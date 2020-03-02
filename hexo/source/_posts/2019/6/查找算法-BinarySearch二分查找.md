---
title: 查找算法-BinarySearch二分查找
date: 2019-06-01
tags: []
categories: 算法
---

二分查找利用已排好序的数组，每一次查找都可以将查找范围减半。查找范围内只剩一个数据时查找结束。 
<!--more-->

# 二分查找算法简介
* 二分查找利用已排好序的数组，每一次查找都可以将查找范围减半。查找范围内只剩一个数据时查找结束。 
* 数据量为n 的数组，将其长度减半log2(n) 次后，其中便只剩一个数据了。
* 也就是说， 在二分查找中重复执行将`目标数据`和数组`中间的数据`进行比较后将查找`范围减半`的 操作log2(n)次后，就能找到目标数据（若没找到则可以得出数据不存在的结论），因此它 的时间复杂度为 O(logn)。

# 二分查找的复杂度
 二分查找的时间复杂度为`O(logn)`，与线性查找的O(n) 相比速度上得到了指数倍提高（x=log2(n)，则 n=2^x）。 

# 二分查找算法的局限性
二分查找必须建立在`数据已经排好序`的基础上才能使用，因此添加数据时必须加到合适的位置，这就需要额外耗费维护数组的时间。 
而使用线性查找时，数组中的数据可以是无序的，因此添加数据时也无须顾虑位置，直接把它加在末尾即可，不需要耗费时间。
>具体使用哪种查找方法，可以根据`查找`和`添加`两个操作哪个更为频繁来决定。

# 算法实现
```java
  @Test
    public void test_bsearch() {
        int a[] = new int[]{1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

        int[] search = new int[]{0, 1, 2, 7, 11};
        for (int s : search) {
            System.out.println(String.format("begin Rsearch[%s]", s));
            int idx = bsearch_recurse(a, 0, a.length - 1, s);
            System.out.println(String.format("end Rsearch[%s],index[%s]", s, idx));
        }

        for (int s : search) {
            System.out.println(String.format("begin Lsearch[%s]", s));
            int idx = bsearch_while(a, s);
            System.out.println(String.format("end Lsearch[%s],index[%s]", s, idx));
        }
    }

    /***
     * 递归实现二分查找
     * @param a 目标数组
     * @param from 开始索引
     * @param to 结果索引
     * @param tar 查找目标
     * @return 目标索引，查不到返回-1
     */
    public int bsearch_recurse(int[] a, int from, int to, int tar) {
        System.out.println(String.format("search from[%s],to[%s]", from, to));
        if (from > to || tar < a[from] || tar > a[to]) {
            return -1;
        } else if (tar == a[from]) {
            return from;
        } else if (tar == a[to]) {
            return to;
        } else {
            int m = (to + from) / 2;
            if (tar > a[m]) {
                return bsearch_recurse(a, m, to, tar);
            } else if (tar < a[m]) {
                return bsearch_recurse(a, from, m, tar);
            } else {
                return m;
            }
        }
    }


    /***
     *循环实现二分查找
     * @param a 目标数组
     * @param tar 查找目标
     * @return 目标索引，查不到返回-1
     */
    public int bsearch_while(int[] a, int tar) {
        int from = 0;
        int to = a.length - 1;
        if (to < 0 || tar < a[from] || tar > a[to]) {
            return -1;
        } else if (tar == a[from]) {
            return from;
        } else if (tar == a[to]) {
            return to;
        } else {
            int m = 0;
            while (from <= to) {
                m = (to + from) / 2;
                System.out.println(String.format("search from[%s],to[%s]", from, to));
                if (tar < a[m]) {
                    to = m - 1;
                } else if (tar > a[m]) {
                    from = m + 1;
                } else {
                    return m;
                }
            }
        }
        return -1;
    }
```

