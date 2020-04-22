[TOC]



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

##### `abs()`

`abs(v instant-vector)` 返回所有样本值均转换为绝对值的输入向量。

##### `absent()`

`absent(v instant-vector)` 如果传递给它的向量具有任何元素，则返回一个空向量；如果传递给它的向量没有元素，则返回值为1的1元素向量。

这对于在给定度量标准名称和标签组合不存在任何时间序列时发出警报非常有用。

```
absent(nonexistent{job="myjob"})
# => {job="myjob"}

absent(nonexistent{job="myjob",instance=~".*"})
# => {job="myjob"}

absent(sum(nonexistent{job="myjob"}))
# => {}
```

在前两个示例中，`absent()`尝试聪明地从输入向量中导出1元素输出向量的标签。

##### `absent_over_time()`

`absent_over_time(v range-vector)` 如果传递给它的范围向量有任何元素，则返回一个空向量；如果传递给它的范围向量没有元素，则返回值为1的1元素向量。

这对于在给定的度量标准名称和标签组合在一定时间内没有时间序列时发出警报是很有用的。

```
absent_over_time(nonexistent{job="myjob"}[1h])
# => {job="myjob"}

absent_over_time(nonexistent{job="myjob",instance=~".*"}[1h])
# => {job="myjob"}

absent_over_time(sum(nonexistent{job="myjob"})[1h:])
# => {}
```

在前两个示例中，`absent_over_time()`尝试聪明地从输入向量中导出1元素输出向量的标签。

##### `ceil()`

`ceil(v instant-vector)`将所有元素的样本值四舍五入`v`到最接近的整数。

##### `changes()`

对于每个输入时间序列，`changes(v range-vector)`返回其值在提供的时间范围内变化的次数作为即时向量。

##### `clamp_max()`

`clamp_max(v instant-vector, max scalar)`将所有元素的样本值钳位为的`v`上限`max`。

##### `clamp_min()`

`clamp_min(v instant-vector, min scalar)`将所有元素的样本值钳制在`v`一个下限内`min`。

##### `day_of_month()`

`day_of_month(v=vector(time()) instant-vector)`返回UTC中每个给定时间的月份。返回值是1到31。

##### `day_of_week()`

`day_of_week(v=vector(time()) instant-vector)`返回UTC中每个给定时间的星期几。返回的值是从0到6，其中0表示星期日等。

##### `days_in_month()`

`days_in_month(v=vector(time()) instant-vector)`返回UTC中每个给定时间的月份中的天数。返回值是28到31。

##### `delta()`

`delta(v range-vector)`计算范围向量中每个时间序列元素的第一个值与最后一个值之间的差`v`，并返回具有给定增量和等效标签的即时向量。根据范围矢量选择器中的指定，可以将增量外推以覆盖整个时间范围，因此即使采样值都是整数，也可以得到非整数结果。

以下示例表达式返回现在和2小时前之间的CPU温度差异：

```
delta(cpu_temp_celsius{host="zeus"}[2h])
```

`delta` 只能与压力表一起使用。

##### `deriv()`

