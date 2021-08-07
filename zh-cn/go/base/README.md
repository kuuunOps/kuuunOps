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
		age  = 18
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

> 常量定义后，在后续使用中，就不可以再进行赋值。

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
		AGE  = 18
	)
	fmt.Println(NAME, AGE)
}
```

- 常量定义了，可以不使用
- 常量组中，如果未赋值，默认与上一常量的类型和数值是一致的

#### 2、iota

> 特殊常量iota，可以被系统修改的常量

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
	fmt.Printf("%T,%d\n", num1, num1)
	fmt.Printf("%T,%f\n", num2, num2)
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
	fmt.Printf("%d的内存地址：%p\n", age, &age)
	fmt.Printf("%s的内存地址：%p\n", name, &name)
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
	num := 16
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

	switch language := "golang"; language {
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

	for i := 0; i < 5; i++ {
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
	for i < 5 {
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

#### 3、break/continue

**break**

```go
package main

import "fmt"

func main() {
	for i := 0; i < 10; i++ {
		if i == 5 {
			break
		}
		fmt.Println(i)
	}
}
```

**continue**

```go
package main

import "fmt"

func main() {
	for i := 0; i < 10; i++ {
		if i == 5 {
			continue
		}
		fmt.Println(i)
	}
}
```

**标记循环**

```go
package main

import "fmt"

func main() {
	// 标记要终止的循环

out:
	for i := 0; i < 10; i++ {
		fmt.Println(i)
		for j := 0; j < 10; j++ {
			if j == 5 {
				break out
			}
			fmt.Println(j)
		}
	}
}

```

#### 4、goto

```go
package main

import "fmt"

func main() {
	var a = 10
LOOP:
	for a < 20 {
		if a == 15 {
			a += 1
			goto LOOP
		}
		fmt.Println(a)
		a++
	}

}
```

---

### 四、随机数生成

#### 1、基本使用

```go
package main

import (
	"fmt"
	"math/rand"
	"time"
)

func main() {
	//设置种子数
	rand.Seed(time.Now().UnixNano() * 7)
	num := rand.Intn(9999)
	fmt.Println(num)
}
```

#### 2、范围随机

```go
package main

import (
	"fmt"
	"math/rand"
	"time"
)

func main() {
	//10-99 之间随机数获取
	rand.Seed(time.Now().UnixNano())
	fmt.Println(rand.Intn(99-10) + 10)

}
```

---

## 复合类型-array

- 数组是值传递类型

### 1、数组的定义

- 数组的初始化

```go
package main

import "fmt"

func main() {
	// 定义一个长度为4的int类型数组
	var arr1 [4]int
	arr1[0] = 1
	arr1[1] = 2
	arr1[2] = 3
	arr1[3] = 4
	fmt.Println(arr1)
	fmt.Println(arr1[2])
}

```

- **len/cap**
    - len()：获取长度，实际的数据量
    - cap()：获取容量，可存储的数据量

```go
package main

import "fmt"

func main() {
	// 定义一个长度为4的int类型数组
	var arr1 [4]int
	arr1[0] = 1
	arr1[1] = 2
	arr1[2] = 3
	fmt.Printf("长度为：%d\n", len(arr1))
	fmt.Printf("容量为：%d\n", cap(arr1))
}
```

- 数组初始化赋值

```go
package main

import "fmt"

func main() {
	var a = [4]int{1, 2, 4, 5}
	fmt.Println(a)
}

```

指定下标位置初始值

```go
package main

import "fmt"

func main() {
	var a = [5]int{1: 3, 3: 20}
	fmt.Println(a)
}
```

- 不定长赋值

```go
package main

import "fmt"

func main() {
	var a = [...]int{3, 20, 99, 222}
	fmt.Println(a)
	fmt.Println(cap(a))
	fmt.Println(len(a))
}
```

### 2、数组的遍历

#### 方法1-下标

```go
package main

import "fmt"

func main() {
	arr1 := [...]int{2, 44, 5, 54}
	fmt.Println(arr1[2])
}
```

#### 方法2-for...i

```go
package main

import "fmt"

func main() {
	arr1 := [...]int{2, 44, 5, 54}
	for i := 0; i < len(arr1); i++ {
		fmt.Println(arr1[i])
	}
}

```

#### 方法3-for...range

```go
package main

import "fmt"

func main() {
	arr1 := [...]int{2, 44, 5, 54}
	for i, i2 := range arr1 {
		fmt.Println(i, i2)
	}
}
```

### 3、数组的排序

#### 冒泡排序

```go
package main

import "fmt"

func main() {
	arr := [...]int{15, 23, 8, 10, 7, 1, 23, 4356, 234, 23}
	for j := 0; j < len(arr); j++ {
		for i := 0; i < len(arr)-1; i++ {
			if arr[i] > arr[i+1] {
				arr[i], arr[i+1] = arr[i+1], arr[i]
			}
		}
	}
	fmt.Println(arr)
}
```

### 4、多维数组

#### 二维数组

```go
package main

