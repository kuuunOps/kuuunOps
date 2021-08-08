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

func PrintTime()  {
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
	fileInfo,err := os.Stat("D:\\code\\go\\test.txt")
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(fileInfo)
	fmt.Println("文件名",fileInfo.Name())
	fmt.Println("文件大小",fileInfo.Size())
	fmt.Println("是否为目录",fileInfo.IsDir())
	fmt.Println("修改时间",fileInfo.ModTime())
	fmt.Println("权限",fileInfo.Mode())
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

func main()  {
	//	打开文件
	f3, err := os.Open("abc.txt")
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(f3)
	f4, err := os.OpenFile("abc.txt",os.O_RDWR|os.O_WRONLY,os.ModePerm)
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

func main()  {
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

func main()  {
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
		n,err = file.Read(bs)
		if n ==0 || err == io.EOF{
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

	file, err := os.OpenFile(fileName,os.O_CREATE|os.O_WRONLY|os.O_APPEND,0666)
	HandleErr(err)
	defer file.Close()

	//bs := []byte{65, 66, 67, 68, 69, 70}
	bs := []byte{97,98,99,100}
	//n,err := file.Write(bs)
	n,err := file.Write(bs[:2])
	HandleErr(err)
	fmt.Println(n)
	file.WriteString("\n")

	n,err = file.WriteString("HelloWorld")
	HandleErr(err)
	fmt.Println(n)
	file.WriteString("\n")
	n,err = file.Write([]byte("today"))
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

	total,err := CopyFileIO(srcFile,fileName)
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

	dataBytes,flag,err :=f.ReadLine()
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
		dataString,err := f.ReadString('\n')
		if err == io.EOF{
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
	s,_ :=b.ReadString('\n')
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

	file, err := os.OpenFile(fileName,os.O_CREATE|os.O_RDWR,os.ModePerm)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	f := bufio.NewWriter(file)
	n,err := f.WriteString("ABC")
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

	dataByte,err := ioutil.ReadFile(fileName)
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
	err :=ioutil.WriteFile(fileName,[]byte(dataString),os.ModePerm)
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

```go
package main

import (
	"fmt"
	"time"
)

func main() {

	//	启动Goroutine
	go printNum()

	for i := 0; i <= 100; i++ {
		fmt.Printf("\t主Goroutine中打印数据：A,%d\n", i)
	}
	time.Sleep(time.Second)
	fmt.Println("Main Over")
}

func printNum() {
	for i := 0; i <= 100; i++ {
		fmt.Printf("子Goroutine中打印数据：%d\n", i)
	}
}

```



## 复合类型-channel