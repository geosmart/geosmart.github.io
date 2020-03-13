---
title: 二叉树BFS-锯齿遍历
date: 2019-06-01
tags: [Tree]
categories: 数据结构
---

>二叉树锯齿状遍历实现
给定一个二叉树，返回其节点值的锯齿形层次遍历。（即先从左往右，再从右往左进行下一层遍历，以此类推，层与层之间交替进行）。

<!--more-->

例如：
给定二叉树 [3,9,20,null,null,15,7],
返回锯齿形层次遍历如下：[[3], [20,9], [15,7]]

# 应用场景
 
# 实现方式
## 利用外部队列遍历
算法思想：广度优先搜索BFS+双端队列
1. 以一个双端队列存储节点，插入和删除仅限在两端操作；
2. 层与层之间LIFO，FILO交叉，正好满足一层正序，一层反序；
3. 当前层遍历完后再从队列获取节点，遍历下一层;
4. 队列为空时完成树的遍历；

## 递归逐层遍历

# 代码实现
```java
import java.util.ArrayList;
import java.util.Deque;
import java.util.LinkedList;
import java.util.List;
  
    /**
     * 层与层之间LIFO，FILO交叉，正好满足一层正序，一层反序；
     */
    public static List<List<Integer>> zigzagLevelOrder(TreeNode root) {
        List<List<Integer>> levels = new ArrayList<>();
        if (root == null) {
            return levels;
        }
        return BFS(root, levels);
    }

    private static List<List<Integer>> BFS(TreeNode root, List<List<Integer>> levels) {
        Deque<TreeNode> deque = new LinkedList<>();
        deque.addLast(root);
        int level = 0;

        //遍历方向需隔层反转
        boolean reverse = true;
        while (deque.size() > 0) {
            levels.add(new ArrayList<>());
            int queueSize = deque.size();
            for (int i = 0; i < queueSize; i++) {
                TreeNode node;
                if (reverse) {
                    //last in first out(先left再right)
                    node = deque.removeFirst();
                    if (node.left != null) {
                        deque.addLast(node.left);
                    }
                    if (node.right != null) {
                        deque.addLast(node.right);
                    }
                } else {
                    //first in last out （先right再left）
                    node = deque.removeLast();
                    if (node.right != null) {
                        deque.addFirst(node.right);
                    }
                    if (node.left != null) {
                        deque.addFirst(node.left);
                    }
                }
                levels.get(level).add(node.val);
                System.out.println(level + ",node-" + node.val);
            }
            reverse = !reverse;
            level++;
        }
        return levels;
    }

```