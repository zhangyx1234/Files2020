实现原理：为jupyter notebook 添加一个新的kernel（可以在界面切换到该虚拟环境）

1、切换到目标虚拟环境

```
#conda activate  envName  #envName 为虚拟环境的具体名字
```

2、在该环境中安装ipykernel

```
# conda  install ipykernel
```

3、 执行以下语句

```
#python -m ipykernel install --name  envName   #envName 为虚拟环境的具体名字
```

