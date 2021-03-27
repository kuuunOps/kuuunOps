# MySQL

## 基础查询

### 1. SQL简单查询

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

**总结：SQL简单查询可以控制数据列，无法控制数据行**


****

### 2. SQL限定查询

**语法：**

```sql
【③ 确定要显示的数据列 】SELECT [DISTINCT] *|列[别名],列[别名],列[别名],... 
【① 确定数据来源 】FROM 表名 
【② 针对数据进行筛选 】[WHERE 限定条件(s)]
```

**语句执行顺序**

1. 执行数据来源`FROM`语句
2. 执行数据条件`WHERE`语句
3. 选出所需要的数据列`SELECT`语句

**SQL条件运算**

1. 关系运算：`<、=、>、>=、<=、!=(<>)`

```sql
SELECT *
FROM emp
WHERE sal < 1200;
```

```sql
SELECT *
FROM emp
WHERE sal = 3000;
```

```sql
SELECT *
FROM emp
WHERE ename='SMITH'; 
-- 注意区分大小写
```

```sql
SELECT *
FROM emp
WHERE job<>'CLERK';
```

   

2. 逻辑运算：`AND、OR、NOT`

```sql
SELECT *
FROM emp
WHERE job<>'CLERK' AND sal<3000;
```

```sql
SELECT *
FROM emp
WHERE job<>'CLERK' AND job<>'SALESMAN';
```

```sql
SELECT *
FROM emp
WHERE job='CLERK' OR sal<1200;
```

```sql
SELECT *
FROM emp
WHERE NOT sal>2000;
```



3. 范围运算：`BETWEEN...AND`

**语法样式**

```sql
WHERE 字段|数值 BETWEEN 最小值 AND 最大值；
```

```sql
SELECT *
FROM emp
WHERE sal BETWEEN 1500 AND 3000；
```

```sql
SELECT *
FROM emp
WHERE hiredate BETWEEN '01-1月-81' AND '31-12月-1981'；
```

```sql
SELECT * FROM emp WHERE ename BETWEEN 'ALEEN' AND 'CLEAK'
```

   

4. 空判断：`IS NULL、IS NOT NULL`

```sql
SELECT *
FROM emp
WHERE comm 	IS NOT NULL;
```

   

5. IN判断：`IN、NOT IN、exists()（复杂查询）`

注：`NOT IN`中不能包含null

```sql
SELECT *
FROM emp
WHERE empno IN (7369,7566,7788,9999);
```

   

6. 模糊查询：`LIKE、NOT LIKE`

* '_'：匹配任意的一位符号
* '%'：匹配任意的符号

```sql
SELECT *
FROM emp
WHERE ename LIKE 'A%';
```

```sql
SELECT *
FROM emp
WHERE ename LIKE '_A%';
```

```sql
SELECT *
FROM emp
WHERE ename LIKE '%A%';
```

**注：**
1. 如果LIKE匹配为空，则匹配所有数据
2. LIKE支持所有的数据类型，但是我们主要用于字符串


****

### 3. SQL查询排序

**语法格式：**

排序可以在任意数据类型进行
执行顺序如下：

```sql
【③ 确定要显示的数据列 】SELECT [DISTINCT] *|列[别名],列[别名],列[别名],... 
【① 确定数据来源 】FROM 表名 
【② 针对数据进行筛选 】[WHERE 限定条件(s)]
【④ 对选定的数据的行与列进行排序 】 [ORDER BY 排序字段 [ASC|DESC],排序字段 [ASC|DESC],...]
```

* ASC：升序（默认）
* DESC：降序

```sql
SELECT *
FROM emp
ORDER BY sal DESC;
```

```sql
SELECT *
FROM emp
ORDER BY hiredate;
```

```sql
SELECT *
FROM emp
ORDER BY sal DESC,hiredate;
```

```sql
SELECT empno,job,sal*12 income
FROM emp
WHERE job='CLERK'
ORDER BY income;
```

---
---

## 单行函数

### 1. 单行函数简介

**单行函数简介**

> ​在数据库里面为了方便用户的开发，会提供一系列函数支持，利用函数的特定功能，实现指定的效果

#### 常见函数

* 字符串函数
* 数值函数
* 日期函数
* 转换函数
* 通用函数

---

### 2. 字符串函数

> ​	字符串函数可以对字符串数据进行处理。

**常见操作**

* 大写转换：UPPER()
* 小写转换：LOWER()
* 首字母大写：INITCAP()
* 替换：REPLACE()
* 长度计算：LENGTH()
* 截取：SUBSTR()

**大小写转换函数**

* 语法结构

1. 大写转换

```sql
字符串 UPPER(列|字符串)
```

2. 小写转换

```sql
字符串 LOWER(列|字符串)
```

* 验证函数功能表：dual

```sql
SELECT LOWER(Hello) FROM dual;
```

* 用户交互

```sql
SELECT * FROM emp WHERE ename='&inputname';
```

对输入数据进行处理,大写操作

```sql
SELECT * FROM emp WHERE ename=UPPER('&inputname');
```

#### 三、首字母大写

```sql
SELECT INITCAP('helloWorld') FROM dual;
```



```sql
SELECT INITCAP(ename) FROM emp;
```

**字符串长度**

```sql
SELECT ename,LENGTH(ename) FROM emp;
```

```sql
SELECT * FROM emp WHERE LENGTH(ename)=5;
```

**字符串替换**

​REPLACE()可以消除空格

​语法格式：
```sql
字符串 REPLACE(列|数据，要查找内容，新的内容)
```

范例：
```sql
SELECT REPLACE(ename,UPPER(''A),'_') FROM emp;
```

```SQL
SELECT REPLACE('hello world ! nihao') FROM dual;
```

**字符串截取**

* 语法结构
1. 字符串 SUBSTR(列|数据，开始点)
2. 字符串 SUBSTR(列|数据，开始点，长度)

* 范例：
```sql
SELECT SUBSTR('helloworldnihao',11) FROM dual;
SELECT SUBSTR('helloworldnihao',6,5) FROM dual;
```

**注：SQL中的下标从1开始，非0**
* 负值截取
```SQL
SELECT ename,SUBSTR(ename,LENGTH(ename)-2) FROM emp;
```

* 仅限ORACLE数据库
```sql
SELECT ename,SUBSTR(ename,-3) FROM emp;
```

---

