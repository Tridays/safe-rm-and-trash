# safe-rm-and-trash

[[English](https://github.com/malongshuai/safe-rm-and-trash/blob/master/README.md) | 简体中文]
# 引言
如果你经常不小心执行危险的rm，例如：
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/01.png?raw=true)

如果你想要更安全的执行rm命令和一个垃圾回收机制，那么`safe-rm-and-trash`可以让你的rm命令和数据变得更加安全。

# 安装
步骤一（下载脚本）：
1.使用curl
```bash
curl -s "https://raw.githubusercontent.com/Tridays/safe-rm-and-trash/main/rm.sh" -o ~/rm.sh
```
2.使用wget
```bash
wget -c "https://raw.githubusercontent.com/Tridays/safe-rm-and-trash/main/rm.sh"
```
3.使用git
```bash
git clone "https://github.com/Tridays/safe-rm-and-trash"
cd safe-rm-and-trash
```
步骤二（安装脚本）：
1.以普通模式安装 --install
```bash
sudo bash ./rm.sh --install
```
普通模式，安装过程部分脚本执行的操作。[保留/bin/rm]：
cp ./rm.sh --> /bin/rm.sh
cp /bin/rm --> /bin/rm.bak | cp /usr/bin/rm --> /usr/bin/rm.bak
echo "alias rm=/bin/rm.sh" | tee -a /etc/profile

2.以安全模式安装 --safe-install
```bash
sudo bash ./rm.sh --safe-install
```
安全模式，安装过程部分脚本执行的操作（比普通模式多了以下操作）。[完全替代rm工作]：
del /bin/rm | del /usr/bin/rm
link /bin/rm.sh --> /bin/rm | link /bin/rm.sh --> /usr/bin/rm


# 工作方式
(1)`safe-rm-and-trash`会创建一个名为`/home/.trash`的垃圾回收站, 如果你想更改垃圾回收站的路径、回收站最大容量、单个文件允许的最大大小，请打开rm.sh修改。
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/02.png?raw=true)

`safe-rm-and-trash`会自动检查rm被调用时传递的参数，如果参数中包含了重要文件，可能意味着这是一次危险的rm操作，`safe-rm-and-trash`会直接忽略本次rm。至于哪些属于重要文件，由你自己来决定（请打开rm.sh修改）。
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/03.png?raw=true)

`safe-rm-and-trash`对所有用户都有效，即包括已存在的用户和未来新创建的用户。



# 哪些是重要文件？

1. 根目录`/`以及根目录下的子目录、子文件总是被保护的
2. 你可以在`/etc/security/rm_fileignore`中定义你自己觉得重要的文件，每行定义一个被保护的文件路径。例如：

    ```
    /home/junmajinlong
    /home/junmajinlong/apps
    ```

现在，该文件中定义的两个文件都被保护起来了，它们是安全的，不会被rm删除。

**注意事项:**

1. 显然，被保护的目录是不会进行递归的，所以'/bin'是安全的，而'/bin/aaa'是不安全的，除非你将它加入/etc/security/rm_fileignore文件中
2. 根目录`/`以及根目录下的子目录是自动被保护的，不用手动将它们添加到/etc/security/rm_fileignore中
3. /etc/security/rm_fileignore文件中定义的路径可以包含任意斜线，`safe-rm-and-trash`会自动处理。所以，'/home/junmajinlong'和'/home///junmajinlong/////'都是有效路径
4. /etc/security/rm_fileignore中定义的路径中不要使用通配符，例如`/home/*`是无效的
5. /etc/security/rm_fileignore中不要定义相对路径，要定义绝对路径

# Usage

1.git clone或拷贝仓库中的Shell脚本到你的主机上

```
$ git clone https://github.com/malongshuai/safe-rm-and-trash.git
```

2.执行该Shell脚本

```
$ cd safe-rm-and-trash
$ sudo bash safe-rm-and-trash.sh
```

执行完成后，你的rm命令就变成了安全的rm了。

3.如果你确实想要删除被保护的文件，比如你明确知道/data是可以删除的，而根目录下的子目录默认总是被保护的，那么你 可以使用原生的rm命令，即/bin/rm.bak来删除。

```
$ rm.bak /path/to/file
```

4.如果你想要卸载`safe-rm-and-trash`，执行函数`uninstall_safe-rm-and-trash`即可：

```
# 如果找不到该函数，则先exec bash，在执行即可
$ uninstall_safe-rm-and-trash
```

卸载完成后，`/bin/rm`就变回原生的rm命令了。
