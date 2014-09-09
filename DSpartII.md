Data Science(part II)
========================================================

# Getting and Cleaning Data

## 概述

> Raw data -> Processing script -> tidy data

- 前期需求
  - 原始数据
  - 干净数据
  - code book
  - 详尽的处理步骤记录
- 原始数据要求
  - 未经处理
  - 未经修改
  - 未经去除异常值
  - 未经总结
- 干净数据
  - 每个变量一列
  - 同一变量不同样本不在一行
  - 一种变量一个表
  - 多张表要有一列可以相互链接
  - 有表头
  - 变量名要有意义
  - 一个文件一张表
- code book
  - 变量信息
  - 总结方式
  - 实验设计
  - 文本文件
  - 包含研究设计与变量信息的章节
- 处理步骤记录
  - 脚本文件
  - 输入为原始数据
  - 输出为处理过数据
  - 脚本中无特定参数

## 下载

- 设定工作目录与数据存储目录


```r
if (!file.exists("data")) {
    dir.create("data")
}
```


- url下载与时间记录


```r
fileUrl <- "yoururl"
download.file(fileUrl, destfile = "./data/XXX.csv", method = "curl")
list.files("./data")
dateDownloaded <- date()
```


## 读取本地文件

- `read.table`
- `read.csv` 默认`sep=",", header=TRUE`
- `quote` 设定引用
- `na.strings` 设定缺失值字符
- `nrows` 设定读取字段
- `skip` 跳过开始行数

## 读取excle文件

- xlsx包


```r
library(xlsx)
cameraData <- read.xlsx("./data/cameras.xlsx", sheetIndex = 1, header = TRUE)
head(cameraData)
# read.xlsx2更快不过选行读取时会不稳定 支持底层读取 如字体等
```


- XLConnect包


```r
library(XLConnect)
wb <- loadWorkbook("XLConnectExample1.xlsx", create = TRUE)
createSheet(wb, name = "chickSheet")
writeWorksheet(wb, ChickWeight, sheet = "chickSheet", startRow = 3, startCol = 4)
saveWorkbook(wb)
# 支持区域操作 生成报告 图片等
```


## 读取XML文件

- 网页常用格式
- 形式与内容分开
- 形式包括标签 元素 属性等
- XML包


```r
library(XML)
fileUrl <- "http://www.w3schools.com/xml/simple.xml"
# 读取xml结构
doc <- xmlTreeParse(fileUrl, useInternal = TRUE)
# 提取节点
rootNode <- xmlRoot(doc)
# 提取根节点名
xmlName(rootNode)
# 提取子节点名
names(rootNode)
# 提取节点数值
xmlSApply(rootNode, xmlValue)
```


- XPath XML的一种查询语法
  - /node 顶级节点
  - //node 所有子节点
  - node[@attr-name] 带属性名的节点
  - node[@attr-name='bob'] 属性名为bob的节点


```r
# 提取节点下属性名为name的数值
xpathSApply(rootNode, "//name", xmlValue)
```


## 读取json文件

- js对象符号 结构化 常作为API输出格式
- jsonlite包


```r
library(jsonlite)
# 读取json文件
jsonData <- fromJSON("https://api.github.com/users/jtleek/repos")
# 列出文件名
names(jsonData)
# 可嵌套截取
jsonData$owner$login
# 可将R对象写成json文件
myjson <- toJSON(iris, pretty = TRUE)

```


## 读取MySQL数据库