import "fmt"

func main() {
	arr := [3][5]int{{1, 2, 3, 65, 2}, {2, 43, 5, 21, 3}, {3, 5, 76, 3, 23}}
	fmt.Println(arr)
}
```

---

## 复合类型-slice

- slice是引用型数据类型，存储的array的内存地址

### 一、slice的基本使用

#### slice的创建

```go
package main

import "fmt"

func main() {
	var s1 []int
	fmt.Println(s1)

	s2 := []int{1, 2, 3, 5}
	fmt.Println(s2)
}

```

#### make

- 使用make创建slice

```go
package main

import "fmt"

func main() {
	s1 := make([]int, 3, 10)
	fmt.Println(s1)
}

```

#### append

- 使用append向slice中添加元素

```go
package main

import "fmt"

func main() {
	s1 := make([]int, 0, 5)
	s1 = append(s1, 1, 2)
	fmt.Println(s1)
}
```

或

```go
package main

import "fmt"

func main() {
	s1 := []int{1, 2, 34, 5, 435, 545}

	s := make([]int, 0, 0)
	s = append(s, 100, 99)
	s = append(s, s1...)
	fmt.Println(s) //[100 99 1 2 34 5 435 545]

}

```

### 二、slice的遍历

#### 1、for...i

```go
package main

import "fmt"

func main() {
	s1 := []int{1, 2, 34, 5, 435, 545}
	for i := 0; i < len(s1); i++ {
		fmt.Println(s1[i])
	}
}

```

#### 2、for...range

```go
package main

import "fmt"

func main() {
	s1 := []int{1, 2, 34, 5, 435, 545}

	for i, i2 := range s1 {
		fmt.Println(i, i2)
	}

}
```

### 三、array创建slice

```go
package main

import "fmt"

func main() {
	a := [...]int{2, 3, 5, 6, 8, 33, 44, 66, 77}
	fmt.Println(a)
	s1 := a[:3]
	fmt.Printf("s1:%v,len:%d,cap:%d\n", s1, len(s1), cap(s1))
	s2 := a[4:]
	fmt.Printf("s1:%v,len:%d,cap:%d\n", s2, len(s2), cap(s2))
	s3 := a[3:7]
	fmt.Printf("s1:%v,len:%d,cap:%d\n", s3, len(s3), cap(s3))

}
```

### 四、深copy与浅copy

#### for循环实现深copy

```go
package main

import "fmt"

func main() {
	s1 := []int{2, 3, 4, 5, 6}
	s2 := make([]int, 0, 10)
	for _, i := range s1 {
		s2 = append(s2, i)
	}
	fmt.Printf("%p\n", s1)
	fmt.Printf("%p\n", s2)
}

```

#### copy

```go
package main

import "fmt"

func main() {
	s1 := []int{12, 22, 33, 44, 55}
	s2 := make([]int, len(s1))
	copy(s2, s1)
	fmt.Println(s2)
}
```

---

## 复合类型-map

- map是引用类型数据

### 一、map的使用

#### 1、创建map

```go
package main

import "fmt"

func main() {
	var m1 map[int]string         // 只是声明，无法直接使用
	var m2 = make(map[int]string) // 初始化
	var m3 = map[string]int{"Golang": 98, "Python": 99, "Java": 100}
	fmt.Println(m1)
	fmt.Println(m2)
	fmt.Println(m3)
}

```

#### 2、修改map

```go
package main

import "fmt"

func main() {
	m1 := make(map[string]int)
	m1["China"] = 100
	m1["Japan"] = 99
	m1["USA"] = 98
	fmt.Println(m1)
}

```

#### 3、获取map

```go
package main

import "fmt"

func main() {
	m1 := make(map[string]int)
	m1["China"] = 100
	m1["Japan"] = 99
	m1["USA"] = 98
	fmt.Println(m1)
	fmt.Println(m1["China"])
}

```

或

```go
package main

import (
	"fmt"
)

func main() {
	m1 := make(map[string]int)
	m1["China"] = 100
	m1["Japan"] = 99
	m1["USA"] = 98

	if v, ok := m1["India"]; ok {
		fmt.Println(v)
	} else {
		m1["India"] = 0
	}
	fmt.Println(m1)
}

```

#### 4、删除map

```go
package main

import (
	"fmt"
)

func main() {
	m1 := make(map[string]int)
	m1["China"] = 100
	m1["Japan"] = 99
	m1["USA"] = 98

	if v, ok := m1["India"]; ok {
		fmt.Println(v)
	} else {
		m1["India"] = 0
	}
	fmt.Println(m1)

	delete(m1, "India")
	fmt.Println(m1)
}

```

### 二、map的遍历

#### 1、无序遍历

```go
package main

import (
	"fmt"
)

func main() {
	s := map[string]int{"China": 100, "Japan": 99, "USA": 98}

	for k, v := range s {
		fmt.Println(k, v)
	}

}

