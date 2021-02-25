# 基础知识

## 1. 认识Python

> Python是一门解释型、面向对象的高级编程语言,Python是开源免费的、支持交互式、可跨平台移植的脚步语言

#### 1.1 Python历程及特性

* 1991年，第一个Python编辑器
* 2000年，Python2.0发布
* 2008年，Python3发布

**特性**

- 开源、易于维护
- 可移植
- 易于使用、简单优雅
- 广泛的标准库、功能强大
- 可扩展、可嵌入

**缺点**

- 运行速度慢
- 代码不能加密

#### 1.2 安装Python环境

* [Python下载地址](https://www.python.org/downloads/)

#### 1.2 IDEA工具

* [PyCharm下载地址](https://www.jetbrains.com/pycharm/download/)
* [VSCode下载地址](https://code.visualstudio.com/Download)


#### 1.3 第一个Python程序

```python
print("Hello,Python")
```

**注释**

* 单行注释

```python
# 这是一个单行注释
```

* 多行注释

```python
"""
这是多行注释
"""

'''
这是多行注释
'''

```

#### 1.4 变量及数据类型

- 变量可以是任意数据类型
- 变量名必须是大小写的英文、数字和下换线`(_)`的组合，且不能以数字开头

**内置关键字**

```python
import keyword
print(keyword.kwlist)
['False', 'None', 'True', 'and', 'as', 'assert', 'async', 'await', 'break', 'class', 'continue', 'def', 'del', 'elif', 'else', 'except', 'finally', 'for', 'from', 'global', 'if', 'import', 'in', 'is', 'lambda', 'nonlocal', 'not', 'or', 'pass', 'raise', 'return', 'try', 'while', 'with', 'yield']
```


#### 1.5 格式化输出

```python
name = "小明"
age = 18

print("我叫%s,今年：%d" % (name, age))
print("我叫{},今年：{}".format(name, age))
print("我叫{0},今年：{1}".format(name, age))
print("我叫{name},今年：{age}".format(name=name, age=age))
print(f"我叫{name},今年：{age}")
```

#### 1.6 输入

```python
password = input("请输入密码：")
print("您刚才输入的密码是：", password)

请输入密码：123456
您刚才输入的密码是： 123456 
```

#### 1.7 数据类型

```python
a = 10
print(type(a))

<class 'int'>
```

#### 1.8 字符串类型数字强制转换

```python
a = '10'
print(type(a))
a = int(a)
print(type(a))

<class 'str'>
<class 'int'>
```

#### 1.9 运算符与表达式

**算数运算符**

`+,-,*,/,%,**,//`

**比较运算符**

`==,!=,>,<,>=,<= `

**位运算**

`&,|,^,~,<<,>>`

**逻辑运算**

`and,or,and`

**成员运算符**

`in,not in`

**身份运算符**

`is,is not`

## 2. 逻辑控制语句

#### 2.1 条件判断语句

- 非0和非空的值为True
- 0或None的值为False

**if语句**

```python
if ...:
    代码块1
else
    代码块2
```


#### 2.2 循环语句

**for语句**

```python
for ...:
    ...
```

**while语句**

```python
while ...:
    ...
```

#### 2.3 break，continue和pass语句

- break
- continue
- pass


## 3. 数据结构

#### 3.1 字符串`String`

**截取**

**拼接**

**转义**

#### 3.2 列表`List`

