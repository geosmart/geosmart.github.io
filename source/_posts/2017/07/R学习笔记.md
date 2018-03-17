---
title: R学习笔记
date: 2017-07-04 08:13:38
tags: [R]
categories: 人工智能
---

>R is a tool for statistics and data modeling. The R programming language is elegant, versatile, and has a highly expressive syntax designed around working with data. R is more than that, though — it also includes extremely powerful graphics capabilities.

- - -
<!-- more --> 

[Try R](http://tryr.codeschool.com/)

# 变量
定义： x<-42，x赋值为42

# 向量（Vectors）
定义： c(1,T,"three")
## Sequence Vectors
输入：seq(5,9)或5:9
输出：[1] 5 6 7 8 9

## 设置步长-increments 
```R
>seq(5,9,0.5)
[1] 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.5 9.0
```

## 向量访问
```R
> sentence <- c('walk', 'the', 'plank')
```

* 索引访问:R索引从1开始 
```R
> sentence[3]
[1] "plank" 
```

* 定义向量访问： 
```R
> sentence[c(1,3)]
[1] "walk" "dog"  
```

* 范围访问： 
```R
> sentence[2:4]  
[1] "the" "dog" "to" 
```
## 修改向量值  
* 单个修改
```R
> sentence[3]<-"dog"
```
* 批量修改
```R
> sentence[5:7]<-c('the','poop','deck')
```


* 新增向量
```R
 sentence[4]<-"to"
```

# 绘图
barplot直方图
```R
> vesselsSunk <- c(4, 5, 1)
> barplot(vesselsSunk)
```

scatter plots散点图
```R
> values <- -10:10
> absolutes <- abs(values)
> plot(values, absolutes)
```

# NA
```R
> a <- c(1, 3, NA, 7, 9)
> sum(a)
[1] NA
> sum(a,na.rm=T)
[1] 20
```

#  matrix
定义：3行4列，值都为0
matrix(0,3,4)

升维：dim设置matrix维度
```R
> plank  <- 1:8
> dim(plank) <- c(2,4)
> print(plank)
     [,1] [,2] [,3] [,4]
[1,]    1    3    5    7
[2,]    2    4    6    8
```

赋值：> plank[1,4] <- 0

## matrix访问
```R
> print(plank)
     [,1] [,2] [,3] [,4]
[1,]    1    3    5    7
[2,]    2    4    6    8
```

* 单个元素
```R
> plank[2,3]
[1] 6
```
* 列
```R
> plank[,4]
[1] 7 8
```

* 指定范围
```R
> plank[,2:4]
     [,1] [,2] [,3]
[1,]    3    5    7
[2,]    4    6    8
```

## 绘图
```R
> elevation <- matrix(1, 10, 10)
> elevation[4, 6] <- 0
```

* 轮廓图
```R
> contour(elevation)
```

* 三维轮廓图
```R
> persp(elevation)
> persp(elevation, expand=0.2)
```

# 统计函数
## Mean 平均值
```R
limbs <- c(4, 3, 4, 3, 2, 4, 4, 4)
names(limbs) <- c('One-Eye', 'Peg-Leg', 'Smitty', 'Hook', 'Scooter', 'Dan', 'Mikey', 'Blackbeard')
> mean(limbs)
# 平均值柱状图
> barplot(limbs)
# 平均值柱状图 + 平均值水平线
> abline(h=mean(limbs)
```

## Median 中位数
```R
> limbs <- c(4, 3, 4, 3, 2, 4, 4, 14)
> names(limbs) <- c('One-Eye', 'Peg-Leg', 'Smitty', 'Hook', 'Scooter', 'Dan', 'Mikey', 'Davy Jones')
> mean(limbs)
[1] 4.75
> barplot(limbs)
> abline(h = mean(limbs))
```

>It may be factually accurate to say that our crew has an average of 4.75 limbs, but it's probably also misleading.
For situations like this, it's probably more useful to talk about the "median" value.   
The median is calculated by sorting the values and choosing the middle one (for sets with an even number of values, the middle two values are averaged).

```R
> median(limbs)
[1] 4
```

## Standard Deviation 标准偏差
>Statisticians use the concept of "standard deviation" from the mean to describe the range of typical values for a data set. For a group of numbers, it shows how much they typically vary from the average value. To calculate the standard deviation, you calculate the mean of the values, then subtract the mean from each number and square the result, then average those squares, and take the square root of that average.

# Data Frames
>R has a structure for just this purpose: the data frame. You can think of a data frame as something akin to a database table or an Excel spreadsheet. It has a specific number of columns, each of which is expected to contain values of a particular type. It also has an indeterminate number of rows - sets of related values for each column.

```R
> treasure <- data.frame(weights, prices, types)
> print(treasure)
  weights prices  types
1     300   9000   gold
2     200   5000 silver
3     100  12000   gems
4     250   7500   gold
5     150  18000   gems
```

## 数据访问
```R
> treasure[[2]]
[1]  9000  5000 12000  7500 18000

> treasure[["weights"]]
[1] 300 200 100 250 150

> treasure$prices
[1]  9000  5000 12000  7500 18000 
```


# 文件IO
```R
> piracy <- read.csv("piracy.csv")
> gdp <- read.table("gdp.txt", sep="  ", header=TRUE)
```

# 数据分析
## cor.test
R can test for correlation between two vectors with the cor.test function. 
```R
> cor.test(countries$GDP, countries$Piracy)
```

## lm
if we calculate the linear model that best represents all our data points (with a certain degree of error).   
The lm function takes a model formula, which is represented by a response variable (piracy rate), a tilde character (~), and a predictor variable (GDP). (Note that the response variable comes first.)

```R
> line <- lm(countries$Piracy ~ countries$GDP)
> abline(line)
```

# 扩展安装
install.packages("ggplot2")
