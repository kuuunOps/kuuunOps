# Git

>官网：https://git-scm.com/downloads

## 入门操作

### 1. 下载安装

### 2. 版本目录初始化
```bash
git init
```

### 3. 配置用户信息
```bash
git config --global user.email "xxx@163.com"
git config --global user.name "xxx"
```
### 4. 添加文件
```bash
git add README.md
```

### 5. 添加描述内容
```bash
git commit -m "wrote a readme.md file"
```

### 6. 查看版本库状态
```bash
git status
```

### 7. 对比
```bash
$ git diff
diff --git a/README.md b/README.md
index d8036c1..013b5bc 100644
--- a/README.md
+++ b/README.md
@@ -1,2 +1,2 @@
-Git is a version control system.
+Git is a distributed version control system.
 Git is free software.
\ No newline at end of file
```

### 8. 查看操作

- 历史记录
```bash
$ git log
commit fba83136544cb27fe44bc19f819d2cf7f7bcd443 (HEAD -> master)
Author: xxx <xxx@163.com>
Date:   Fri Jun 2 21:05:25 2017 +0800
    append GPL
commit 0c41475346cf35db11762135809aaba0dc750519
Author: xxx <xxx@163.com>
Date:   Fri Jun 2 21:03:40 2017 +0800
    add distributed
commit 3212aef6da9bc4dc76839cafb32f68ca86515452
Author: xxx <xxx@163.com>
Date:   Fri Jun 2 20:56:53 2017 +0800
    wrote a readme.md file
```

- 简要信息
```bash
$ git log --pretty=oneline
fba83136544cb27fe44bc19f819d2cf7f7bcd443 (HEAD -> master) append GPL
0c41475346cf35db11762135809aaba0dc750519 add distributed
3212aef6da9bc4dc76839cafb32f68ca86515452 wrote a readme.md file
```

### 9. 回退

- 回退上一版本
```bash
git reset --hard HEAD
HEAD is now at 0c41475 add distributed
```

- 回退到指定版本
```bash
git reset --hard 3212aef
HEAD is now at 3212aef wrote a readme.md file
```

- 查看回退记录
```bash
$ git reflog
3212aef (HEAD -> master) HEAD@{0}: reset: moving to 3212aef
0c41475 HEAD@{1}: reset: moving to HEAD^
fba8313 HEAD@{2}: commit: append GPL
0c41475 HEAD@{3}: commit: add distributed
3212aef (HEAD -> master) HEAD@{4}: commit (initial): wrote a readme.md file
```

### 10. 撤销

- 从工作区撤销
```bash
git checkout -- README.md
```

- 从暂存区撤销
```bash
git reset HEAD README.md
Unstaged changes after reset:
M       README.md
```

### 11. 删除文件
```bash
$ git rm test.txt
rm 'test.txt'
```

### 12. 创建秘钥
```bash
ssh-keygen -t rsa -C "xxx@163.com"
```

### 13. 添加远程仓库地址

- https协议
```bash
$ git remote add origin https://github.com/xxx/mygit.git
```

- ssh协议
```bash
$ git remote add origin git@github.com:xxx/mygit.git
```

### 14. 推送
```bash
$ git push -u origin master
Counting objects: 26, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (20/20), done.
Writing objects: 100% (26/26), 2.11 KiB | 0 bytes/s, done.
Total 26 (delta 6), reused 0 (delta 0)
remote: Resolving deltas: 100% (6/6), done.
To https://github.com/xxx/mygit.git
 * [new branch]      master -> master
Branch master set up to track remote branch master from origin.
```

### 15. 克隆其他仓库地址
```bash
git clone git@github.com:xxx/mygit.git
```

### 16. 分支

- 创建分支
```bash
$ git checkout -b dev
Switched to a new branch 'dev'
```
等同于
```bash
$ git branch dev
$ git checkout dev
```

- 查看分支
```bash
$ git branch
    * dev
    master
```

- 切换分支
```bash
$ git checkout master
```

- 合并分支
```bash
$ git merge dev
Updating 69bb74e..4155896
Fast-forward
 README.md | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-
```

- 删除分支
```bash
$ git branch -d dev
Deleted branch dev (was 4155896).
```

- 查看分支情况
```bash
$ git log --graph --pretty=oneline --abbrev-commit
```

### 17. 处理BUG分支

- 暂停工作区内容
```bash
$ git stash
```

- 查看暂停区内容
```bash
$ git stash list
```

- 恢复工作区
```bash
$ git stash apply stash@{0}
```

- 强制删除分支
```bash
$ git branch -D feature-vulcan
```

- 给分支打标签
```bash
$ git tag v1.0
```

- 给历史分支打标签
```bash
$ git log --pretty=oneline --abbrev-commit
a8c91a1 (HEAD -> dev, tag: v1.0, origin/master, origin/HEAD, master) merge with no-ff
b21e991 add merge
639df9b conflict fixed
aa1b490 & simple
19422ea AND simple
4155896 branch test
69bb74e Initial commit
admin@DESKTOP-J05KT0C MINGW64 /g/git/pythoncode/gitskills (dev)
$ git tag v0.9 aa1b490
admin@DESKTOP-J05KT0C MINGW64 /g/git/pythoncode/gitskills (dev)
$ git log --pretty=oneline --abbrev-commit
a8c91a1 (HEAD -> dev, tag: v1.0, origin/master, origin/HEAD, master) merge with no-ff
b21e991 add merge
639df9b conflict fixed
aa1b490 (tag: v0.9) & simple
19422ea AND simple
4155896 branch test
69bb74e Initial commit
```

- 为标签做说明描述
```bash
$ git tag -a v0.1 -m "version 0.1 released" 69bb74e
admin@DESKTOP-J05KT0C MINGW64 /g/git/pythoncode/gitskills (dev)
$ git log --pretty=oneline --abbrev-commit
a8c91a1 (HEAD -> dev, tag: v1.0, origin/master, origin/HEAD, master) merge with no-ff
b21e991 add merge
639df9b conflict fixed
aa1b490 (tag: v0.9) & simple
19422ea AND simple
4155896 branch test
69bb74e (tag: v0.1) Initial commit
admin@DESKTOP-J05KT0C MINGW64 /g/git/pythoncode/gitskills (dev)
$ git show v0.1
tag v0.1
Tagger: zhanghk <vipzhanghaokun@163.com>
Date:   Sat Jun 3 00:05:08 2017 +0800
version 0.1 released
commit 69bb74e2b80d31772c29d4bf787025290668a7b1 (tag: v0.1)
...
```

- 删除标签
```bash
$ git tag -d v0.1
Deleted tag 'v0.1' (was 2296cc7)
```
