## 包管理

### 一、main包

- 入口main函数所在的包

### 二、定义包

```go
package timeutils

import (
	"fmt"
	"time"
)

func PrintTime() {
	fmt.Println(time.Now())
}
```

### 三、包的导入

```go
package main

import (
	"fmt"
	"uncordon.com/person"
	"uncordon.com/utils"
	// 对包使用别名
	tools "uncordon.com/utils/timeutils"
)

func main() {
	utils.Count()
	tools.PrintTime()
	p1 := person.Person{Name: "李雷", Age: 18, Sex: "男"}
	fmt.Println(p1)
}

```

### 四、init()包

- init()是保留函数，用于初始化信息
- 不能有参数，返回值，由go程序自动调用
- init()可以定义多个
- init()先执行，再执行main函数
- 使用“_”引入包，隐式执行init()

---

## 常见包

### time包

```go
package main

import (
	"fmt"
	"math/rand"
	"time"
)

func main() {
	// 获取当前时间
	t1 := time.Now()
	fmt.Println(t1)

	// 获取指定时间
	t2 := time.Date(2008, 7, 15, 16, 30, 28, 0, time.Local)
	fmt.Println(t2)

	//	时间转换，time对象转换为string对象
	s1 := t1.Format("2006-01-02 15:04:05.0000 MST")
	fmt.Println(s1)

	//	时间转换，string对象转换为time对象
	s2 := "1999年10月1日 06:10:59.0001 CST"
	t3, err := time.Parse("2006年1月2日 15:04:05.0000 MST", s2)
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(t3)

	// 获取年，月，日
	fmt.Println(t1.Date())
	// 获取时，分，秒
	fmt.Println(t1.Clock())

	// 单独获取
	fmt.Println("年", t1.Year())
	fmt.Println("月", t1.Month())
	fmt.Println("日", t1.Day())
	fmt.Println(t1.Hour())
	fmt.Println(t1.Minute())
	fmt.Println(t1.Second())

	fmt.Println(t1.Weekday())

	//	获取时间戳
	fmt.Println(t1.Unix())
	fmt.Println(t1.UnixNano())

	//	时间计算
	t5 := t1.Add(time.Minute)
	fmt.Println(t5)
	t5 = t5.Add(24 * time.Hour)
	fmt.Println(t5)
	t6 := t1.AddDate(1, 0, 0)
	fmt.Println(t6)

	//	计算时间差值
	d1 := t5.Sub(t1)
	fmt.Println(d1)

	//	睡眠
	rand.Seed(time.Now().UnixNano())
	randNum := rand.Intn(10) + 1
	fmt.Println(randNum)
	time.Sleep(time.Duration(randNum) * time.Second)

	fmt.Println("main over")
}

```

### os包-文件操作

#### os

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	fileInfo, err := os.Stat("D:\\code\\go\\test.txt")
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(fileInfo)
	fmt.Println("文件名", fileInfo.Name())
	fmt.Println("文件大小", fileInfo.Size())
	fmt.Println("是否为目录", fileInfo.IsDir())
	fmt.Println("修改时间", fileInfo.ModTime())
	fmt.Println("权限", fileInfo.Mode())
}

```

#### 文件路径

```go
package main

import (
	"fmt"
	"os"
	"path/filepath"
)

func main() {

	f1 := "test.txt"
	f2 := "D:\\code\\go\\src\\uncordon.com\\test.txt"
	fmt.Println(filepath.IsAbs(f1))
	fmt.Println(filepath.IsAbs(f2))

	// 获取绝对路径
	fmt.Println(filepath.Abs(f1))
	fmt.Println(filepath.Abs(f2))
```

#### 创建目录

- os.Mkdir：创建不存在的目录
- os.MkdirAll：级联创建目录

```go
package main

import (
	"fmt"
	"os"
)

func main() {

	//	创建目录
	err := os.Mkdir("D:\\code\\go\\src\\uncordon.com\\a", os.ModePerm)
	if err != nil {
		if _, ok := err.(*os.PathError); ok {
			err = os.MkdirAll("D:\\code\\go\\src\\uncordon.com\\a\\cc\\ee", os.ModePerm)
			if err != nil {
				fmt.Println(err)
				return
			}
		}
	}
}
```

#### 创建文件

- os.Creat：创建空文件

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	f, err := os.Create("D:\\code\\go\\src\\uncordon.com\\a\\ab.txt")
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(f)

	f3, err := os.Create("abc.txt")
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(f3)
}
```

#### 打开文件

- os.Open：以只读模式打开文件
- os.OpenFile：以指定的模式和权限打开文件

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	//	打开文件
	f3, err := os.Open("abc.txt")
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(f3)
	f4, err := os.OpenFile("abc.txt", os.O_RDWR|os.O_WRONLY, os.ModePerm)
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(f4)
}
```

#### 关闭文件

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	f3, err := os.OpenFile("abc.txt", os.O_RDWR|os.O_WRONLY, os.ModePerm)
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(f3)
	f3.Close()
}
```

