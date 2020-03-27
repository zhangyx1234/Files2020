**理解时间序列**

在Node Exporter的/metrics接口中返回的每一行监控数据，在Prometheus下称为一个样本。采集到的样本由以下三部分组成：

- 指标（metric）：指标和一组描述当前样本特征的labelsets唯一标识；
- 时间戳（timestamp）：一个精确到毫秒的时间戳，一般由采集时间决定；
- 样本值（value）： 一个folat64的浮点型数据表示当前样本的值。

Prometheus会将所有采集到的样本数据以时间序列（time-series）的方式保存在内存数据库中，并且定时保存到硬盘上。每条time-series通过指标名称（metrics name）和一组标签集（labelset）命名。如下所示，可以将time-series理解为一个以时间为X轴的二维矩阵：