## 版本管理的演变

集中式VCS

- 有集中的版本管理服务器
- 具备文件版本管理和分支管理能力
- 继承效率有明显地提高
- 客户端必须时刻和服务器相连

分布式VCS

- 服务端和客户端都有完整的版本库
- 脱离服务端，客户端照样可以管理版本
- 查看历史和版本比较等多数操作，都不需要访问服务器，比集中式VCS更能提高版本管理效率

---
## Git特点

- 最优的存储能力
- 非凡的性能
- 开源
- 很容易做备份
- 支持离线操作
- 很容易定制工作流程

---

## Git的安装

>官方网站：https://git-scm.com/downloads

---

## Git配置

```shell
git config --global user.name 'your_name'
git config --global user.email 'your_email@domin.com'
```
- `--local`
- `--global`
- `--system`

显示配置

```shell
git config --list --local
git config --list --global
git config --list --system
```
---

## 创建Git仓库

### 导入已有的项目

```shell
cd 项目文件夹
git init
```

### 创建新的项目

```shell
cd 某个文件夹
git init your_project
cd your_project
```

## 提交

```shell
touch README.md
git add README.md
git commit -m "Add readme"
```

## 查看日志

```shell
git log
```