#### 删除文件/目录

- os.Remove：删除文件/空目录
- os.RemoveAll：删除文件/目录

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	err := os.Remove("D:\\code\\go\\src\\uncordon.com\\a\\ab.txt")
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println("文件删除成功")
	err = os.Remove("D:\\code\\go\\src\\uncordon.com\\a\\cc")
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println("目录删除成功")

	err = os.RemoveAll("D:\\code\\go\\src\\uncordon.com\\a\\cc")
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println("目录删除成功")
}
```

### io包

#### io-读

```go
package main

import (
	"fmt"
	"io"
	"os"
)

func main() {
	fileName := "D:\\code\\go\\src\\uncordon.com\\abc.txt"

	file, err := os.Open(fileName)
	if err != nil {
		fmt.Println(err)
	}
	defer file.Close()

	bs := make([]byte, 4, 4)

	n := -1
	for true {
		n, err = file.Read(bs)
		if n == 0 || err == io.EOF {
			break
		}
		fmt.Println(string(bs[:n]))
	}
	/*	n, err := file.Read(bs)
		fmt.Println(err)
		fmt.Println(n)
		fmt.Println(bs)
		fmt.Println(string(bs))
		n, err = file.Read(bs)
		fmt.Println(err)
		fmt.Println(n)
		fmt.Println(bs)
		fmt.Println(string(bs))
		n, err = file.Read(bs)
		fmt.Println(err)
		fmt.Println(n)
		fmt.Println(bs)
		fmt.Println(string(bs))
		n, err = file.Read(bs)
		fmt.Println(err)
		fmt.Println(n)
		fmt.Println(bs)
		fmt.Println(string(bs))*/
}

```

#### io-写

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	fileName := "D:\\code\\go\\src\\uncordon.com\\hello.txt"

	file, err := os.OpenFile(fileName, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	HandleErr(err)
	defer file.Close()

	//bs := []byte{65, 66, 67, 68, 69, 70}
	bs := []byte{97, 98, 99, 100}
	//n,err := file.Write(bs)
	n, err := file.Write(bs[:2])
	HandleErr(err)
	fmt.Println(n)
	file.WriteString("\n")

	n, err = file.WriteString("HelloWorld")
	HandleErr(err)
	fmt.Println(n)
	file.WriteString("\n")
	n, err = file.Write([]byte("today"))
	HandleErr(err)
	fmt.Println(n)
	file.WriteString("\n")

}

func HandleErr(err error) {
	if err != nil {
		fmt.Println(err)
	}
}

```

#### 复制文件

- 原始IO操作

```go
package main

import (
	"fmt"
	"io"
	"os"
	"strings"
)

func main() {
	srcFile := "E:\\Downloads\\谍影重重5.HD1280超清韩版英语中英双字.mp4"
	fs := strings.Split(srcFile, "\\")
	fileName := fs[len(fs)-1]

	_, err := CopyFileCustom(srcFile, fileName)
	if err != nil {
		fmt.Println(err)
	}
}

func CopyFileCustom(srcFile, destFile string) (int64, error) {
	file1, err := os.Open(srcFile)
	if err != nil {
		return 0, err
	}
	file2, err := os.OpenFile(destFile, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0666)
	if err != nil {
		return 0, err
	}
	defer file1.Close()
	defer file2.Close()
	buf := make([]byte, 8*1024)
	n := -1
	var total int64 = 0
	for true {
		n, err = file1.Read(buf)
		if n == 0 || err == io.EOF {
			fmt.Printf("%s复制完毕\n", destFile)
			break
		} else if err != nil {
			fmt.Printf("%s复制错误\n", srcFile)
			return 0, err
		}
		total += int64(n)
		fmt.Printf("已复制：%dMB\n", total/1024/1024)
		_, err = file2.Write(buf[:n])
		if err != nil {
			return 0, err
		}
	}
	return total, nil

}

```

