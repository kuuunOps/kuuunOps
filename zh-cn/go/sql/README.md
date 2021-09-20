# 数据库操作

## 一、mysql驱动

```go
package main
import "github.com/go-sql-driver/mysql"
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
    DBName: "jazzrecords",
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
func canPurchase(id int, quantity int) (bool, error) {
    var enough bool
    // Query for a value based on a single row.
    if err := db.QueryRow("SELECT (quantity >= ?) from album where id = ?",
        quantity, id).Scan(&enough); err != nil {
        if err == sql.ErrNoRows {
            return false, fmt.Errorf("canPurchase %d: unknown album", id)
        }
        return false, fmt.Errorf("canPurchase %d: %v", id)
    }
    return enough, nil
}
```

### 2、多行查询

```go
func albumsByArtist(artist string) ([]Album, error) {
    rows, err := db.Query("SELECT * FROM album WHERE artist = ?", artist)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    // An album slice to hold data from returned rows.
    var albums []Album

    // Loop through rows, using Scan to assign column data to struct fields.
    for rows.Next() {
        var alb Album
        if err := rows.Scan(&alb.ID, &alb.Title, &alb.Artist,
            &alb.Price, &alb.Quantity); err != nil {
            return albums, err
        }
        albums = append(albums, album)
    }
    if err = rows.Err(); err != nil {
        return albums, err
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
func AddAlbum(alb Album) (int64, error) {
    result, err := db.Exec("INSERT INTO album (title, artist) VALUES (?, ?)", alb.Title, alb.Artist)
    if err != nil {
        return 0, fmt.Errorf("AddAlbum: %v", err)
    }

    // Get the new album's generated ID for the client.
    id, err := result.LastInsertId()
    if err != nil {
        return 0, fmt.Errorf("AddAlbum: %v", err)
    }
    // Return the new album's ID.
    return id, nil
}
```

### 2、更新

```go
func AddAlbum(alb Album) (int64, error) {
    result, err := db.Exec("INSERT INTO album (title, artist) VALUES (?, ?)", alb.Title, alb.Artist)
    if err != nil {
        return 0, fmt.Errorf("AddAlbum: %v", err)
    }

    // Get the new album's generated ID for the client.
    id, err := result.LastInsertId()
    if err != nil {
        return 0, fmt.Errorf("AddAlbum: %v", err)
    }
    // Return the new album's ID.
    return id, nil
}
```