`deriv(v range-vector)``v`使用[简单的线性回归](https://en.wikipedia.org/wiki/Simple_linear_regression)来计算范围向量中时间序列的每秒导数。

`deriv` 只能与压力表一起使用。

##### `exp()`

`exp(v instant-vector)`计算中的所有元素的指数函数`v`。特殊情况是：

- `Exp(+Inf) = +Inf`
- `Exp(NaN) = NaN`

##### `floor()`

`floor(v instant-vector)`将所有元素的样本值四舍五入`v`到最接近的整数。

##### `histogram_quantile()`

`histogram_quantile(φ float, b instant-vector)`计算φ -分位数（0≤φ≤1）从桶`b`一个的 [直方图](https://prometheus.io/docs/concepts/metric_types/#histogram)。（有关φ分位数的详细说明以及通常使用直方图度量类型的信息，请参见 [直方图和摘要](https://prometheus.io/docs/practices/histograms)。）中的样本`b`是每个存储桶中观察值的计数。每个样本必须有一个标签`le`，其中标签值表示存储桶的包含上限。（不带标签的样本将被忽略。）[直方图度量标准类型会](https://prometheus.io/docs/concepts/metric_types/#histogram) 自动提供带有`_bucket`后缀和适当标签的时间序列。

使用此`rate()`功能可以指定分位数计算的时间窗口。

示例：直方图度量称为`http_request_duration_seconds`。要计算最近10m的请求持续时间的90％，请使用以下表达式：

```
histogram_quantile(0.9, rate(http_request_duration_seconds_bucket[10m]))
```

计算中的每个标签组合的分位数 `http_request_duration_seconds`。要进行聚合，请`sum()`在`rate()`函数周围使用聚合器。由于`le`标签是必需的 `histogram_quantile()`，因此必须将其包含在`by`子句中。以下表达式通过以下方式汇总第90个百分点`job`：

```
histogram_quantile(0.9, sum(rate(http_request_duration_seconds_bucket[10m])) by (job, le))
```

要汇总所有内容，请仅指定`le`标签：

```
histogram_quantile(0.9, sum(rate(http_request_duration_seconds_bucket[10m])) by (le))
```

该`histogram_quantile()`函数通过假设存储桶内的线性分布来内插分位数。最高存储桶的上限必须为`+Inf`。（否则，`NaN`返回。）如果分位数位于最高存储桶中，则返回第二高存储桶的上限。如果该存储桶的上限大于0，则将最低存储桶的下限假定为0。在这种情况下，通常在该存储桶中应用线性插值。否则，将为位于最低存储桶中的分位数返回最低存储桶的上限。

如果`b`包含少于两个存储桶，`NaN`则返回。对于φ<0，`-Inf`返回。如果φ> 1，`+Inf`则返回。

##### `holt_winters()`

`holt_winters(v range-vector, sf scalar, tf scalar)`根据中的范围为时间序列生成平滑值`v`。平滑因子越低`sf`，对旧数据的重视程度越高。趋势因子越高`tf`，考虑的数据趋势就越多。二者`sf`并`tf`必须在0和1之间。

`holt_winters` 只能与压力表一起使用。

##### `hour()`

`hour(v=vector(time()) instant-vector)`返回UTC中每个给定时间的一天中的小时。返回值是从0到23。

##### `idelta()`

`idelta(v range-vector)`计算范围向量中最后两个样本之间的差`v`，并返回具有给定增量和等效标签的即时向量。

`idelta` 只能与压力表一起使用。

##### `increase()`

`increase(v range-vector)`计算范围向量中时间序列的增加。单调性中断（例如由于目标重新启动而导致的计数器重置）会自动进行调整。根据范围向量选择器中的指定，可以推断出增加的时间以覆盖整个时间范围，因此，即使计数器仅以整数增量增加，也可能会获得非整数结果。

以下示例表达式返回范围向量中每个时间序列在最近5分钟内测得的HTTP请求数：

```
increase(http_requests_total{job="api-server"}[5m])
```

`increase`仅应与计数器一起使用。它是语法糖`rate(v)`乘以指定时间范围窗下的秒数，应主要用于人类可读性。`rate`在记录规则中使用，以便在每秒的基础上始终跟踪增长情况。

##### `irate()`

`irate(v range-vector)`计算范围向量中时间序列的每秒瞬时增加率。这基于最后两个数据点。单调性中断（例如由于目标重新启动而导致的计数器重置）会自动进行调整。

以下示例表达式返回范围向量中每个时间序列的两个最近数据点的HTTP请求的每秒速率，该速率最多可向后查询5分钟：

```
irate(http_requests_total{job="api-server"}[5m])
```

`irate`仅应在绘制易变，快速移动的计数器时使用。使用`rate`警报和缓慢移动的柜台，因为在房价短暂变化可以重设`FOR`条款和图表完全由罕见尖峰难以阅读。

请注意，当`irate()`与 [聚集运算符](https://prometheus.io/docs/prometheus/latest/querying/operators/#aggregation-operators)（例如`sum()`）或随时间推移聚集的函数（以结尾的任何函数`_over_time`）组合时，请始终`irate()`先执行，然后进行聚合。否则，`irate()`当目标重新启动时，无法检测到计数器重置。

##### `label_join()`

对于中的每个时间序列`v`，`label_join(v instant-vector, dst_label string, separator string, src_label_1 string, src_label_2 string, ...)`将所有`src_labels` using 的所有值结合`separator`在一起，并返回带有`dst_label`包含结合值的标签的时间序列。`src_labels`此功能可以有任意多个。

此示例将返回一个向量，其中每个时间序列都有一个`foo`标签，并在标签上`a,b,c`添加了值：

```
label_join(up{job="api-server",src1="a",src2="b",src3="c"}, "foo", ",", "src1", "src2", "src3")
```

##### `label_replace()`

对于其中的每个时间序列`v`，`label_replace(v instant-vector, dst_label string, replacement string, src_label string, regex string)`将正则表达式`regex`与标签匹配`src_label`。如果匹配，则返回时间序列，并`dst_label`用的扩展名替换 标签`replacement`。`$1`用第一个匹配的子组替换，`$2`再用第二个匹配的子组替换。如果正则表达式不匹配，则时间序列不变。

此示例将返回一个向量，其中每个时间序列都有一个`foo` 标签，并在标签上`a`添加了值：

```
label_replace(up{job="api-server",service="a:c"}, "foo", "$1", "service", "(.*):.*")
```

##### `ln()`

`ln(v instant-vector)`计算中所有元素的自然对数`v`。特殊情况是：

- `ln(+Inf) = +Inf`
- `ln(0) = -Inf`
- `ln(x < 0) = NaN`
- `ln(NaN) = NaN`

##### `log2()`

`log2(v instant-vector)`计算中的所有元素的二进制对数`v`。特殊情况与中的情况相同`ln`。

##### `log10()`

`log10(v instant-vector)`计算中所有元素的十进制对数`v`。特殊情况与中的情况相同`ln`。

##### `minute()`

`minute(v=vector(time()) instant-vector)`返回UTC中每个给定时间的小时分钟。返回值是从0到59。

##### `month()`

`month(v=vector(time()) instant-vector)`返回UTC中每个给定时间的一年中的月份。返回的值是从1到12，其中1表示一月等。

##### `predict_linear()`

```
predict_linear(v range-vector, t scalar)`使用[简单的线性回归](https://en.wikipedia.org/wiki/Simple_linear_regression)`t`，基于范围向量预测从现在开始的时间序列秒值 。`v
```

`predict_linear` 只能与压力表一起使用。

##### `rate()`

`rate(v range-vector)`计算范围向量中时间序列的每秒平均平均增长率。单调性中断（例如由于目标重新启动而导致的计数器重置）会自动进行调整。而且，计算会外推到时间范围的末尾，从而允许遗漏刮擦或刮擦周期与该范围的时间段不完全对齐。

以下示例表达式返回范围向量中每个时间序列在过去5分钟内测得的HTTP请求的每秒速率：

```
rate(http_requests_total{job="api-server"}[5m])
```

`rate`仅应与计数器一起使用。它最适合于警报和慢速计数器的图形显示。

请注意，当`rate()`与聚集运算符（例如`sum()`）或随时间推移聚集的函数（以结尾的任何函数`_over_time`）组合时，请始终`rate()`先执行，然后进行聚合。否则，`rate()`当目标重新启动时，无法检测到计数器重置。

##### `resets()`

对于每个输入时间序列，`resets(v range-vector)`将提供的时间范围内的计数器重置次数作为即时向量返回。两个连续采样之间值的任何减少都将解释为计数器复位。

`resets` 仅应与计数器一起使用。

##### `round()`

`round(v instant-vector, to_nearest=1 scalar)`将所有元素的样本值四舍五入为`v`最接近的整数。领带通过四舍五入解决。可选`to_nearest`参数允许指定样本值应四舍五入到的最接近倍数。该倍数也可以是分数。

##### `scalar()`

给定一个单元素输入向量，`scalar(v instant-vector)`返回该单个元素的样本值作为标量。如果输入向量不完全具有一个元素，`scalar`则将返回`NaN`。

##### `sort()`

`sort(v instant-vector)` 返回按其样本值升序排列的向量元素。

##### `sort_desc()`

与相同`sort`，但以降序排列。

##### `sqrt()`

`sqrt(v instant-vector)`计算中的所有元素的平方根`v`。

##### `time()`

`time()`返回自1970年1月1日UTC以来的秒数。请注意，这实际上并不返回当前时间，而是返回要计算表达式的时间。

##### `timestamp()`

`timestamp(v instant-vector)` 返回给定向量的每个样本的时间戳记，作为自1970年1月1日UTC以来的秒数。

*该功能已在Prometheus 2.0中添加*

##### `vector()`

`vector(s scalar)``s`以没有标签的向量形式返回标量。

##### `year()`

`year(v=vector(time()) instant-vector)` 以UTC为单位返回给定时间的年份。



##### 内置函数详细链接：https://prometheus.io/docs/prometheus/latest/querying/functions/

### 6、简单示例

#### 简单的时间序列选择

返回所有带有指标的时间序列`http_requests_total`：

```
http_requests_total
```

返回所有时间序列以及指标`http_requests_total`和给定 `job`和`handler`标签：

```
http_requests_total{job="apiserver", handler="/api/comments"}
```

返回相同向量的整个时间范围（在本例中为5分钟），使其成为范围向量：

```
http_requests_total{job="apiserver", handler="/api/comments"}[5m]
```

请注意，无法直接绘制导致范围向量的表达式，而是在表达式浏览器的表格视图（“控制台”）中查看。

使用正则表达式，您只能选择名称与特定模式匹配的作业的时间序列，在这种情况下，所有以结尾的作业`server`：

```
http_requests_total{job=~".*server"}
```

Prometheus中的所有正则表达式都使用[RE2语法](https://github.com/google/re2/wiki/Syntax)。

要选择除4xx之外的所有HTTP状态代码，可以运行：

```
http_requests_total{status!~"4.."}
```

#### 子查询

返回`http_requests_total`过去30分钟内指标的5分钟速率，分辨率为1分钟。

```
rate(http_requests_total[5m])[30m:1m]
```

这是一个嵌套子查询的示例。该`deriv`函数的子查询使用默认分辨率。请注意，不必要地使用子查询是不明智的。

```
max_over_time(deriv(rate(distance_covered_total[5s])[30s:5s])[10m:])
```

#### 使用函数，运算符等

返回所有`http_requests_total` 度量标准名称的时间序列的每秒速率，以最近5分钟为单位：

```
rate(http_requests_total[5m])
```

假设`http_requests_total`时间序列都具有标签`job` （按作业名称进行扇出）和`instance`（按作业实例进行扇出），我们可能希望对所有实例的比率求和，因此得到的输出时间序列较少，但仍保留`job`维度：

```
sum by (job) (
  rate(http_requests_total[5m])
)
```

如果我们有两个具有相同维标签的不同度量，则可以对它们应用二元运算符，并且具有相同标签集的两侧的元素都将匹配并传播到输出。例如，此表达式为每个实例返回MiB中未使用的内存（在虚构的群集调度程序上，它公开了有关其运行的实例的这些指标）：

```
(instance_memory_limit_bytes - instance_memory_usage_bytes) / 1024 / 1024
```

相同的表达式，但由应用程序求和，可以这样写：

```
sum by (app, proc) (
  instance_memory_limit_bytes - instance_memory_usage_bytes
) / 1024 / 1024
```

如果相同的虚拟群集调度程序针对每个实例公开了以下CPU使用率指标：

```
instance_cpu_time_ns{app="lion", proc="web", rev="34d0f99", env="prod", job="cluster-manager"}
instance_cpu_time_ns{app="elephant", proc="worker", rev="34d0f99", env="prod", job="cluster-manager"}
instance_cpu_time_ns{app="turtle", proc="api", rev="4d3a513", env="prod", job="cluster-manager"}
instance_cpu_time_ns{app="fox", proc="widget", rev="4d3a513", env="prod", job="cluster-manager"}
...
```

...我们可以按应用程序（`app`）和进程类型（`proc`）将前3个CPU用户分组，如下所示：

```
topk(3, sum by (app, proc) (rate(instance_cpu_time_ns[5m])))
```

假设此指标每个运行实例包含一个时间序列，则可以像这样计算每个应用程序的运行实例数：

```
count by (app) (instance_cpu_time_ns)
```



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

# 三、prometheus中API查询

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