- io.Copy

```go
package main

import (
	"fmt"
	"io"
	"os"
	"strings"
)

func main() {
	srcFile := "E:\\Downloads\\谍影重重5.HD1280超清韩版英语中英双字.mp4"
	fs := strings.Split(srcFile, "\\")
	fileName := fs[len(fs)-1]

	total, err := CopyFileIO(srcFile, fileName)
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(total)
}

func CopyFileIO(srcFile, destFile string) (int64, error) {
	file1, err := os.Open(srcFile)
	if err != nil {
		return 0, err
	}
	file2, err := os.OpenFile(destFile, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0666)
	if err != nil {
		return 0, err
	}
	defer file1.Close()
	defer file2.Close()

	return io.Copy(file2, file1)
}

```

- ioutil

```go
package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strings"
)

func main() {
	srcFile := "E:\\Downloads\\谍影重重5.HD1280超清韩版英语中英双字.mp4"
	fs := strings.Split(srcFile, "\\")
	fileName := fs[len(fs)-1]

	total, err := CopyFileIOutil(srcFile, fileName)
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(total)
}

func CopyFileIOutil(srcFile, destFile string) (int, error) {
	bs, err := ioutil.ReadFile(srcFile)
	if err != nil {
		return 0, err
	}
	err = ioutil.WriteFile(destFile, bs, os.ModePerm)
	if err != nil {
		return 0, err
	}
	return len(bs), err
}

```

#### 断点续传

- io.SeekStart：0
- io.SeekCurrent：1
- io.SeekEnd：2

```go
package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"strconv"
	"strings"
)

func main() {
	srcFile := "E:\\Downloads\\谍影重重5.HD1280超清韩版英语中英双字.mp4"
	fs := strings.Split(srcFile, "\\")
	fileName := fs[len(fs)-1]
	fmt.Println(fileName)

	CopyFileAdvance(srcFile, fileName)

}

func CopyFileAdvance(srcFile, destFile string) {

	// 源文件
	file1, err := os.Open(srcFile)
	HandleErr(err)

	//目标文件
	file2, err := os.OpenFile(destFile, os.O_CREATE|os.O_RDWR|os.O_TRUNC, os.ModePerm)
	HandleErr(err)

	// 临时文件
	tmpFile := destFile + ".tmp"
	fileTmp, err := os.OpenFile(tmpFile, os.O_CREATE|os.O_RDWR, os.ModePerm)
	HandleErr(err)

	defer file1.Close()
	defer file2.Close()

	buf := make([]byte, 8*1024)

	// 获取文件寻址位置
	fileTmp.Seek(0, io.SeekStart)
	tmpN, _ := fileTmp.Read(buf)
	count, _ := strconv.ParseInt(string(buf[:tmpN]), 10, 64)
	fmt.Println(count)

	// 设定文件寻址读取位置
	file1.Seek(count, io.SeekStart)
	file2.Seek(count, io.SeekStart)

	dataBuf := make([]byte, 8*1024)
	readN := -1
	writeN := -1
	total := count

	// 开始复制文件
	for {
		readN, err = file1.Read(dataBuf)
		if err == io.EOF || readN == 0 {
			fmt.Println("复制完毕")
			fileTmp.Close()
			os.Remove(tmpFile)
			break
		}
		writeN, err = file2.Write(dataBuf[:readN])
		total += int64(writeN)
		fmt.Printf("文件已经复制:%dMB\n", total/1024/1024)
		fileTmp.Seek(0, io.SeekStart)
		fileTmp.WriteString(strconv.Itoa(int(total)))
	}
}

func HandleErr(err error) {
	if err != nil {
		fmt.Println(err)
		log.Fatal(err)
	}
}

```

### bufio包

#### NewReader

```go
package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
)

func main() {
	fileName := "hello.txt"

	file, err := os.Open(fileName)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	f := bufio.NewReader(file)

	bf := make([]byte, 128)
	n, err := f.Read(bf)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(n)
	fmt.Println(string(bf[:n]))
}

```

#### Readline