```

#### 2、有序遍历

```go
package main

import (
	"fmt"
	"sort"
)

func main() {
	s := map[string]int{"China": 100, "Japan": 99, "USA": 98}

	ss := make([]string, 0)
	for k, _ := range s {
		ss = append(ss, k)
	}
	sort.Strings(ss)

	for _, i := range ss {
		fmt.Println(i, s[i])
	}

}
```

### 三、map与slice

```go
package main

import "fmt"

func main() {
	user1 := make(map[string]string)
	user1["name"] = "李雷"
	user1["age"] = "20"
	user1["sex"] = "男"
	user1["address"] = "北京市昌平区"

	user2 := make(map[string]string)
	user2["name"] = "韩梅梅"
	user2["age"] = "18"
	user2["sex"] = "女"
	user2["address"] = "北京市通州区"

	user3 := make(map[string]string)
	user3["name"] = "李晓华"
	user3["age"] = "21"
	user3["sex"] = "女"
	user3["address"] = "杭州市余杭区"

	users := make([]map[string]string, 0)
	users = append(users, user1)
	users = append(users, user2)
	users = append(users, user3)

	for _, user := range users {
		fmt.Println(user["name"])
	}
}

```

---

## 字符串-String

- 字符串是一个字节的切片
- 字节--byte--uint8

### 一、string使用

#### 1、string的定义

```go
package main

import "fmt"

func main() {
	s1 := "Hello"
	s2 := `Hello World!`
	fmt.Println(s1)
	fmt.Println(s2)

}

```

#### 2、len

- 字节长度

```go
package main

import "fmt"

func main() {
	s1 := "Hello 中国!"
	s2 := `Hello World!`
	fmt.Println(s1)
	fmt.Println(s2)
	fmt.Println(len(s1))
	fmt.Println(len(s2))
}

```

#### 3、字符串的遍历

```go
package main

import "fmt"

func main() {
	s1 := "Hello 中国!"

	for _, i := range s1 {
		fmt.Println(i)
	}
}

```

#### 4、字符串与字节的转换

```go
package main

import "fmt"

func main() {

	s1 := "Hello 中国!"
	fmt.Println([]byte(s1))

	s2 := []byte{72, 101, 108, 108, 111, 32, 228, 184, 173, 229, 155, 189, 33}
	fmt.Println(string(s2))
}

```

### 二、strings包

#### Contains

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	s1 := "Hello World!"
	if strings.Contains(s1, "H") {
		fmt.Println("存在")
	} else {
		fmt.Println("不存在")
	}
}

```

#### ContainsAny

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	s1 := "Hello World!"

	if strings.ContainsAny(s1, "Hc") {
		fmt.Println("存在")
	} else {
		fmt.Println("不存在")
	}
}

```

#### Count

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	s1 := "Hello World!"

	fmt.Println(strings.Count(s1, "l"))

}

```

#### HasPrefix/HasSuffix

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	s1 := "Hello World!"

	fmt.Println(strings.HasPrefix(s1, "Hello"))
	fmt.Println(strings.HasSuffix(s1, "!"))

}

```

#### Index/LastIndex

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	s1 := "Hello World!"

	fmt.Println(strings.Index(s1, "o"))
	fmt.Println(strings.LastIndex(s1, "o"))
}


```

#### IndexAny

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	s1 := "Hello World!"

	fmt.Println(strings.IndexAny(s1, "oa"))
}

```

#### Join

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	s1 := []string{"Hello", "World", "!"}

	s2 := strings.Join(s1, " ")
	fmt.Println(s2)
}

```

#### Split

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	s1 := `123-456-789`
	fmt.Println(strings.Split(s1, "-"))
}

```

#### Repeat

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	s1 := strings.Repeat("Ah ", 5)
	fmt.Println(s1)
}

```

#### Replace

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	s1 := "Hello World！"
	fmt.Println(strings.Replace(s1, "o", "*", -1))
}

```

#### ToLower/ToUpper

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	s1 := "Hello World！"

	fmt.Println(strings.ToLower(s1))
	fmt.Println(strings.ToUpper(s1))
}

```

### 三、strconv包

#### string--bool

```go
package main

import (
	"fmt"
	"strconv"
)

func main() {
	s1 := "true"
	if s, err := strconv.ParseBool(s1); err != nil {
		fmt.Println(err)
	} else {
		fmt.Println(s)

	}
}

```

```go
package main

import (
	"fmt"
	"strconv"
)

func main() {
	b1 := true

	s1 := strconv.FormatBool(b1)
	fmt.Println(s1)

}

```

#### string--int

```go
package main

import (
	"fmt"
	"strconv"
)

func main() {
	s1 := "100"
	v, err := strconv.ParseInt(s1, 10, 64)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(v)

}

```

```go
package main

import (
	"fmt"
	"strconv"
)

func main() {
	s := "100"
	v, err := strconv.Atoi(s)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(v)
}

```

