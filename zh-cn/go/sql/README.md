# 数据库操作

## 一、mysql驱动

```go
package main
import "github.com/go-sql-driver/mysql"
```

SQL脚本准备

```sql
create database recordings;
use recordings;
DROP TABLE IF EXISTS album;
CREATE TABLE album (
  id         INT AUTO_INCREMENT NOT NULL,
  title      VARCHAR(128) NOT NULL,
  artist     VARCHAR(255) NOT NULL,
  price      DECIMAL(5,2) NOT NULL,
  PRIMARY KEY (`id`)
);

INSERT INTO album 
  (title, artist, price) 
VALUES 
  ('Blue Train', 'John Coltrane', 56.99),
  ('Giant Steps', 'John Coltrane', 63.99),
  ('Jeru', 'Gerry Mulligan', 17.99),
  ('Sarah Vaughan', 'Sarah Vaughan', 34.98);
```

---

## 二、数据库连接的建立

### 1、基于字符串

```go
db, err = sql.Open("mysql", "username:password@tcp(127.0.0.1:3306)/jazzrecords")
if err != nil {
log.Fatal(err)
}
```

### 2、基于mysql.Config

```go
// Specify connection properties.
cfg := mysql.Config{
    User:   username,
    Passwd: password,
    Net:    "tcp",
    Addr:   "127.0.0.1:3306",
    DBName: "recordings",
}

// Get a database handle.
db, err = sql.Open("mysql", cfg.FormatDSN())
if err != nil {
    log.Fatal(err)
}
```

### 3、连接的可用性

```go
db, err = sql.Open("mysql", connString)

// Confirm a successful connection.
if err := db.Ping(); err != nil {
    log.Fatal(err)
}
```
---

## 三、查询数据

### 1、单行查询

```go
type Album struct {
ID     int64
Title  string
Artist string
Price  float32
}

// albumByID queries for the album with the specified ID.
func albumByID(id int64) (Album, error) {
// An album to hold data from the returned row.
var alb Album

row := db.QueryRow("SELECT * FROM album WHERE id = ?", id)
if err := row.Scan(&alb.ID, &alb.Title, &alb.Artist, &alb.Price); err != nil {
if err == sql.ErrNoRows {
return alb, fmt.Errorf("albumsById %d: no such album", id)
}
return alb, fmt.Errorf("albumsById %d: %v", id, err)
}

```

### 2、多行查询

```go
// albumsByArtist queries for albums that have the specified artist name.
func albumsByArtist(name string) ([]Album, error) {
// An albums slice to hold data from returned rows.
var albums []Album

rows, err := db.Query("SELECT * FROM album WHERE artist = ?", name)
if err != nil {
return nil, fmt.Errorf("albumsByArtist %q: %v", name, err)
}
defer rows.Close()
// Loop through rows, using Scan to assign column data to struct fields.
for rows.Next() {
var alb Album
if err := rows.Scan(&alb.ID, &alb.Title, &alb.Artist, &alb.Price); err != nil {
return nil, fmt.Errorf("albumsByArtist %q: %v", name, err)
}
albums = append(albums, alb)
}
if err := rows.Err(); err != nil {
return nil, fmt.Errorf("albumsByArtist %q: %v", name, err)
}
return albums, nil
}
```

### 3、空值处理

- NullBool
- NullFloat64
- NullInt32
- NullInt64
- NullString
- NullTime


```go
var s sql.NullString
err := db.QueryRow("SELECT name FROM customer WHERE id = ?", id).Scan(&s)
if err != nil {
    log.Fatal(err)
}

// Find customer name, using placeholder if not present.
name := "Valued Customer"
if s.Valid {
    name = s.String
}
```

### 4、多个查询结果集

```go
rows, err := db.Query("SELECT * from album; SELECT * from song;")
if err != nil {
    log.Fatal(err)
}
defer rows.Close()

// Loop through the first result set.
for rows.Next() {
    // Handle result set.
}

// Advance to next result set.
rows.NextResultSet()

// Loop through the second result set.
for rows.Next() {
    // Handle second set.
}

// Check for any error in either result set.
if err := rows.Err(); err != nil {
    log.Fatal(err)
}
```
---

## 四、执行非返回数据的SQL语句

### 1、插入

```go
func addAlbum(alb Album) (int64, error) {
    result, err := db.Exec("INSERT INTO album (title, artist, price) VALUES (?, ?, ?)", alb.Title, alb.Artist, alb.Price)
    if err != nil {
        return 0, fmt.Errorf("addAlbum: %v", err)
    }
    id, err := result.LastInsertId()
    if err != nil {
        return 0, fmt.Errorf("addAlbum: %v", err)
    }
    return id, nil
}
```

### 2、更新

```go
func updateAlbumByID(id int64) (int64, error) {
    result, err := db.Exec("UPDATE album SET price = 100 WHERE id = ?", id)
    if err != nil {
        return 0, fmt.Errorf("updateAlbumByID: %v", err)
    }
    rows, err := result.RowsAffected()
    if err != nil {
        return 0, fmt.Errorf("updateAlbumByID: %v", err)
    }
    return rows, nil
}
```

### 3、删除

```go
func deleteAlbumByPrice(price float32) (int64, error) {
	result, err := db.Exec("DELETE FROM album  WHERE price > ?", price)
	if err != nil {
		return 0, fmt.Errorf("deleteAlbumByPrice: %v", err)
	}
	rows, err := result.RowsAffected()
	if err != nil {
		return 0, fmt.Errorf("deleteAlbumByPrice: %v", err)
	}
	return rows, nil
}
```

---

## 五、预处理

```go
// AlbumByID retrieves the specified album.
func AlbumByID(id int) (Album, error) {
    // Define a prepared statement. You'd typically define the statement
    // elsewhere and save it for use in functions such as this one.
    stmt, err := db.Prepare("SELECT * FROM album WHERE id = ?")
    if err != nil {
        log.Fatal(err)
    }

    var album Album

    // Execute the prepared statement, passing in an id value for the
    // parameter whose placeholder is ?
    err := stmt.QueryRow(id).Scan(&album.ID, &album.Title, &album.Artist, &album.Price, &album.Quantity)
    if err != nil {
        if err == sql.ErrNoRows {
            // Handle the case of no rows returned.
        }
        return album, err
    }
    return album, nil
}
```