```go
package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
)

func main() {
	fileName := "hello.txt"

	file, err := os.Open(fileName)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	f := bufio.NewReader(file)

	dataBytes, flag, err := f.ReadLine()
	fmt.Println(dataBytes)
	fmt.Println(string(dataBytes))
	fmt.Println(flag)
	fmt.Println(err)
}
```

#### ReadString

```go
package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
)

func main() {
	fileName := "hello.txt"

	file, err := os.Open(fileName)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	f := bufio.NewReader(file)

	for {
		dataString, err := f.ReadString('\n')
		if err == io.EOF {
			fmt.Println("打印完毕")
			break
		}
		fmt.Println(dataString)
	}
}

```

#### ReadBytes

```go
package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
)

func main() {
	fileName := "hello.txt"

	file, err := os.Open(fileName)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	f := bufio.NewReader(file)

	for {
		dataByte, err := f.ReadBytes('\n')
		if err == io.EOF {
			fmt.Println("打印完毕")
			break
		}
		fmt.Println(string(dataByte))

	}
}

```

#### scanner

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	b := bufio.NewReader(os.Stdin)
	s, _ := b.ReadString('\n')
	fmt.Println(s)
}

```

#### writer

```go
package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
)

func main() {
	fileName := "cccc.txt"

	file, err := os.OpenFile(fileName, os.O_CREATE|os.O_RDWR, os.ModePerm)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	f := bufio.NewWriter(file)
	n, err := f.WriteString("ABC")
	if err != nil {
		fmt.Println(err)
	}
	f.Flush()
	fmt.Println(n)
}

```

---

### ioutil包

- 1.6x以后的版本，将由io和os包提供相关的功能进行替代

```go
package main

import (
	"fmt"
	"io/ioutil"
)

func main() {
	fileName := "hello.txt"

	dataByte, err := ioutil.ReadFile(fileName)
	fmt.Println(err)
	fmt.Println(string(dataByte))
}

```

```go
package main

import (
	"fmt"
	"io/ioutil"
	"os"
)

func main() {
	fileName := "abc.txt"
	dataString := "Hello World"
	err := ioutil.WriteFile(fileName, []byte(dataString), os.ModePerm)
	if err != nil {
		fmt.Println(err)
	}
}

```

```go
package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func main() {
	dataString := "Hello World"
	dataByte, err := ioutil.ReadAll(strings.NewReader(dataString))
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(string(dataByte))

}

```

```go
package main

import (
	"fmt"
	"io/ioutil"
	"os"
)

func main() {
	tmpDir, err := ioutil.TempDir(".", "test")
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(tmpDir)
	defer os.RemoveAll(tmpDir)
	tmpFile, err := ioutil.TempFile(tmpDir, "Test*.txt")
	if err != nil {
		fmt.Println(err)
		return
	}
	defer os.RemoveAll(tmpFile.Name())
	fmt.Println(tmpFile.Name())

}

```

---

## 并发性

- 多任务
- 并发性（Concurrency）：是指在一个系统中，拥有多个计算，这些计算有同时执行的特性，而且他们之间有着潜在的交互。
- 并行性（Parallelizability）：并行性是指计算机系统具有可以同时进行运算或操作的特性，在同一时间完成两种或两种以上工作。
- 进程
- 线程
- 协程

---

## Goroutine

> Go语言中使用goroutine非常简单，只需要在调用函数的时候在前面加上go关键字，就可以为一个函数创建一个goroutine。

### 启动一个Goroutine

```go
func hello() {
fmt.Println("Hello Goroutine!")
}

func main() {
go hello() // 启动另外一个goroutine去执行hello函数
time.Sleep(time.Second)
fmt.Println("main goroutine done!")
}
```

### 启动多个Goroutine

> 使用sync.WaitGroup控制goroutine与主线程的同步等待关系

- `Add(N)`：启动N个同步等待goroutine
- `Done()`：完成一个goroutine
- `Wait()`：等待所有的goroutine执行结束

```go
var wg sync.WaitGroup