```go
package main

import (
	"fmt"
	"strconv"
)

func main() {
	n := 100
	s := strconv.FormatInt(int64(n), 10)
	fmt.Println(s)
}

```

```go
package main

import (
	"fmt"
	"strconv"
)

func main() {
	n := 100
	fmt.Println(strconv.Itoa(n))
}

```

---

## 复合类型-function

- go语言中至少含有一个main函数，程序启动时，系统自动执行的函数

### 一、函数的基本使用

```go
package main

import "fmt"

func getSum() {
	sum := 0
	for i := 1; i <= 100; i++ {
		sum += i
	}
	fmt.Println(sum)
}
func main() {
	getSum()
}

```

### 二、参数

#### 1、固定参数

```go
package main

import "fmt"

// 用于统计数字累加和
func getSum(start, end int) int {
	/*
		start: 起始数值的变量参数
		end：结束数值的变量参数
		return：返回计算结果
	*/
	sum := 0
	for i := start; i <= end; i++ {
		sum += i
	}
	return sum
}
func main() {
	sum := getSum(1, 97)
	fmt.Println(sum)
}

```

#### 2、可变参数

- 可变参数即slice
- 最多只能有一个可变参数

```go
package main

import "fmt"

func getSum(nums ...int) {
	sum := 0
	for i := 0; i < len(nums); i++ {
		sum += nums[i]
	}
	fmt.Println(sum)
}

func main() {
	// getSum([]int{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}...)
	getSum(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
}

```

#### 3、参数传递

- 值传递
- 引用传递

### 三、返回值

#### 1、返回一个值

```go
package main

import "fmt"

func add(x, y int) int {
	return x + y
}

func main() {
	res := add(3, 5)
	fmt.Println(res)
}

```

#### 2、多值返回

```go
package main

import "fmt"

func demo(x, y int) (int, int) {
	return x + y, x * y
}

func main() {
	v1, v2 := demo(4, 3)
	fmt.Println(v1, v2)
}

```

#### 3、空白标识符“_”

```go
package main

import "fmt"

func demo(x, y int) (int, int) {
	return x + y, x * y
}

func main() {
	v1, _ := demo(4, 3)
	fmt.Println(v1)
}

```

### 四、作用域

#### 1、局部作用域

- 在函数内部定义的变量
- 变量在哪里定义，就只能在哪个范围使用

#### 2、全局作用域

- 在函数外部定义的变量
- 所有的函数都可以使用，数据共享

### 五、递归函数

- 一个函数自己调用自己

```go
package main

import "fmt"

func getSum(num int) int {
	if num == 1 {
		return 1
	}
	return getSum(num-1) + num

}

func main() {
	sum := getSum(100)
	fmt.Println(sum)
}

```

### 六、defer

- 让一个函数或方法的执行被延迟执行
- 多个defer，按LIFO顺序执行
- defer函数调用时，就已经传递参数了，只是暂时不执行函数中的代码

```go
package main

import "fmt"

func fun1(s string) {
	fmt.Println(s)
}
func main() {
	defer fun1("第一：王二狗")
	defer fun1("第二：李小花")
	fun1("李四")
}

```

### 七、匿名函数

#### 1、基本样式

```go
package main

import "fmt"

func main() {
	func() {
		fmt.Println("Hello World!")
	}()
}

```

#### 2、带参数

```go
package main

import "fmt"

func main() {
	func(a, b int) {
		fmt.Println(a + b)
	}(1, 2)
}

```

#### 3、带返回值

```go
package main

import "fmt"

func main() {
	res := func(a, b int) int {
		return a + b
	}(1, 2)

	fmt.Println(res)
}
```

### 八、回调函数

```go
package main

import "fmt"

func main() {

	res1 := oper(10, 20, add)
	fmt.Println(res1)

	res2 := oper(30, 20, sub)
	fmt.Println(res2)
}

// 闭包函数
func add(a, b int) int {
	return a + b
}

func sub(a, b int) int {
	return a - b
}

// 高阶函数
func oper(a, b int, fun func(int, int) int) int {
	return fun(a, b)
}

```

使用匿名函数作为参数

```go
package main

import "fmt"

func main() {

	res3 := oper(10, 20, func(a int, b int) int {
		return a * b
	})
	fmt.Println(res3)
}

func oper(a, b int, fun func(int, int) int) int {
	return fun(a, b)
}

```

### 九、闭包

```go
package main

import "fmt"

func main() {
	res1 := increment()
	fmt.Println(res1())
}

func increment() func() int {
	i := 1
	return func() int {
		i++
		return i
	}
}

```

---

## 复合类型-pointer

### 一、指针基本使用

```go
package main

import "fmt"

func main() {

	//获取地址
	a := 10
	fmt.Printf("%p\n", &a)
	//声明指针
	var p1 *int
	p1 = &a

	// 使用&获取数值的指针地址
	// 使用*获取指针地址指向的数值
	fmt.Println(*p1)
	fmt.Printf("%p\n", p1)

	//修改数值
	*p1 = 200
	fmt.Println(*p1)
	fmt.Println(a)

}

```

