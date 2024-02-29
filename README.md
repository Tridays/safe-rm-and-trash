# safe-rm-and-trash

[[English](https://github.com/malongshuai/safe-rm-and-trash/blob/master/README.md) | 简体中文]
# 1.引言
如果你经常不小心执行危险的rm，例如：<br />
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/01.png?raw=true)
<br />
如果你想要更安全的执行rm命令和一个垃圾回收机制，那么`safe-rm-and-trash`可以让你的rm命令和数据变得更加安全。

# 2.安装
**注意事项:`safe-rm-and-trash`在ubuntu 16.04、18.04、20.04、22.04测试均正常使用，其他Linux系统请在模拟机测试正常使用，再考虑部署**<br />
**声明:`safe-rm-and-trash`在不同的操作系统难免会出现bug，不能保证万无一失，任何部署之前，请在模拟系统上进行大量测试，必要时使用`-i`，确保可用性，否则出现误删除请自行承担**<br />
步骤一（下载脚本）：<br />
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
步骤二（安装脚本）：<br />
1.以普通模式安装 --install
```bash
sudo bash ./rm.sh --install
source /etc/profile # 更新环境变量
```
普通模式，安装过程部分脚本执行的操作。[保留/bin/rm]： <br />
cp ./rm.sh --> /bin/rm.sh <br />
cp /bin/rm --> /bin/rm.bak | cp /usr/bin/rm --> /usr/bin/rm.bak<br />
echo "alias rm=/bin/rm.sh" | tee -a /etc/profile <br /><br />

2.以安全模式安装 --safe-install
```bash
sudo bash ./rm.sh --safe-install
source /etc/profile # 更新环境变量
```
安全模式，安装过程部分脚本执行的操作（比普通模式多了以下操作）。[完全替代rm工作]： <br />
del /bin/rm | del /usr/bin/rm <br />
link /bin/rm.sh --> /bin/rm | link /bin/rm.sh --> /usr/ bin/rm<br />


# 3.工作方式
(1)`safe-rm-and-trash`会创建一个名为`/home/.trash`的垃圾回收站, 如果你想更改垃圾回收站的路径、回收站最大容量、单个文件允许的最大大小，请打开rm.sh修改。
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/02.png?raw=true)

(2)`safe-rm-and-trash`会自动检查rm被调用时传递的参数，如果参数中包含了重要文件，可能意味着这是一次危险的rm操作，`safe-rm-and-trash`会直接忽略本次rm。至于哪些属于重要文件，由你自己来决定（请打开rm.sh修改）。
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/03.png?raw=true)

(3)`safe-rm-and-trash`对所有用户都有效，即包括已存在的用户和未来新创建的用户。

(4)`safe-rm-and-trash`替代rm时，会自动备份/bin/rm --> /bin/rm.bak。（注意：新版本系统rm可能在/usr/bin/目录下）。

# 4.使用演示
(1)普通安装模式（你会发现rm命令被rm.sh替代了, 但是保留了原来的/bin/rm）
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/install.png?raw=true)

(2)安全安装模式（你会发现rm命令和/bin/rm被完全rm.sh替代了）
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/safe-install.png?raw=true)

**注意事项:**
进行rm测试时，请确保他是rm.sh而不是系统的rm，必要时使用`-i`，如下：
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/04.png?raw=true)

(3)在系统根目录进行危险操作测试⚠️
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/05.png?raw=true)

(4)在系统根二级目录危险操作测试⚠️
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/08.png?raw=true)

(5)在系统根三级目录危险操作测试⚠️
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/09.png?raw=true)

(6)在其他普通目录危险操作测试⚠️
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/06.png?raw=true)


解释：不论您在哪个目录执行危险操作，`safe-rm-and-trash`会保护根目录`/`以及二级目录，当您执行`rm -rf /bin/*`是不被允许的，会被rm.sh拦截，但是你可以单个手动删除，如`rm -rf /bin/nginx`，或者您真的确认要需要删除时，请使用脚本提示的命令删除`/bin/rm.bak -rf ./bin/*`（这会被真正删除，危险操作！！！）


(7)删除普通文件/文件夹测试
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/07.png?raw=true)

(8)把普通文件/文件夹移除到垃圾回收站测试（使用`-b`）
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/10.png?raw=true)

(9)以sudo删除文件/文件夹测试
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/11.png?raw=true)


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