func hello(i int) {
defer wg.Done() // goroutine结束就登记-1
fmt.Println("Hello Goroutine!", i)
}
func main() {

for i := 0; i < 10; i++ {
wg.Add(1) // 启动一个goroutine就登记+1
go hello(i)
}
wg.Wait() // 等待所有登记的goroutine都结束
}
```

### 线程数控制

- `GOMAXPROCS`

控制最大并发核心数量。Go1.5版本之后，默认使用全部的CPU逻辑核心数。

```go
runtime.GOMAXPROCS(N)
```

### Go语言中的操作系统线程和goroutine的关系：

- 一个操作系统线程对应用户态多个goroutine。
- go程序可以同时使用多个操作系统线程。
- goroutine和OS线程是多对多的关系，即m:n。

---

## 复合类型-channel

> channel是一种数据类型，属于引用类型。channel是可以让一个goroutine发送特定值到另一个goroutine的通信机制。

Go 语言中的通道（channel）是一种特殊的类型。通道像一个传送带或者队列，总是遵循先入先出（First In First
Out）的规则，保证收发数据的顺序。每一个通道都是一个具体类型的导管，也就是声明channel的时候需要为其指定元素类型。

Go语言的并发模型是CSP（Communicating Sequential Processes），提倡通过通信共享内存而不是通过共享内存而实现通信。

### 创建channel

```go
// 声明一个int类型chan，单位进行初始化
var ch1 chan int
```

使用make进行初始化

```go
make(chan 类型, [缓冲大小])
```

示例：

```go
ch4 := make(chan int)
ch5 := make(chan bool)
ch6 := make(chan []int)
```

### 操作channel

#### 1、发送，将一个值发送到通道中。

```go
ch1 := make(chan int)
ch1 <- 10
```

#### 2、接收，从一个通道中接收值。

```go
ch1 := make(chan int)
ch1 <- 10
x := <- ch1
```

#### 3、关闭

我们通过调用内置的close函数来关闭通道。

```go
close(ch1)
```

- 对一个关闭的通道再发送值就会导致panic。
- 对一个关闭的通道进行接收会一直获取值直到通道为空。
- 对一个关闭的并且没有值的通道执行接收操作会得到对应类型的零值。
- 关闭一个已经关闭的通道会导致panic。

### 无缓冲channel

> 无缓冲的通道又称为阻塞的通道

```go
func main() {
    ch := make(chan int)
    ch <- 10
    fmt.Println("发送成功")
}
```

无缓冲通道，因为没有接收这，会触发死锁错误。

```go
fatal error: all goroutines are asleep - deadlock!
```

可以使用goroutine创建一个接收的线程。

```go
func recev(c chan int) {
    ret := <-c
    fmt.Println("接收成功", ret)
}
	
func main() {
    ch1 := make(chan int)
    go recev(ch1) // 启用goroutine从通道接收值
    ch <- 10
    fmt.Println("发送成功")
}
```

### 有缓冲channel

> 在使用make函数初始化通道的时候为其指定通道的容量。

```go
func main() {
ch := make(chan int, 1) // 创建一个容量为1的有缓冲区通道
ch <- 10
fmt.Println("发送成功")
}
```

使用内置的len函数获取通道内元素的数量，使用cap函数获取通道的容量。

### 优雅获取channel

当向通道中发送完数据时，我们可以通过close函数来关闭通道。使用for range循环获取数据。

```go
func main() {
    ch1 := make(chan int)
    ch2 := make(chan int)
    // 开启goroutine将0~100的数发送到ch1中
    go func () {
        for i := 0; i < 100; i++ {
            ch1 <- i
        }
        close(ch1)
    }()
    // 开启goroutine从ch1中接收值，并将该值的平方发送到ch2中
    go func () {
        for {
            // 通道关闭后再取值ok=false
            if i, ok := <-ch1; !ok {
                break
            } else {
                ch2 <- i * i
            }
        }
        close(ch2)
    }()
    // 在主goroutine中从ch2中接收值打印
    // 通道关闭后会退出for range循环
    for i := range ch2 {
        fmt.Println(i)
    }
}
```

### 单向channel

>限制通道在函数中只能发送或只能接收。

```go
func counter(out chan<- int) {
	for i := 0; i < 100; i++ {
		out <- i
	}
	close(out)
}

func squarer(out chan<- int, in <-chan int) {
	for i := range in {
		out <- i * i
	}
	close(out)
}
func printer(in <-chan int) {
	for i := range in {
		fmt.Println(i)
	}
}

