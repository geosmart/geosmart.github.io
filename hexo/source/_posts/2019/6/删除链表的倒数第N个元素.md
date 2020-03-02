---
title: 删除链表的倒数第N个元素
date: 2019-06-01
tags: []
categories: 数据结构
---

给定一个链表，删除链表的倒数第 n 个节点，并且返回链表的头结点。
<!--more-->


# 单链表
查找复杂度O(n)，删除O(1)，新增O(1)，
实际生产中，一般使用双向链表，空间换时间，但更实用；
比如这个查找倒数第n个节点的问题，
* 单链表需要2个指针以不同速度遍历1次实现，或者是需要完全遍历2次；
* 双向链表只需遍历1次到达尾节点，再往前遍历n次就可以完成任务；

# 2个指针删除倒数第N个元素的复杂度
* 时间复杂度：O(L)，该算法对含有 L个结点的列表进行了一次遍历。
* 空间复杂度：O(1)，只用了常量级的额外空间。

# 代码 
``` java
  
    /**
     * 2次遍历删倒数第n个节点，即删L-n+1个节点，转换为寻找L-n节点问题
     * 第1次遍历获得链表长度L，L-n+1即为要删的节点
     * 第2次遍历到第L-n节点，指向L-n+1.next节点，即完成删除L-n+1节点；
     *
     * @param head 头节点指针
     * @param n    倒数第n个节点
     * @return 头部指针
     */
    public static ListNode removeNthFromEnd2(ListNode head, int n) {
        ListNode dummy = new ListNode(0);
        dummy.next = head;
        ListNode p = dummy;
        int len = 0;
        while (p.next != null) {
            p = p.next;
            len++;
        }
        p = dummy;
        len -= n;
        while (len > 0) {
            len--;
            p = p.next;
        }
        p.next = p.next.next;
        return dummy.next;
    }

    /**
     * 快慢指针，遍历一次，设链表长度为L，删倒数第n个节点，即删L-n+1个节点，转换为寻找L-n节点问题
     * 链表头部新增1个虚拟节点指向头节点，快q慢s指针都从虚拟节点开始；
     * 1.从虚拟节点开始遍历，s指针比q指针慢n+1步（间隔n个节点）
     * 2.快指针q到达链表尾部(null)时，慢指针s到达倒数第L-n个节点
     * 3.将第L-n个节点的next指向第L-n+1.next，即完成删除第L-n+1个节点；
     *
     * @param head 头节点指针
     * @param n    倒数第n个节点
     * @return 头部指针
     */
    public static ListNode removeNthFromEnd(ListNode head, int n) {
        //虚拟结点，用来简化某些极端情况，例如列表中只含有一个结点，或需要删除列表的头部。
        ListNode dummy = new ListNode(0);
        dummy.next = head;
        ListNode q = dummy;
        ListNode s = dummy;
        for (int i = 0; i < n + 1; i++) {
            q = q.next;
        }
        while (q != null) {
            s = s.next;
            q = q.next;
        }
        s.next = s.next.next;
        return dummy.next;
    }

    /***
     * 根据数组构建链表
     * @param vals 数组
     * @return 链表头节点
     */
    public static ListNode newSingleLinkedList(int[] vals) {
        ListNode[] nodes;
        nodes = new ListNode[vals.length];
        for (int i = 0; i < vals.length; i++) {
            if (nodes[i] == null) {
                nodes[i] = new ListNode(vals[i]);
            }
            if (i < vals.length - 1) {
                nodes[i + 1] = new ListNode(vals[i + 1]);
                nodes[i].next = nodes[i + 1];
            }
        }
        return nodes[0];
    }

    /***
     * 单链表节点
     */
    public static class ListNode {
        int val;
        ListNode next;

        public ListNode(int val) {
            this.val = val;
        }

        public void printNode() {
            ListNode printNode = this;
            StringBuilder sb = new StringBuilder();
            while (printNode != null) {
                sb.append("-->").append(printNode.val);
                printNode = printNode.next;
            }
            System.out.println(sb);
        }
    }
```
