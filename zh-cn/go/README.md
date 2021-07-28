# Go
>Go是一种开源编程语言，可以轻松构建简单、可靠和高效的软件。
---
## Go的安装

### 1、下载安装

- Go官网：https://golang.org/
- 代理网站：https://golang.google.cn/
- 中文网社区：https://studygolang.com/

根据自己操作系统及网络环境，下载对应的安装包文件。

### 2、配置

设置以下环境变量的值

- `GOROOT`：go程序的安装目录

例如：
```shell
GOROOT=/usr/local/go
```

- `GOPATH`: 程序开发的工作区

例如：
```shell
GOPAHT=/home/zhanghk/go
```

- `GOPROXY`: 配置国内依赖包下载代理

例如：
```shell
GO111MODULE=on
GOPROXY=https://goproxy.cn
```

### 3、GOPATH目录结构设置

- bin：用于安装生产的二进制文件
- src：源码存放目录，主要的工作区
- pkg：存放包文件

---

## 第一个程序

### 1、Helloworld

在src目录中创建helloworld程序目录， 在目录中创建文件`helloworld.go`。内容如下：
```go
package main

import "fmt"

func main() {
    fmt.Println("Hello World!")
}
```
运行命令

```shell
go run helloworld.go
```

### 2、go常用命令

- `go run`：运行程序
- `go build`：编译
- `go install`：编译后安装程序
- `go test`：测试

---

## 变量与常量

### 一、变量

#### 1、变量的定义

**方式一**

```go
package main

import "fmt"

func main() {
	/*
    var name string = "LiLei"
    var age int = 18
	 */
	var name string
	name = "LiLei"
	var age int
	age = 18

	fmt.Println(name, age)
}
```

**方式二**

```go
package main

import "fmt"

func main() {
	var name = "LiLei"
	var age = 18

	fmt.Println(name, age)
}
```

**方式三**

```go
package main

import "fmt"

func main() {
	name := "LiLei"
	age := 18

	fmt.Println(name, age)
}
```

#### 2、批量定义

```go
package main

import "fmt"

func main() {
	var (
		name = "LiLei"
		age = 18
	)

	fmt.Println(name, age)
}
```
或

```go
package main

import "fmt"

func main() {
	name, age := "LiLei", 18

	fmt.Println(name, age)
}
```

#### 3、变量的注意事项

- 变量必须先定义才能使用
- 变量类型和赋值必须一致
- 同一作用域内变量名不能重复定义
- 简短定义方式，左侧至少有一个变量是新值
- 简短定义不能定义全局作用域
- 变量存在零值即默认值
  - `int`：0
  - `float`：0
  - `string`：“”
- 变量定义了就必须要使用

---

### 二、常量

#### 1、常量的定义

>常量定义后，在后续使用中，就不可以再进行赋值。

```go
package main

import "fmt"

func main() {
  //const PI float = 3.14
  const PI = 3.14

  fmt.Println(PI)
}
```

定义一组常量

```go
package main

import (
	"fmt"
)

func main() {
	//const NAME,AGE = "LiLei",18
	const (
		NAME = "LiLei"
		AGE = 18
	)
	fmt.Println(NAME,AGE)
}
```

- 常量定义了，可以不使用
- 常量组中，如果未赋值，默认与上一常量的类型和数值是一致的

#### 2、iota

>特殊常量iota，可以被系统修改的常量

```go
package main

import "fmt"

func main() {
	const (
		a = iota
		b = iota
		c = iota
	)
	fmt.Println(a, b, c)
}
```

---

## 基本类型数据

### 一、数值

- 整数
  - `int`：取决于操作系统的位数
  - `int8`：
  - `int16`
  - `int32`：rune
  - `int64`
  - `uint8`：byte
  - `uint16`
  - `uint32`
  - `uint64`

- 浮点数
  - float32
  - float64
  
- 复数

### 二、字符串

`string`是多个byte的集合，使用双引号标注（如果使用单引号标注，将被识别为整数类型，即ACSII表）。

```go
package main

import "fmt"

func main() {
	stu1 := 'L'
	stu2 := "LiLei"

	fmt.Printf("%T,%d\n", stu1, stu1)
	fmt.Printf("%T,%s\n", stu2, stu2)

}
```

### 三、布尔

`bool`的零值为`false`

- `true`
- `false`

```go
package main

import "fmt"

func main() {
  var a bool
  b := true
  c := false

  fmt.Printf("%T,%t\n", a, a)
  fmt.Printf("%T,%t\n", b, b)
  fmt.Printf("%T,%t\n", c, c)
}
```

### 四、数据类型转换

```go
package main

import "fmt"

func main() {
	num1 := 100
	num2 := float64(num1)
	fmt.Printf("%T,%d\n",num1,num1)
	fmt.Printf("%T,%f\n",num2,num2)
}
```

### 五、运算符

- `+`
- `-`
- `*`
- `/`
- `%`
- `++`
- `--`
- `>`
- `<`
- `>=`
- `<=`
- `==`
- `!=`
- `&&`
- `||`
- `!`

---

## 输入与输出

### 一、fmt.Printf()


- `%b`：二进制数值占位符
- `%d`：十进制数值类型变量占位符
- `%f`：浮点数值类型变量占位符
- `%s`：字符串类型变量占位符
- `%t`：布尔类型变量占位符
- `%v`：原值占位符
- `%%`：表示%字面值
- `%T`：变量类型占位符
- `%p`：指针占位符

- `&`：用于获取变量的内存指针地址

```go
package main

import "fmt"

func main() {
	name := "LiLei"
	age := 18
	fmt.Printf("%d的内存地址：%p\n",age,&age)
	fmt.Printf("%s的内存地址：%p\n",name,&name)
}
```

### 二、fmt.Scanln()/fmt.Scanf()

### 三、bufio.NewReader()


---

## 复合类型-array

---
## 复合类型-slice

---
## 复合类型-map

---
## 复合类型-function

---
## 复合类型-pointer

---
## 复合类型-struct

---
## 复合类型-interface

---
## 复合类型-channel