### 二、数值的指针和指针的数值

```go
package main

import "fmt"

func main() {

	//定义数组
	arr1 := [4]int{1, 2, 3, 4}
	fmt.Println(arr1)
	//获取数值的指针地址
	fmt.Println(&arr1)

	//定义数组类型的指针变量
	var p1 *[4]int
	p1 = &arr1
	fmt.Println(p1)
	fmt.Println(*p1)

	//修改元素数值
	(*p1)[0] = 100
	fmt.Println(arr1)
	// 简写
	p1[1] = 200
	fmt.Println(arr1)

	a := 1
	b := 2
	c := 3
	d := 4
	arr2 := [4]int{a, b, c, d}
	// 定义存储指针类型数据的数组
	arr3 := [4]*int{&a, &b, &c, &d}
	fmt.Println(arr2)
	fmt.Println(*arr3[0])
}

```

### 三、函数指针和指针函数

#### 1、函数的指针

- 指向了一个函数的指针

```go
package main

import "fmt"

func main() {

	var f func()
	f = fun1
	f()
}

func fun1() {
	fmt.Println("func1...")
}

```

#### 2、指针的函数

- 一个函数它的返回值是一个指针

```go
package main

import "fmt"

func main() {
	f1 := fun1()
	fmt.Println(f1)
	fmt.Println(*f1)
	fmt.Println(f1[0])
}

func fun1() *[4]int {
	arr := [4]int{2, 3, 4, 5}
	return &arr
}

```

### 四、指针参数

```go
package main

import "fmt"

func main() {

	a := 10
	fun1(&a)
	fmt.Println(a)

}

func fun1(p *int) {
	fmt.Println(*p)
	*p = 200
	fmt.Println("函数修改过的值：", *p)
}

```

---

## 复合类型-struct

- 结构体属于值类型数据

### 一、初识结构体

```go
package main

import "fmt"

type Person struct {
	name    string
	age     int
	sex     string
	address string
}

func main() {
	// 方法一
	var p1 Person
	p1.name = "李雷"
	p1.age = 20
	p1.sex = "男"
	p1.address = "北京市昌平区"
	fmt.Println(p1)

	// 方法二
	p2 := Person{}
	p2.name = "韩梅梅"
	p2.age = 18
	p2.sex = "女"
	p2.address = "北京市通州区"
	fmt.Println(p2)

	//方法三
	p3 := Person{name: "Alice", age: 18, sex: "女", address: "北京市朝阳区"}
	fmt.Println(p3)
}
```

### 二、结构体指针

- new，用于创建任意类型的指针

```go
package main

import (
	"fmt"
)

type Person struct {
	name    string
	age     int
	sex     string
	address string
}

func main() {

	p1 := new(Person)
	fmt.Printf("%T\n", p1)
	p1.name = "李雷"
	p1.age = 18
	p1.sex = "男"
	p1.address = "北京市通州区"
	fmt.Println(p1)
}

```

### 三、结构体匿名字段

#### 1、匿名结构体

```go
package main

import "fmt"

func main() {
	s1 := struct {
		name string
		age  int
	}{"李雷", 18}
	fmt.Println(s1.name, s1.age)
}

```

#### 2、匿名字段

```go
package main

import "fmt"

func main() {
	w1 := Worker{
		string: "李雷",
		int:    18,
	}
	fmt.Println(w1.string, w1.int)
}

type Worker struct {
	string
	int
}

```

### 四、结构体嵌套

```go
package main

import "fmt"

type Book struct {
	bookName string
	price    float64
}

type Student struct {
	name string
	age  int
	// 传递结构体指针
	book *Book
}

func main() {
	b1 := Book{
		bookName: "西游记",
		price:    28.7,
	}

	s1 := Student{
		name: "李雷",
		age:  18,
		book: &b1,
	}
	fmt.Println(s1.name)
	fmt.Println(s1.age)
	fmt.Println(s1.book.bookName)
	fmt.Println(s1.book.price)
}

```

### 五、面向对象

#### 1、显示继承

```go
package main

import "fmt"

//定义父类
type Person struct {
	name string
	age  int
}

//定义子类
type Student struct {
	//继承父类结构
	Person
	school string
}

func main() {
	s1 := Student{
		Person: Person{
			name: "李雷",
			age:  18,
		},
		school: "五道口职业技术学院",
	}
	fmt.Println(s1)
}

```

#### 2、隐式继承

```go
package main

import "fmt"

//定义父类
type Person struct {
	name string
	age  int
}

//定义子类
type Student struct {
	//继承父类结构
	Person
	school string
}

func main() {
	var s1 Student
	s1.name = "李雷"
	s1.age = 18
	s1.school = "五道口职业技术学院"
	fmt.Println(s1)
}

```

#### 3、方法