- 网络应用常见数据库软件
- 一行一记录
- 数据库表间有index向量
- [常见命令](http://www.pantz.org/software/mysql/mysqlcommands.html)
- [指南](http://www.r-bloggers.com/mysql-and-r/)
- RMySQL包


```r
library(RMySQL)
# 读取数据库
ucscDb <- dbConnect(MySQL(), user = "genome", host = "genome-mysql.cse.ucsc.edu")
result <- dbGetQuery(ucscDb, "show databases;")
# 断开链接
dbDisconnect(ucscDb)
# 读取指定数据库
hg19 <- dbConnect(MySQL(), user = "genome", db = "hg19", host = "genome-mysql.cse.ucsc.edu")
allTables <- dbListTables(hg19)
length(allTables)
# mysql语句查询
dbGetQuery(hg19, "select count(*) from affyU133Plus2")
# 选择子集
query <- dbSendQuery(hg19, "select * from affyU133Plus2 where misMatches between 1 and 3")
affyMis <- fetch(query)
quantile(affyMis$misMatches)
```


## 读取HDF5数据

- 分层分组读取大量数据的格式
- rhdf5包


```r
library(rhdf5)
created = h5createFile("example.h5")
created = h5createGroup("example.h5", "foo")
created = h5createGroup("example.h5", "baa")
created = h5createGroup("example.h5", "foo/foobaa")
h5ls("example.h5")
A = matrix(1:10, nr = 5, nc = 2)
h5write(A, "example.h5", "foo/A")
B = array(seq(0.1, 2, by = 0.1), dim = c(5, 2, 2))
attr(B, "scale") <- "liter"
h5write(B, "example.h5", "foo/foobaa/B")
h5ls("example.h5")
df = data.frame(1L:5L, seq(0, 1, length.out = 5), c("ab", "cde", "fghi", "a", 
    "s"), stringsAsFactors = FALSE)
h5write(df, "example.h5", "df")
h5ls("example.h5")
readA = h5read("example.h5", "foo/A")
readB = h5read("example.h5", "foo/foobaa/B")
readdf = h5read("example.h5", "df")
```


## 读取网页数据

- 网页抓取HTML数据
- 读完了一定关链接
- httr包


```r
con = url("http://scholar.google.com/citations?user=HI-I6C0AAAAJ&hl=en")
htmlCode = readLines(con)
close(con)
htmlCode
library(XML)
url <- "http://scholar.google.com/citations?user=HI-I6C0AAAAJ&hl=en"
html <- htmlTreeParse(url, useInternalNodes = T)
xpathSApply(html, "//title", xmlValue)
library(httr)
html2 = GET(url)
content2 = content(html2, as = "text")
parsedHtml = htmlParse(content2, asText = TRUE)
xpathSApply(parsedHtml, "//title", xmlValue)
GET("http://httpbin.org/basic-auth/user/passwd")
GET("http://httpbin.org/basic-auth/user/passwd", authenticate("user", "passwd"))
google = handle("http://google.com")
pg1 = GET(handle = google, path = "/")
pg2 = GET(handle = google, path = "search")
```


## 读取API

- 通过接口授权后调用数据
- httr包


```r
myapp = oauth_app("twitter", key = "yourConsumerKeyHere", secret = "yourConsumerSecretHere")
sig = sign_oauth1.0(myapp, token = "yourTokenHere", token_secret = "yourTokenSecretHere")
homeTL = GET("https://api.twitter.com/1.1/statuses/home_timeline.json", sig)
json1 = content(homeTL)
json2 = jsonlite::fromJSON(toJSON(json1))
```


## 读取其他资源

- 图片
  - [jpeg](http://cran.r-project.org/web/packages/jpeg/index.html)
  - [readbitmap](http://cran.r-project.org/web/packages/readbitmap/index.html)
  - [png](http://cran.r-project.org/web/packages/png/index.html)
  - [EBImage (Bioconductor)](http://www.bioconductor.org/packages/2.13/bioc/html/EBImage.html)

- GIS
  - [rdgal](http://cran.r-project.org/web/packages/rgdal/index.html)
  - [rgeos](http://cran.r-project.org/web/packages/rgeos/index.html)
  - [raster](http://cran.r-project.org/web/packages/raster/index.html)

- 声音
  - [tuneR](http://cran.r-project.org/web/packages/tuneR/)
  - [seewave](http://rug.mnhn.fr/seewave/)

## 数据截取与排序

- 增加行直接`$`
- `seq`产生序列
- 通过`[`按行 列或条件截取
- `which`返回行号
- 排序向量用`sort`
- 排序数据框(多向量)用`order`
- [plyl包](http://plyr.had.co.nz/09-user/)排序


```r
library(plyr)
arrange(X, var1)
arrange(X, desc(var1))
```


## 数据总结

- `head` `tail`查看数据
- `summary` `str`总结数据
- `quantile` 按分位数总结向量
- `table` 按向量元素频数总结
- `sum(is.na(data))` `any(is.na(data))` `all(data$x > 0)` 异常值总结
- `colSums(is.na(data))` 行列求和
- `table(data$x %in% c("21212"))`特定数值计数总结
- `xtabs` `ftable` 创建列联表
- `print(object.size(fakeData),units="Mb")` 现实数据大小
- `cut` 通过设置`breaks`产生分类变量
- Hmisc包


```r
library(Hmisc)
data$zipGroups = cut2(data$zipCode, g = 4)
table(data$zipGroups)
library(plyr)
# mutate进行数据替换或生成
data2 = mutate(data, zipGroups = cut2(zipCode, g = 4))
table(data2$zipGroups)
```


## 数据整理

- 每一列一个变量
- 每一行一个样本
- 每个文件存储一类样本
- `melt`进行数据融合
- [`reshape2`包](http://www.slideshare.net/jeffreybreen/reshaping-data-in-r)
- `dcast`分组汇总数据框
- `acast`分组汇总向量数组
- `arrange`指定变量名排序
- `merge`按照指定向量合并数据
- plyr包的`join`函数也可实现合并

## [*数据操作data.table包*](https://github.com/raphg/Biostat-578/blob/master/Advanced_data_manipulation.Rpres)

- 基本兼容`data.frame`
- 速度更快
- 通过`key`可指定因子变量并快速提取分组的行
- 可在第二个参数是R表达式


```r
DT[, list(mean(x), sum(z))]
DT[, table(y)]
```


- 可用`:`生成新变量 进行简单计算


```r
DT[, `:=`(w, z^2)]
DT[, `:=`(m, {
    tmp <- (x + z)
    log2(tmp + 5)
})]
```


- 进行数据条件截取


```r
DT[, `:=`(a, x > 0)]
DT[, `:=`(b, mean(x + w)), by = a]
```


- 进行计数


```r
DT <- data.table(x = sample(letters[1:3], 1e+05, TRUE))
DT[, .N, by = x]
```


## 文本处理

- 处理大小写`tolower` `toupper`
- 处理变量名`strsplit`


```r
firstElement <- function(x) {
    x[1]
}
sapply(splitNames, firstElement)
```


- 字符替换`sub` `gsub`
- 寻找变量`grep`(返回行号) `grepl`(返回逻辑值)
- stringr包 `stringr` 
- `paste0` 不带空格
- `str_trim` 去除空格
- 命名原则
  - 变量名小写
  - 描述性
  - 无重复
  - 变量名不要符号分割
  - Names of variables should be
- 正则表达式
  - 文字处理格式
  - `^` 匹配开头
  - `$` 匹配结尾
  - `[]` 匹配大小写 `^`在开头表示非
  - `.` 匹配任意字符
  - `|` 匹配或
  - `()` 匹配与
  - `?` 匹配可选择
  - `*` 匹配任意
  - `+` 匹配至少一个
  - `{}` 匹配其中最小最大 一个值表示精确匹配 `m,`表示至少m次匹配
  - `\1` 匹配前面指代

## 日期处理

- `formate`处理日期格式
  - `%d` 日 
  - `%a` 周缩写
  - `%A` 周
  - `%m` 月
  - `%b` 月缩写
  - `%B` 月全名
  - `%y` 2位年
  - `%Y` 4位年
- `weekdays` 显示星期
- `months` 显示月份
- `julian` 显示70年以来的日期
- [lubridate包](http://cran.r-project.org/web/packages/lubridate/vignettes/lubridate.html)
  - `ymd`
  - `mdy`
  - `dmy`
  - `ymd_hms`
  - `Sys.timezone`
