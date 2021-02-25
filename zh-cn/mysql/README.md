# MySQL

### 基础查询

#### 1. SQL简单查询

**语法格式：**

```sql
SELECT [DISTINCT] *|列[别名],... FROM 表名
```

#### 查询表中的所有数据

```sql
SELECT * FROM emp;
```

#### 指定列（投影查询）

```sql
SELECT empno,enname,sal,job FROM emp;
```

#### 四则运算

```sql
SELECT empno,enname,sal*12 FROM emp;
```

#### 别名设置

```sql
SELECT empno,enname,sal*12 income FROM emp;

//别名也可以使用中文，但不建议使用中文
SELECT empno 雇员编号,enname 姓名,sal*12 年薪 FROM emp;
```
#### 数据连接操作

- 使用'||'进行数据连接操作

```sql
SELECT empno||ename FROM emp;

// SQL中数字直接写，字符串要使用单引号声明
SELECT empno||1 FROM emp;
SELECT empno||'hello' FROM emp;
```

- 使用数据连接格式化操作

```sql
SELECT '编号:'||empno||'姓名：'||ename FROM emp;
```
#### 消除重复内容

DISTINCT

```SQL
SELECT DISTINCT job FROM emp;
```


# 总结：SQL简单查询可以控制数据列，无法控制数据行