```go
package main

import "fmt"

type Worker struct {
	name string
	age  int
	sex  string
}

func (w Worker) work() {
	fmt.Println(w.name, "在工作...")
}

func (w *Worker) rest() {
	fmt.Println(w.name, "工人在休息...")
}
func main() {
	w1 := Worker{name: "李雷", age: 18, sex: "name"}
	w1.work()
	w1.rest()
}

```

#### 4、方法继承

```go
package main

import "fmt"

//定义父类
type Person struct {
	name string
	age  int
}

//定义子类
type Student struct {
	Person
	school string
}

//定义父类方法
func (p Person) eat() {
	fmt.Println(p.name, "正在吃东西...")
}

//重写父类方法
func (s Student) eat() {
	fmt.Println(s.name, "正在吃面包...")
}

//新增子类方法
func (s Student) study() {
	fmt.Println(s.name, "正在学习")
}

func main() {
	var s1 Student
	s1.name = "李雷"
	s1.age = 18
	s1.school = "五道口职业技术学院"
	fmt.Println(s1.name)
	fmt.Println(s1.age)
	fmt.Println(s1.school)
	s1.eat()
	s1.study()

}

```

---

## 复合类型-interface

- 接口是一组方法签名
- 当某个类型为接口中的所有方法提供了方法的实现，它被称为实现接口
- go语言中，接口和类型的实现关系，是非侵入式
- 当需要接口类型的对象时，可以使用任意实现类对象代替
- 接口对象不能访问实现类中的属性

### 一、接口初识

```go
package main

import "fmt"

// 定义接口
type USB interface {
	start()
	end()
}

type Mouse struct {
	name string
}

type FlashDisk struct {
	name string
}

//Mouse实现接口全部方法
func (m Mouse) start() {
	fmt.Println(m.name, "鼠标，开始工作")
}

func (m Mouse) end() {
	fmt.Println(m.name, "鼠标，结束工作")
}

//FlashDisk实现接口全部方法
func (d FlashDisk) start() {
	fmt.Println(d.name, "U盘，开始工作")
}

func (d FlashDisk) end() {
	fmt.Println(d.name, "U盘，结束工作")
}

//定义测试方法
func testInterface(usb USB) {
	usb.start()
	usb.end()
}

func main() {
	m1 := Mouse{name: "罗技G502"}
	fmt.Println(m1.name)

	f1 := FlashDisk{name: "金士顿128GB"}
	fmt.Println(f1.name)

	testInterface(m1)
	testInterface(f1)

	var usb USB
	usb = m1
	usb.start()
	usb.end()
}

```

### 二、接口的类型

- 多态
    - 一个事务的多种形态
    - 一个接口的实现，1、看成实现本身的类型，能够访问实现类中的属性和方法。2、看成是对应的接口类型，那就只能够访问接口中的方法

- 接口的用法
    - 一个函数如果接受接口类型作为参数，那么实际上可以传入该接口的任意实现类型对象作为参数
    - 定义一个类型为接口类型，实际上可以复制为任意实现类的对象

### 三、空接口

```go
package main

import "fmt"

type A interface {
}

type Cat struct {
	color string
}

type Person struct {
	name string
	age  int
}

// 接口A为空接口，代表任意类型
func test1(a A) {
	fmt.Println(a)
}

func test2(a interface{}) {
	fmt.Println("---->", a)
}

func test3(s []interface{}) {
	for i := 0; i < len(s); i++ {
		fmt.Printf("第%d个数据是%v\n", i+1, s[i])
	}
}

func main() {
	var a1 A = Cat{color: "花猫"}
	var a2 A = Person{name: "李雷", age: 18}
	var a3 A = "Hello"
	var a4 A = 100
	fmt.Println(a1)
	fmt.Println(a2)
	fmt.Println(a3)
	fmt.Println(a4)

	test1(a1)
	test1(a2)
	test1(a3)
	test1(a4)

	test2(a1)
	test2(a2)
	test2(a3)
	test2(a4)

	m1 := make(map[string]interface{})
	m1["name"] = "李小花"
	m1["age"] = 18
	m1["sex"] = "女"

	s1 := make([]interface{}, 0, 10)
	s1 = append(s1, a1, a2, a3, a4)
	fmt.Println(s1)

	test3(s1)

}

```

### 四、接口嵌套

```go
package main

import "fmt"

type A interface {
	test1()
}

type B interface {
	test2()
}

type C interface {
	A
	B
	test3()
}

// 如果想实现接口C，那不止要实现接口C的方法，还要实现接口A，B中的方法
type Cat struct {
}

func (c Cat) test1() {
	fmt.Println("test1...")
}

func (c Cat) test2() {
	fmt.Println("test2...")
}

func (c Cat) test3() {
	fmt.Println("test3...")
}

func main() {
	var c Cat = Cat{}
	c.test1()
	c.test2()
	c.test3()

	var a A = c
	a.test1()

	var b B = c
	b.test2()

}

```

