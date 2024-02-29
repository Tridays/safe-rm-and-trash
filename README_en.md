# safe-rm-and-trash

[[English] | [简体中文](https://github.com/Tridays/safe-rm-and-trash/blob/main/README.md)]
# 1.Introduction
If you often accidentally perform dangerous RMs, such as：<br />
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/01.png?raw=true)
<br />
If you want to execute rm commands and a garbage collection mechanism more securely, then `safe-rm-and-trash` can make your rm commands and data more secure.


# 2.Install
**Attention: `safe-rm-and-trash` was tested and used normally on Ubuntu 16.04, 18.04, 20.04, and 22.04. Other Linux systems should be tested and used normally on a simulation machine before considering deployment**<br /><br />
**Disclaimer: `safe-rm-and-trash` may encounter bugs on different operating systems and cannot be guaranteed to be foolproof. Before any deployment, please conduct extensive testing on a simulated system and use '- i' if necessary to ensure availability. Otherwise, please bear the responsibility for accidental deletion**<br />
Step 1 (Download Script)：<br />
1.Using curl
```bash
curl -s "https://raw.githubusercontent.com/Tridays/safe-rm-and-trash/main/rm.sh" -o ~/rm.sh
```
2.Using wget
```bash
wget -c "https://raw.githubusercontent.com/Tridays/safe-rm-and-trash/main/rm.sh"
```
3.Using Git
```bash
git clone "https://github.com/Tridays/safe-rm-and-trash"
cd safe-rm-and-trash
```
Step 2 (Installation Script)：<br />
1.Install in normal mode --install
```bash
sudo bash ./rm.sh --install
source /etc/profile # Update environment variables
```
Normal mode, the operation executed by the script during the installation process. [Keep /bin/rm]： <br />
cp ./rm.sh --> /bin/rm.sh <br />
cp /bin/rm --> /bin/rm.bak | cp /usr/bin/rm --> /usr/bin/rm.bak<br />
echo "alias rm=/bin/rm.sh" | tee -a /etc/profile <br /><br />

2.Install in Safe Mode --safe-install
```bash
sudo bash ./rm.sh --safe-install
source /etc/profile # Update environment variables
```
In safe mode, the script execution during the installation process includes the following additional operations compared to normal mode. [Completely replacing rm work]： <br />
del /bin/rm | del /usr/bin/rm <br />
link /bin/rm.sh --> /bin/rm | link /bin/rm.sh --> /usr/ bin/rm<br />


# 3.Way of working
(1)`safe-rm-and-trash` will create a garbage bin named `/home/.trash`. If you want to change the path of the garbage bin, the maximum capacity of the garbage bin, or the maximum allowed size of a single file, please open rm.sh to modify it.<br />

![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/02.png?raw=true)
<br />

(2)`safe-rm-and-trash` will automatically check the parameters passed when rm is called. If the parameters contain important files, it may indicate that this is a dangerous rm operation, and `safe-rm-and-trash` will directly ignore this rm operation. As for which files are important, it is up to you to decide (please open rm.sh to modify).
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/03.png?raw=true)

(3)`safe-rm-and-trash`Effective for all users, including existing users and future newly created users.

(4)`safe-rm-and-trash`When replacing RM, it will automatically back up/bin/rm -->/bin/rm.bak. (Note: The new version of the system rm may be located in the/usr/bin/ directory).

# 4.Use demonstration
(1)Normal installation mode (you will find that the rm command has been replaced by rm.sh, but the original/bin/rm has been retained)
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/install.png?raw=true)

(2)Safe installation mode (you will find that the rm command and /bin/rm are completely replaced by rm.sh)
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/safe-install.png?raw=true)

**Note:**
When conducting rm testing, please ensure that it is rm. sh and not the system's rm. If necessary, use `-i` as follows:
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/04.png?raw=true)

(3)Perform dangerous operation testing in the system root directory⚠️
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/05.png?raw=true)

(4)Dangerous operation test in the second level directory of the system root⚠️
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/08.png?raw=true)

(5)Dangerous operation test in the third level directory of the system root⚠️
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/09.png?raw=true)

(6)Dangerous operation testing in other regular directories⚠️
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/06.png?raw=true)


Explanation: Regardless of which directory you are performing dangerous operations in, `safe-rm-and-trash` will protect the root directory `/` and secondary directory. When you execute `rm -rf /bin/*`, it is not allowed and will be intercepted by rm.sh. However, you can manually delete it individually, such as `rm -rf /bin/nginx`, or if you really need to delete it, please use the command prompted by the script to delete `/bin/rm.bak -rf ./bin/*` (This will be truly deleted, dangerous operation!!!)



(7)Delete regular files/folders for testing
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/07.png?raw=true)

(8)Remove regular files/folders to the garbage bin for testing (use `-b`)
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/10.png?raw=true)

(9)Test using sudo to delete files/folders
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/11.png?raw=true)


# 5.How to clear the garbage bin on time?
```bash
sudo crontab -e

# 添加(每天00:00定时清空)
0 0 * * * /bin/rm.sh -f --clean

# 或者(每间隔3天的00:00定时清空)
0 0 */3 * * /bin/rm.sh -f --clean
```


# 6.How to uninstall`safe-rm-and-trash` || Restore system rm
```bash
# You only need to execute to restore the system rm
/bin/rm.sh --uninstall

# When needed, you can continue to use rm.sh again
/bin/rm.sh --safe-install
```

# 7.`safe-rm-and-trash`Parameter Introduction
![alt text](https://github.com/Tridays/safe-rm-and-trash/blob/main/12.png?raw=true)
Except for these newly added options such as `-b、--install、--safe-install、--uninstall、--clean`, the remaining options are almost identical to the system's native rm command.<br/>
**Note: Only when using '`-b` will files be recycled to the trash can**<br/>
**If this project is helpful for your data security, please help click on `Star`**<br/>
**If you find any script bugs, please feel free to raise an  `issue`**<br/>
