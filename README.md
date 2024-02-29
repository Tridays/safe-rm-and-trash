# safe-rm-and-trash

[[English](https://github.com/Tridays/safe-rm-and-trash/blob/main/README_en.md) | 简体中文]
# 1.引言
如果你经常不小心执行危险的rm，例如：<br />
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/01.png?raw=true)
<br />
如果你想要更安全的执行rm命令和一个垃圾回收机制，那么`safe-rm-and-trash`可以让你的rm命令和数据变得更加安全。

# 2.安装
**注意事项:`safe-rm-and-trash`在ubuntu 16.04、18.04、20.04、22.04测试均正常使用，其他Linux系统请在模拟机测试正常使用，再考虑部署**<br /><br />
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


# 5.如何按时清空垃圾回收站？
```bash
sudo crontab -e

# 添加(每天00:00定时清空)
0 0 * * * /bin/rm.sh -f --clean

# 或者(每间隔3天的00:00定时清空)
0 0 */3 * * /bin/rm.sh -f --clean
```


# 6.如何卸载`safe-rm-and-trash` || 恢复系统rm
```bash
# 你只需要执行，即可恢复系统rm
/bin/rm.sh --uninstall

# 当需要时，还可以继续使用回rm.sh
/bin/rm.sh --safe-install
```

# 7.`safe-rm-and-trash`参数介绍
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/12.png?raw=true)
除了这些选项是新增加的`-b、--install、--safe-install、--uninstall、--clean`之外，其余的选项和系统原生rm命令几乎一致。<br/>
**注意事项:只有使用`-b`时，文件才会回收到垃圾站**<br/>
**如果这个项目对你的数据安全有帮助，请帮忙点个`Star`**<br/>
**如果发现脚本bug，欢迎提`issue`**<br/>