### 五、接口断言

- 方式一
    - instance := 接口对象.(实际类型) ，会panic()
    - instance,ok := 接口对象.(实际类型)
- 方式二 switch instance := 接口对象.(type){ case 实际类型1： case 实际类型2： }

```go
package main

import (
	"fmt"
	"math"
)

type Shape interface {
	perimeter() float64
	area() float64
}

type Trilateral struct {
	a, b, c float64
}

func (t Trilateral) perimeter() float64 {
	return t.a + t.b + t.c
}

func (t Trilateral) area() float64 {
	p := t.perimeter() / 2
	S := math.Sqrt(p * (p - t.a) * (p - t.b) * (p - t.c))
	return S
}

type Circle struct {
	radius float64
}

func (c Circle) perimeter() float64 {
	return 2 * math.Pi * c.radius
}

func (c Circle) area() float64 {
	return math.Pi * math.Pow(c.radius, 2)
}

func main() {

	// 定义三角形对象t1
	var t1 Trilateral
	t1.a = 3
	t1.b = 4
	t1.c = 5
	fmt.Println(t1.area())
	fmt.Println(t1.perimeter())

	//定义圆形对象c1
	var c1 Circle
	c1.radius = 3
	fmt.Println(c1.perimeter())
	fmt.Println(c1.area())

	//定义接口对象s1
	var s1 Shape
	s1 = t1
	fmt.Println(s1.perimeter())
	fmt.Println(s1.area())

	//定义接口对象s2
	var s2 Shape
	s2 = c1
	fmt.Println(s2.perimeter())
	fmt.Println(s2.area())

	testShape(t1)
	testShape(c1)
	testShape(s1)

	getType(t1)
	getType(c1)
	getType(s1)

	var t2 *Trilateral = &Trilateral{3, 4, 2}
	fmt.Printf("ins:%T,%p,%p\n", t2, &t2, t2)
	getType(t2)

	getType2(t1)
	getType2(c1)
	getType2(t2)
}

// 使用if语句进行接口类型判断，进行接口断言
func getType(s Shape) {
	if instance, ok := s.(Trilateral); ok {
		fmt.Println("是三角形，三边是：", instance.a, instance.b, instance.c)
	} else if instance, ok := s.(Circle); ok {
		fmt.Println("是圆形，半径是：", instance.radius)
	} else if instance, ok := s.(*Trilateral); ok {
		fmt.Printf("ins:%T,%p,%p\n", instance, &instance, instance)
		fmt.Printf("ins:%T,%p,%p\n", s, &s, s)
	} else {
		fmt.Println("我也不知道")
	}
}

// 使用switch语句进行接口类型判断，进行接口断言
func getType2(s Shape) {
	switch instance := s.(type) {
	case Trilateral:
		fmt.Println("是三角形，三边是：", instance.a, instance.b, instance.c)
	case Circle:
		fmt.Println("是圆形，半径是：", instance.radius)
	case *Trilateral:
		fmt.Println("是三角形，三边是：", instance.a, instance.b, instance.c)
	}
}

//定义测试函数，参数为接口对象
func testShape(s Shape) {
	fmt.Printf("周长:%.2f,面积：%.2f\n", s.perimeter(), s.area())
}

```

### 六、type

#### 1、定义新类型

```go
package main

import "fmt"

type myInt int
type myString string

func main() {
	var i1 myInt
	i1 = 200

	var name myString
	name = "李雷"

	fmt.Printf("%T\n", i1)
	fmt.Printf("%T\n", name)
}

```

#### 2、定义函数类型

```go
package main

import (
	"fmt"
	"strconv"
)

type myFunc func(int, int) string

func foo() myFunc {
	f := func(a, b int) string {
		s := strconv.Itoa(a) + strconv.Itoa(b)
		return s
	}
	return f
}

func main() {
	r := foo()
	fmt.Println(r(10, 2))
}

```

#### 3、别名

```go
package main

import "fmt"

type myInt = int

func main() {
	var i1 myInt
	i1 = 100
	fmt.Printf("%T\n", i1)
}

```

非本地类型不能定义的方法

```go
package main

import (
	"fmt"
	"time"
)

//非本地类型不能定义的方法
type myDuration time.Duration

func (d myDuration) ShowTime() {
	fmt.Println(time.Now())
}

func main() {
	var t1 myDuration
	t1.ShowTime()
}

```

#### 4、嵌套时别名

- 嵌套结构体时，需要显示指定赋值那个结构体的属性值/方法

```go
package main

import "fmt"

type Person struct {
	name string
}

func (p Person) show() {
	fmt.Println("From Person Struct--->", p, p.name)
}

// 定义一个别名
type People = Person

func (p People) show2() {
	fmt.Println("From People Struct--->", p.name)
}

type Student struct {
	Person
	People
}

func main() {
	var p Student
	p.Person.name = "李雷"
	p.Person.show()
	p.People.name = "韩梅梅"
	p.People.show2()
}

```

