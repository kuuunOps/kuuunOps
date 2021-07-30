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

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {

    fmt.Println("请输入内容：")
	reader := bufio.NewReader(os.Stdin)
	s1, _ := reader.ReadString('\n')
	fmt.Printf(s1)
}

```
---

## 流程控制

### 一、if

#### 1、if

```go
package main

import "fmt"

func main() {
	num:= 16
	if num > 10 {
		fmt.Println("大于10")
	}
	fmt.Println("main...over...")
}
```

#### 2、if...else

```go
package main

import "fmt"

func main() {

	score := 0
	fmt.Println("请输入你的成绩：")
	fmt.Scanln(&score)
	if score >= 60 {
		fmt.Println("成绩合格")
	} else {
		fmt.Println("成绩不合格")
	}
}
```

if 语句嵌套

```go
package main

import (
	"fmt"
)

func main() {

	sex := "男"
	if sex == "男" {
		fmt.Println("去男厕所")
	} else {
		if sex == "女" {
			fmt.Println("去女厕所")
		} else {
			fmt.Println("不知道")
		}
	}
}
```


#### 3、if...else...if

```go
package main

import (
	"fmt"
)

func main() {

	sex := "男"
	if sex == "男" {
		fmt.Println("去男厕所")
	} else if sex == "女" {
		fmt.Println("去女厕所")
	} else {
		fmt.Println("不知道")
	}
}
```

#### 4、if其他用法

```go
package main

import "fmt"

func main() {
  if num := 4; num > 0 {
    fmt.Println("正数")
  } else {
    fmt.Println("负数")
  }
}

```

---

### 二、switch

- switch可以作用在其他数据类型
- switch作用的变量类型必须和case的数据类型一致
- case后的数据必须是唯一的
- default语句为可选

#### 1、基本用法

```go
package main

import "fmt"

func main() {

  num := 3
  switch num {
  case 1:
    fmt.Println("第一季度")
  case 2:
    fmt.Println("第二季度")
  case 3:
    fmt.Println("第三季度")
  case 4:
    fmt.Println("第四季度")
  default:
    fmt.Println("数据异常")
  }
}

```
#### 2、switch其他用法

```go
package main

import "fmt"

func main() {
	score := 80
	switch {
	case score >= 0 && score < 60:
		fmt.Println("D")
	case score >= 60 && score < 70:
		fmt.Println("C")
	case score >= 70 && score < 80:
		fmt.Println("B")
	case score >= 80:
		fmt.Println("A")
	}
}
```

或

```go
package main

import "fmt"

func main() {

	month := 5
	day := 0
	year := 2019
	switch month {
	case 1, 3, 5, 7, 8, 10, 12:
		day = 31
	case 4, 6, 9, 11:
		day = 30
	case 2:
		if year%400 == 0 || year%4 == 0 && year%100 != 0 {
			day = 29
		} else {
			day = 28
		}
	}
	fmt.Printf("%d 年 %d 月 的天数是 %d\n", year, month, day)
}

```

或

```go
package main

import "fmt"

func main() {

	switch language := "golang";language {
	case "golang":
		fmt.Println("Go语言")
	case "python":
		fmt.Println("Python语言")
	case "java":
		fmt.Println("Java语言")
	}
}

```

#### 3、break/fallthrough

- break用于强制结束case语句
- fallthrough用于穿透case语句

```go
package main

import "fmt"

func main() {
	num := 1
	switch num {
	case 1:
		fmt.Println("1")
		fmt.Println("1")
		break
		fmt.Println("1")
	case 2:
		fmt.Println("2")
		fmt.Println("2")
		fmt.Println("2")
	}
}
```

或

```go
package main

import "fmt"

func main() {
	num := 2
	switch num {
	case 1:
		fmt.Println("1")
		fmt.Println("1")
		fmt.Println("1")
	case 2:
		fmt.Println("2")
		fmt.Println("2")
		fmt.Println("2")
		fallthrough
	case 3:
		fmt.Println("3")
		fmt.Println("3")
		fmt.Println("3")
	}
}
```

---

### 三、for

#### 1、基本使用

```go
package main

import "fmt"

func main() {

	for i:=0;i < 5;i++{
		fmt.Println("Hello World!")
	}
}
```

#### 2、其他用法

```go
package main

import "fmt"

func main() {

	i := 0
	for i<5 {
		fmt.Println("Hello World")
		i++
	}
}
```
或

```go
package main

import "fmt"

func main() {
	i := 0
	for {
		fmt.Println(i)
		if i == 5 {
			break
		}
		i++
	}
}
```

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
