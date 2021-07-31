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
	rand.Seed(time.Now().UnixNano()*7)
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
  var arr1 [4] int
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
	var arr1 [4] int
	arr1[0] = 1
	arr1[1] = 2
	arr1[2] = 3
	fmt.Printf("长度为：%d\n",len(arr1))
	fmt.Printf("容量为：%d\n",cap(arr1))
}
```

- 数组初始化赋值

```go
package main

import "fmt"

func main() {
	var a = [4]int{1,2,4,5}
	fmt.Println(a)
}

```

指定下标位置初始值

```go
package main

import "fmt"

func main() {
	var a = [5]int{1:3,3:20}
	fmt.Println(a)
}
```

- 不定长赋值

```go
package main

import "fmt"

func main() {
	var a = [...]int{3,20,99,222}
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
	arr1 := [...]int{2,44,5,54}
	fmt.Println(arr1[2])
}
```

#### 方法2-for...i

```go
package main

import "fmt"

func main() {
	arr1 := [...]int{2,44,5,54}
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
	
	s2 := []int{1,2,3,5}
	fmt.Println(s2)
}

```

#### make

- 使用make创建slice

```go
package main

import "fmt"

func main() {
	s1 := make([]int,3,10)
	fmt.Println(s1)
}

```

#### append

- 使用append向slice中添加元素

```go
package main

import "fmt"

func main() {
	s1 := make([]int,0,5)
	s1 = append(s1,1,2)
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
	fmt.Printf("s1:%v,len:%d,cap:%d\n",s1,len(s1),cap(s1))
	s2 := a[4:]
	fmt.Printf("s1:%v,len:%d,cap:%d\n",s2,len(s2),cap(s2))
	s3 := a[3:7]
	fmt.Printf("s1:%v,len:%d,cap:%d\n",s3,len(s3),cap(s3))
	
}
```

### 四、深copy与浅copy

#### for循环实现深copy

```go
package main

import "fmt"

func main() {
	s1 := []int{2,3,4,5,6}
	s2 := make([]int,0,10)
	for _, i := range s1 {
		s2 = append(s2,i)
	}
	fmt.Printf("%p\n",s1)
	fmt.Printf("%p\n",s2)
}

```

#### copy

```go
package main

import "fmt"

func main() {
	s1 := []int{12,22,33,44,55}
	s2 := make([]int,len(s1))
	copy(s2,s1)
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
	var m1 map[int]string // 只是声明，无法直接使用
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

	delete(m1,"India")
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
		fmt.Println(i,s[i])
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

	users := make([]map[string]string,0)
	users = append(users,user1)
	users = append(users,user2)
	users = append(users,user3)

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

	s2 := []byte{72,101,108,108,111,32,228,184,173,229,155,189,33}
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

	fmt.Println(strings.Count(s1,"l"))

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

  fmt.Println(strings.Index(s1,"o"))
  fmt.Println(strings.LastIndex(s1,"o"))
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

	fmt.Println(strings.IndexAny(s1,"oa"))
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
	fmt.Println(strings.Split(s1,"-"))
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
	s1 := strings.Repeat("Ah ",5)
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
	fmt.Println(strings.Replace(s1,"o","*",-1))
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

---
## 复合类型-pointer

---
## 复合类型-struct

---
## 复合类型-interface

---
## 复合类型-channel