---

## 错误与异常

### 一、error的使用

```go
package main

import (
	"fmt"
	"log"
	"os"
)

func main() {
	f, err := os.Open("test.txt")
	if err != nil {
		fmt.Println(err)
		log.Fatal(err)
		return
	}
	fmt.Println(f.Name(), "打开文件成功！")
}

```

### 二、创建error对象

- error是一个接口数据类型
- errors中的New方法，可以创建error对象

```go
package main

import (
	"errors"
	"fmt"
)

func main() {
	err1 := errors.New("自定义的错误")
	fmt.Println(err1)

	err2 := fmt.Errorf("错误信息码：%d", 100)
	fmt.Println(err2)

	err3 := checkAge(-30)
	if err3 != nil {
		fmt.Println(err3)
		return
	}

}

//测试函数
func checkAge(age int) error {
	if age < 0 {
		//return errors.New("年龄不合法")
		return fmt.Errorf("给定的年龄数值%d,不合法", age)
	}

	fmt.Println("年龄是：", age)
	return nil
}

```
### 三、错误的获取/表示

- 通过接口断言，转为实现类，调用实现类的属性

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	f, err := os.Open("test1.txt")
	if err != nil {
		fmt.Println(err)
		//log.Fatal(err)
		if ins,ok := err.(*os.PathError);ok {
			fmt.Println(ins.Op)
			fmt.Println(ins.Path)
			fmt.Println(ins.Err)
		}
		return
	}
	fmt.Println(f.Name(), "打开文件成功！")
}

```

- 通过接口断言，转为实现类，调用实现类的方法

```go
package main

import (
	"fmt"
	"net"
)

func main() {
	add, err := net.LookupHost("www.google.com")
	if err != nil {
		fmt.Println(err)
		if ins, ok := err.(*net.DNSError); ok {
			if ins.IsTimeout {
				fmt.Println("访问超时")
			} else if ins.IsNotFound {
				fmt.Println("没有找到资源")
			}
		}
		return
	}
	fmt.Println(add)
}

```

- 直接比较错误类型

```go
package main

import (
	"fmt"
	"path/filepath"
)

func main() {
	fs, err := filepath.Glob("[")
	if err != nil && err == filepath.ErrBadPattern {
		fmt.Println(err)
		return
	}
	fmt.Println(fs)
}

```

### 四、自定义错误


```go
package main

import (
	"fmt"
	"math"
)

func main() {
	r := -3.0
	c1, err := circleArea(r)
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(c1)
}

// 自定义错误
type areaError struct {
	msg    string
	radius float64
}

// 实现Error方法
func (e *areaError) Error() string {
	return fmt.Sprintf("error:半径，%2f,%s", e.radius, e.msg)
}

func circleArea(radius float64) (float64, error) {
	if radius < 0 {
		return 0, &areaError{radius: radius, msg: "半径是非法的"}
	}
	return math.Pi * radius * radius, nil
}

```


```go
package main

import "fmt"

func main() {
	length, width := -100.12, 9.1
	s, err := rectArea(length, width)
	if err != nil {
		fmt.Println(err)
		if ins, ok := err.(*areaError); ok {
			if ins.lengthNegative() {
				fmt.Printf("error: %.2f\n", ins.length)
			}
			if ins.widthNegative() {
				fmt.Printf("error: %.2f\n", ins.width)
			}
		}
		return
	}
	fmt.Println(s)

}

type areaError struct {
	msg           string
	length, width float64
}

func (e *areaError) Error() string {
	return e.msg
}

func (e *areaError) lengthNegative() bool {
	return e.length < 0
}

func (e *areaError) widthNegative() bool {
	return e.width < 0
}

// 定义计算矩形面积的函数
func rectArea(length, width float64) (float64, error) {
	msg := ""
	if length < 0 {
		msg = "长度小于零"
	}
	if width < 0 {
		if msg == "" {
			msg = "宽度小于零"
		} else {
			msg += ",宽度小于零"
		}
	}

	if msg != "" {
		return 0, &areaError{msg, length, width}
	}
	return width * length, nil
}

```

### 五、异常

```go
package main

import "fmt"

func main() {
	defer func() {
		if msg := recover(); msg != nil{
			fmt.Println(msg,"程序继续")
		}
	}()
	funA()
	defer myPrint("defer main A")
	funB()
	defer myPrint("defer main B")

	fmt.Println("main over")
}

func myPrint(s string)  {
	fmt.Println(s)
}
func funA()  {
	fmt.Println("函数A")
}

func funB()  {
	defer func() {
		if msg := recover(); msg != nil{
			fmt.Println(msg,"程序继续")
		}
	}()
	fmt.Println("函数B")
	defer myPrint("defer 函数B Start")
	for i := 0; i < 10; i++ {
		fmt.Println("i:",i)
		if i == 5 {
			panic("...")
		}
	}
	defer myPrint("defer 函数B End")
}

```

