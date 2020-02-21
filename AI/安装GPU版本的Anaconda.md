1、安装GPU版本的Anaconda

```linux
1）建立新的环境
conda create -n Pytorch python=3.6

2）激活环境
conda activate pytorch

3）添加清华源
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/

conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/pro/

4）安装Pytorch
conda install pytorch torchvision cudatoolkit=10.0 -c pytorch

5）Jupyter Notebook测试
import torch
torch.cuda.is_available()
```

2 、修改Jupter  Notebook 路径

```
1）查看路径方法： 在Anaconda Prompt中输入
jupyter notebook --generate-config 

2) 打开配置文件jupyter_notebook_config.py  修改路径 notebook_dir为自己指定地址
 注：路径不包含中文
 
3）右击属性，将%USERPROFILE%删除
```

3 、修改 Jupyter Notebook编辑风格

```
1) 安装主题工具 jupterthemes 
pip install --upgrade jupyterthemes

2）查看所有主题
jt -l

3）修改自己的主题
jt -t 'theme_name' -f 'font_name' -fs 'font_size'

4）查看各个方面设置
jt --help

5） 安装前保证matplotlib库的版本

6）比较合适的主题
jt --lineh 140  -tf ptmono -t onedork -ofs 13 -nfs 14 -tfs 14 -fs 14 -T -N -dfs 10

```

4、代码补全的设置方法

```
1）安装jupyter_contrib_nbextensions
conda install jupyter_contrib_nbextensions

2）安装jupyter_nbextensions_configurator
conda install jupyter_nbextensions_configurator

3）安装完成后重新打开jupyternotebook，在菜单栏可以看到 NBextensions这个选项，在其中勾选上“Hinterland”即可打开自动补全。
```

5、切换环境

```
1）切换到pytroch 环境
activate  pytorch

2）安装 ipykernel
conda install ipykernel

3) 在notebook 主界面‘kernel’下拉的‘Change kernel’ 切换源

```

