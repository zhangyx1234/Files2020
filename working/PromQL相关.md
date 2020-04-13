# 一、PromQL 基本使用

​        PromQL (Prometheus Query Language) 是 Prometheus 自己开发的数据查询 DSL 语言，语言表现力非常丰富，内置函数很多，在日常数据可视化以及rule 告警中都会使用到它。

在页面 `http://localhost:9090/graph` 中，输入下面的查询语句，查看结果，例如：

```
http_requests_total{code="200"}
```

### 1、字符串和数字

**字符串**: 在查询语句中，字符串往往作为查询条件 labels 的值，和 Golang 字符串语法一致，可以使用 `""`, `''`, 或者 ``` `, 格式如：

```
"this is a string"
'these are unescaped: \n \\ \t'
`these are not unescaped: \n ' " \t`
```

**正数，浮点数**: 表达式中可以使用正数或浮点数，例如：

```
3
-2.4
```

### 2、查询结果类型

PromQL 查询结果主要有 3 种类型：

- 瞬时数据 (Instant vector): 包含一组时序，每个时序只有一个点，例如：`http_requests_total`
- 区间数据 (Range vector): 包含一组时序，每个时序有多个点，例如：`http_requests_total[5m]`
- 纯量数据 (Scalar): 纯量只有一个数字，没有时序，例如：`count(http_requests_total)`

### 3、查询条件

​		Prometheus 存储的是时序数据，而它的时序是由名字和一组标签构成的，其实名字也可以写出标签的形式，例如 `http_requests_total` 等价于 {**name**="http_requests_total"}。

一个简单的查询相当于是对各种标签的筛选，例如：

```
http_requests_total{code="200"} // 表示查询名字为 http_requests_total，code 为 "200" 的数据
```

​		查询条件支持正则匹配，例如：

```
http_requests_total{code!="200"}  // 表示查询 code 不为 "200" 的数据
http_requests_total{code=～"2.."} // 表示查询 code 为 "2xx" 的数据
http_requests_total{code!～"2.."} // 表示查询 code 不为 "2xx" 的数据
```

### 4、操作符

Prometheus 查询语句中，支持常见的各种表达式操作符，例如

**算术运算符**:

支持的算术运算符有 `+，-，*，/，%，^`, 例如 `http_requests_total * 2` 表示将 http_requests_total 所有数据 double 一倍。

**比较运算符**:

支持的比较运算符有 `==，!=，>，<，>=，<=`, 例如 `http_requests_total > 100` 表示 http_requests_total 结果中大于 100 的数据。

**逻辑运算符**:

支持的逻辑运算符有 `and，or，unless`, 例如 `http_requests_total == 5 or http_requests_total == 2` 表示 http_requests_total 结果中等于 5 或者 2 的数据。

**聚合运算符**:

支持的聚合运算符有 `sum，min，max，avg，stddev，stdvar，count，count_values，bottomk，topk，quantile，`, 例如 `max(http_requests_total)` 表示 http_requests_total 结果中最大的数据。

注意，和四则运算类型，Prometheus 的运算符也有优先级，它们遵从（^）> (*, /, %) > (+, -) > (==, !=, <=, <, >=, >) > (and, unless) > (or) 的原则。

### 5、内置函数

​		Prometheus 内置不少函数，方便查询以及数据格式化，例如将结果由浮点数转为整数的 floor 和 ceil，

```
floor(avg(http_requests_total{code="200"}))
ceil(avg(http_requests_total{code="200"}))
```

​		查看 http_requests_total 5分钟内，平均每秒数据

```
rate(http_requests_total[5m])
```

##### 内置函数详细链接：https://prometheus.io/docs/prometheus/latest/querying/functions/





# 二、PromQL与数据处理

​        Prometheus通过PromQL提供了强大的数据查询和处理能力。对于外部系统而言可以通过Prometheus提供的API接口，使用PromQL查询相关的样本数据，从而实现如数据可视化等自定义需求，PromQL是Prometheus对内，对外功能实现的主要接口。

### 1、理解时间序列

​		在Node Exporter的/metrics接口中返回的每一行监控数据，在Prometheus下称为一个样本。采集到的样本由以下三部分组成：

- 指标（metric）：指标和一组描述当前样本特征的labelsets唯一标识；
- 时间戳（timestamp）：一个精确到毫秒的时间戳，一般由采集时间决定；
- 样本值（value）： 一个folat64的浮点型数据表示当前样本的值。


​        Prometheus会将所有采集到的样本数据以时间序列（time-series）的方式保存在内存数据库中，并且定时保存到硬盘上。每条time-series通过指标名称（metrics name）和一组标签集（labelset）命名。这种多维度的数据存储方式，可以衍生出很多不同的玩法。 比如，如果数据来自不同的数据中心，那么我们可以在样本中添加标签来区分来自不同数据中心的监控样本，例如：

```
node_cpu{cpu="cpu0",mode="idle", dc="dc0"}
```

​        从内部实现上来看Prometheus中所有存储的监控样本数据没有任何差异，均是一组标签，时间戳以及样本值。从存储上来讲所有的监控指标metric都是相同的，但是在不同的场景下这些metric又有一些细微的差异。 例如，在Node Exporter返回的样本中指标node_load1反应的是当前系统的负载状态，随着时间的变化这个指标返回的样本数据是在不断变化的。而指标node_cpu所获取到的样本数据却不同，它是一个持续增大的值，因为其反应的是CPU的累积使用时间，从理论上讲只要系统不关机，这个值是会无限变大的。

​        为了能够帮助用户理解和区分这些不同监控指标之间的差异，Prometheus定义了4中不同的指标类型（metric type）：Counter（计数器）、Gauge（仪表盘）、Histogram（直方图）、Summary（摘要）。

### 2、Counter：只增不减的计数器**

​         Counter是一个简单但有强大的工具，例如我们可以在应用程序中记录某些事件发生的次数，通过以时序的形式存储这些数据，我们可以轻松的了解该事件产生速率的变化。PromQL内置的聚合操作和函数可以用户对这些数据进行进一步的分析：
例如，通过rate()函数获取HTTP请求量的增长率：

```
rate(http_requests_total[5m]) 
```

### **3、Gauge：可增可减的仪表盘**

​        与Counter不同，Gauge类型的指标侧重于反应系统的当前状态。因此这类指标的样本数据可增可减。常见指标如：node_memory_MemFree（主机当前空闲的内容大小）、node_memory_MemAvailable（可用内存大小）都是Gauge类型的监控指标。
通过Gauge指标，用户可以直接查看系统的当前状态：

```
node_memory_MemFree
```


对于Gauge类型的监控指标，通过PromQL内置函数delta()可以获取样本在一段时间返回内的变化情况。例如，计算CPU温度在两个小时内的差异：

```
delta(cpu_temp_celsius{host="zeus"}[2h])
```


还可以使用deriv()计算样本的线性回归模型，甚至是直接使用predict_linear()对数据的变化趋势进行预测。例如，预测系统磁盘空间在4个小时之后的剩余情况：

```
predict_linear(node_filesystem_free{job="node"}[1h], 4 * 3600)
```

### **4、使用Histogram和Summary分析数据分布情况**

​        在大多数情况下人们都倾向于使用某些量化指标的平均值，例如CPU的平均使用率、页面的平均响应时间。这种方式的问题很明显，以系统API调用的平均响应时间为例：如果大多数API请求都维持在100ms的响应时间范围内，而个别请求的响应时间需要5s，那么就会导致某些WEB页面的响应时间落到中位数的情况，而这种现象被称为长尾问题。
​       为了区分是平均的慢还是长尾的慢，最简单的方式就是按照请求延迟的范围进行分组。例如，统计延迟在010ms之间的请求数有多少而1020ms之间的请求数又有多少。通过这种方式可以快速分析系统慢的原因。Histogram和Summary都是为了能够解决这样问题的存在，通过Histogram和Summary类型的监控指标，我们可以快速了解监控样本的分布情况。

​        例如，指标prometheus_tsdb_wal_fsync_duration_seconds的指标类型为Summary。 它记录了Prometheus Server中wal_fsync处理的处理时间，通过访问Prometheus Server的/metrics地址，可以获取到以下监控样本数据：

```
prometheus_tsdb_wal_fsync_duration_seconds{quantile="0.5"} 0.012352463
prometheus_tsdb_wal_fsync_duration_seconds{quantile="0.9"} 0.014458005
prometheus_tsdb_wal_fsync_duration_seconds{quantile="0.99"} 0.017316173
prometheus_tsdb_wal_fsync_duration_seconds_sum 2.888716127000002
prometheus_tsdb_wal_fsync_duration_seconds_count 216
```


从上面的样本中可以得知当前Promtheus Server进行wal_fsync操作的总次数为216次，耗时2.888716127000002s。其中中位数（quantile=0.5）的耗时为0.012352463，9分位数（quantile=0.9）的耗时为0.014458005s。

​        Prometheus对于数据的存储方式就意味着，不同的标签就代表着不同的特征维度。用户可以通过这些特征维度对查询，过滤和聚合样本数据。
例如，通过node_load1，查询出当前时间序列数据库中所有名为node_load1的时间序列：

```
node_load1
```


如果找到满足某些特征维度的时间序列，则可以使用标签进行过滤：

```
node_load1{instance="localhost:9100"}
```

​         通过以标签为核心的特征维度，用户可以对时间序列进行有效的查询和过滤，当然如果仅仅是这样，显然还不够强大，Prometheus提供的丰富的聚合操作以及内置函数，可以通过PromQL轻松回答以下问题：
当前系统的CPU使用率？

```
avg(irate(node_cpu{mode!="idle"}[2m])) without (cpu, mode)
```


CPU占用率前5位的主机有哪些？

```
topk(5, avg(irate(node_cpu{mode!="idle"}[2m])) without (cpu, mode))
```


预测在4小时候后，磁盘空间占用大致会是什么情况？

```
predict_linear(node_filesystem_free{job="node"}[2h], 4 * 3600)
```

​        其中avg()，topk()等都是PromQL内置的聚合操作，irate()，predict_linear()是PromQL内置的函数，irate()函数可以计算一段时间返回内时间序列中所有样本的单位时间变化率。predict_linear函数内部则通过简单线性回归的方式预测数据的变化趋势。

​        以Grafana为例，在Grafana中可以通过将Promtheus作为数据源添加到系统中，后再使用PromQL进行数据可视化。在Grafana v5.1中提供了对Promtheus 4种监控类型的完整支持，可以通过Graph Panel，Singlestat Panel，Heatmap Panel对监控指标数据进行可视化。

使用Graph Panel可视化主机CPU使用率变化情况：


使用Sigle Panel显示当前状态：


使用Heatmap Panel显示数据分布情况：

# 三、prometheus中常用的查询

​        prometheus server 可以通过HTTPAPI的方式进行查询，官网链接https://prometheus.io/docs/prometheus/latest/querying/basics/

 我这边主要用到的是实时查询，当然prometheus还支持历史查询，我这里 先介绍实时查询，其他的可以直接参考官方文档。

实时查询接口：

"%s/api/v1/query?query=%s"

### 1、 直接查询某一监控指标:

比如查询 process_start_time_seconds,

http://localhost:9090/api/v1/query?query=process_start_time_seconds

{
    "status":"success",
    "data":{
        "resultType":"vector",
        "result":[
            {
                "metric":{
                    "__name__":"process_start_time_seconds",
                    "instance":"localhost:9090",
                    "job":"prometheus"
                },
                "value":[
                    1533194622.184,
                    "1532609170.42"
                ]
            },
            {
                "metric":{
                    "__name__":"process_start_time_seconds",
                    "instance":"localhost:9295",
                    "job":"postgres"
                },
                "value":[
                    1533194622.184,
                    "1533034386.88"
                ]
            }
        ]
    }
}

### 2、根据某一字段加上标签：

比如查询job为prometheus的process_start_time_seconds指标：

http://localhost:9090/api/v1/query?query=process_start_time_seconds{job="prometheus"}

### 3、正则表达式匹配前缀：

比如一些监控 指标都以pro开头，可以通过正则表达式匹配前缀的方式一把搂回来：

htp://localhost:9090/api/v1/query?query={__name__=~"pro.*"}

当然prometheus是支持各个标签 label之间通过and ，or ，unless进行组合，比如：

htp://localhost:9090/api/v1/query?query={__name__=~"pro.*"}and{job="progres"}

查询出job名为progres，标签名以pro为前缀的监控数据。



# 四、指标详细解析