---
title: 二叉树BFS-分层遍历
date: 2019-06-01
tags: [Tree]
categories: 数据结构
---

>二叉树分层遍历实现，
给定一个二叉树，返回其按层次遍历的节点值。 （即逐层地，从左到右访问所有节点）。
<!--more-->

例如:
给定二叉树: [3,9,20,null,null,15,7],
返回其层次遍历结果：[[3],[9,20],[15,7]]
# 应用场景
 
# 实现方式
## 利用外部队列遍历
算法思想：广度优先搜索BFS
1. 以一个FIFO的队列存储节点；
2. 在遍历当前层时，把当前层的左右子节点入队;
3. 当前层遍历完后再从队列获取节点，遍历下一层;
4. 队列为空时完成树的遍历；

## 递归逐层遍历

# 代码实现
```java
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

    /***
     * 利用外部队列遍历
     */
    public static List<List<Integer>> levelOrder_queue(TreeNode root) {
        if (root == null) {
            return levels;
        }
        Queue<TreeNode> queue = new LinkedList<>();
        queue.add(root);

        int level = 0;
        while (!queue.isEmpty()) {
            // start the current level
            levels.add(new ArrayList<>());

            //当前层的元素大小=队列大小
            int level_length = queue.size();
            // 循环只处理当前层的元素
            for (int i = 0; i < level_length; ++i) {
                TreeNode node = queue.remove();

                //元素加入当前层所在数组
                levels.get(level).add(node.val);

                //当前层级的子节点加入队列，下一层会处理
                if (node.left != null) {
                    queue.add(node.left);
                }
                if (node.right != null) {
                    queue.add(node.right);
                }
            }
            // go to next level
            level++;
        }
        return levels;
    }

    /***
     * 递归逐层遍历
     */
    public static List<List<Integer>> levelOrder_recurse(TreeNode root) {
        if (root == null) {
            return levels;
        }
        helper(root, 0);
        return levels;
    }

    private static void helper(TreeNode node, int level) {
        if (levels.size() == level) {
            //当前层初始化
            levels.add(new ArrayList<Integer>());
        }
        levels.get(level).add(node.val);

        //递归左子树
        if (node.left != null) {
            helper(node.left, level + 1);
        }
        //递归右子树
        if (node.right != null) {
            helper(node.right, level + 1);
        }
    }

```