func main() {
	ch1 := make(chan int)
	ch2 := make(chan int)
	go counter(ch1)
	go squarer(ch2, ch1)
	printer(ch2)
}
```

- `chan<- int` 是一个只写单向通道（只能对其写入int类型值），可以对其执行发送操作但是不能执行接收操作；
- `<-chan int` 是一个只读单向通道（只能从其读取int类型值），可以对其执行接收操作但是不能执行发送操作。

### worker pool(goroutine 池)

>指定启动一定数量的goroutine–worker pool模式，控制goroutine的数量，防止goroutine泄漏和暴涨。

```go
func worker(id int, jobs <-chan int, results chan<- int) {
	for j := range jobs {
		fmt.Printf("worker:%d start job:%d\n", id, j)
		time.Sleep(time.Second)
		fmt.Printf("worker:%d end job:%d\n", id, j)
		results <- j * 2
	}
}


func main() {
	jobs := make(chan int, 100)
	results := make(chan int, 100)
	// 开启3个goroutine
	for w := 1; w <= 3; w++ {
		go worker(w, jobs, results)
	}
	// 5个任务
	for j := 1; j <= 5; j++ {
		jobs <- j
	}
	close(jobs)
	// 输出结果
	for a := 1; a <= 5; a++ {
		<-results
	}
}
```

### select多路复用

> Go内置了select关键字，可以同时响应多个通道的操作。
> select的使用类似于switch语句，它有一系列case分支和一个默认的分支。每个case会对应一个通道的通信（接收或发送）过程。select会一直等待，直到某个case的通信操作完成时，就会执行case分支对应的语句。

```go
func main() {
	ch := make(chan int, 1)
	for i := 0; i < 10; i++ {
		select {
		case x := <-ch:
			fmt.Println(x)
		case ch <- i:
		}
	}
}
```

- 可处理一个或多个channel的发送/接收操作。
- 如果多个case同时满足，select会随机选择一个。
- 对于没有case的select{}会一直等待，可用于阻塞main函数。

---

## 并发安全和锁

### sync.Mutex-互斥锁

>互斥锁是一种常用的控制共享资源访问的方法，它能够保证同时只有一个goroutine可以访问共享资源。Go语言中使用sync包的Mutex类型来实现互斥锁。 

```go
var x int64
var wg sync.WaitGroup
var lock sync.Mutex

func add() {
	for i := 0; i < 50000; i++ {
		lock.Lock() // 加锁
		x = x + 1
		lock.Unlock() // 解锁
	}
	wg.Done()
}
func main() {
	wg.Add(2)
	go add()
	go add()
	wg.Wait()
	fmt.Println(x)
}
```

### sync.RWMutex-读写互斥锁

互斥锁是完全互斥的，但是有很多实际的场景下是读多写少的，当我们并发的去读取一个资源不涉及资源修改的时候是没有必要加锁的，这种场景下使用读写锁是更好的一种选择。读写锁在Go语言中使用sync包中的RWMutex类型。

读写锁分为两种：读锁和写锁。当一个goroutine获取读锁之后，其他的goroutine如果是获取读锁会继续获得锁，如果是获取写锁就会等待；当一个goroutine获取写锁之后，其他的goroutine无论是获取读锁还是写锁都会等待。

```go
var (
	x      int64
	wg     sync.WaitGroup
	lock   sync.Mutex
	rwlock sync.RWMutex
)

func write() {
	//lock.Lock() // 加互斥锁
	rwlock.Lock() // 加写锁
	x = x + 1
	time.Sleep(10 * time.Millisecond) // 假设读操作耗时10毫秒
	rwlock.Unlock()                   // 解写锁
	//lock.Unlock() // 解互斥锁
	wg.Done()
}

func read() {
	//lock.Lock() // 加互斥锁
	rwlock.RLock()               // 加读锁
	time.Sleep(time.Millisecond) // 假设读操作耗时1毫秒
	rwlock.RUnlock()             // 解读锁
	//lock.Unlock() // 解互斥锁
	wg.Done()
}

func main() {
	start := time.Now()
	for i := 0; i < 10; i++ {
		wg.Add(1)
		go write()
	}

	for i := 0; i < 10000; i++ {
		wg.Add(1)
		go read()
	}

	wg.Wait()
	end := time.Now()
	fmt.Println(end.Sub(start))
}
```

### sync.WaitGroup-同步锁

```go
var wg sync.WaitGroup

func hello() {
	defer wg.Done()
	fmt.Println("Hello Goroutine!")
}
func main() {
	wg.Add(1)
	go hello() // 启动另外一个goroutine去执行hello函数
	fmt.Println("main goroutine done!")
	wg.Wait()
}
```

### sync.Once-单次锁

