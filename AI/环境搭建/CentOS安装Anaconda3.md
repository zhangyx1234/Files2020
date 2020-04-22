## 一、Anaconda安装

1、wget 获取anaconda3的路径，此处为了下载速度，选择清华的镜像，取最新的版本。镜像路径为https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/?C=M&O=D

![image-20200324094750580](CentOS%E5%AE%89%E8%A3%85Anaconda3.assets/image-20200324094750580.png)

```
#wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda3-2020.02-Linux-x86_64.sh
```

 2、用bash安装anaconda3

```
#bash Anaconda3-2020.02-Linux-x86_64.sh’
```

一路输入yes或者enter

![image-20200324100725464](CentOS%E5%AE%89%E8%A3%85Anaconda3.assets/image-20200324100725464.png)

3、添加环境变量

```
#vi /etc/profile

在最后加上如下
PATH=/root/anaconda3/bin:$PATH
export PATH
```

4、刷新环境变量

```
#source ~/.bashrc
#source activate   #进入环境、可选择的操作
#source deactivate #退出环境、可选择的操作

#conda list 
```

![image-20200324102654960](CentOS%E5%AE%89%E8%A3%85Anaconda3.assets/image-20200324102654960.png)

5、coda  基本命令

```
升级
#conda update conda
#conda update anaconda
#conda update anaconda-navigator    //update最新版本的anaconda-navigator  

卸载
rm -rf anaconda    //ubuntu

基本命令
conda update -n base conda        //update最新版本的conda
conda create -n xxxx python=3.5   //创建python3.5的xxxx虚拟环境
conda activate xxxx               //开启xxxx环境
conda deactivate                  //关闭环境
conda env list                    //显示所有的虚拟环境


修改国内源

#conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
#conda config --set show_channel_urls yes
```



## 二、Jupyter配置

1、密码相关

```
#conda   activate   enName

#python

#from notebook.auth import passwd

#passwd()

Enter password:  capitek2020
Verify password:  capitek2020
'sha1:22fbadf3d114:d6ae0ba4a21c7fd2ff5bf8bc95aeb2f7e3740e9c'

#如下修改会用到密文
c.NotebookApp.password = u'sha1:22fbadf3d114:d6ae0ba4a21c7fd2ff5bf8bc95aeb2f7e3740e9c'

```

2.修改配置文件：

```
#jupyter notebook --generate-config
```

在 /root/.jupyter/jupyter_notebook_config.py中找到下面的行，取消注释并修改。

```
c.NotebookApp.ip='*'
c.NotebookApp.password = u'sha1:a5...刚才复制的那个密文'
c.NotebookApp.open_browser = True
c.NotebookApp.port =8888 #可自行指定一个端口, 访问时使用该端
c.NotebookApp.notebook_dir = '/root/JupyterNoteBook/'

```

5、启动jupyter notebook

服务器上启动 jupyter notebook，root 用户使用 jupyter notebook --allow-root。

```
#jupyter notebook --ip=0.0.0.0 --no-browser --allow-root
```

浏览器打开 IP:指定的端口, 输入密码就可以访问了。



6、新建环境后新环境打不开jupyter notebook

```
conda install -n torch python=3.6
conda activate torch
conda install nb_conda_kernels
```

