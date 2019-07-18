---
title: AVL
date: 2017-10-11
tags: []
categories: 04数据结构
---





# AVL
>The AVL tree is named after its two Soviet inventors, Georgy `A`delson-`V`elsky and Evgenii `L`andis, who published it in their 1962 paper "`An algorithm for the organization of information`".

> An AVL tree is a `self-balancing binary search tree`, and it was the `first` such data structure to be invented. 
> In an AVL tree, the heights of the two child subtrees of any node differ by at most one. 
> AVL trees are often compared with red-black trees because they support the same set of operations and because `red-black trees` also take `O(log n)` time for the basic operations. Because AVL trees are more `rigidly balanced`, they are `faster than red-black trees for lookup intensive applications`. 
> However, `red-black trees are faster for insertion and removal`.

## AVL Tree的性质
* 任意一个结点的key，比它的lesserChild的key大，比它的greaterChild的key小；
* 任意结点的孩子结点之间高度差距最大为1；

## 平衡检测
对于一棵树来说，它的`高度(height)`定义如下：
>从根节点(root)开始到某一个叶子节点(leaf)的最长路径(path)上结点的个数

根据AVL树的定义，我们可以为所有的结点定义一个`平衡因子(balanced factor)`：
>某个结点的平衡因子等于该节点的greaterHeight的高度减去lesserHeight的高度

根据平衡树的定义，计算得到的平衡因为会出现两种情况：
* 如果平衡因子是`0, 1, -1` 这三个数的话，可以认定该节点是符合平衡树的定义的；
* 否则，该结点不平衡，需要重新平衡；
对于一个BST来说，`每次插入的元素只可能放在叶子结点上。所以只能影响某个子树是否平衡，对其他子树不会有任何的影响。`
在这种情况下，我们只需要根据搜索的路径，从孩子往祖先找，如果有不平衡的结点就可以被找到。如果一直到根结点都没有发现不平衡结点，则可以认为这次的插入操作没有造成树的不平衡。
 
## AVL保持平衡操作
如果发现了某个不平衡的结点，那么就需要对该结点进行重平衡。实现重平衡的方法，是对该节点的子树进行`旋转(rotation)`。
旋转有两种情况，如下图所示：
* 一种称为左旋转(关于X结点的左旋转);
* 一种称为右旋转(关于Y结点的右旋转); 
AVL树的旋转实际可以用4种情况表达：LL,RR,LR,RL。LL型时单向右旋，RR时单向左旋；LR,RL时双向旋转（先左后右、先右后左)。
![AVL树的旋转](AVL树的旋转.png)

## AVL的结构
AVL树节点-父类
```java
 protected static class Node<T extends Comparable<T>> {
        protected T id = null;
        protected Node<T> parent = null;
        protected Node<T> lesser = null;
        protected Node<T> greater = null;
        protected Node(Node<T> parent, T id) {
            this.parent = parent;
            this.id = id;
        }
    }
```

AVL树节点
```java
protected static class AVLNode<T extends Comparable<T>> extends Node<T> {
        protected int height = 1;
        protected AVLNode(Node<T> parent, T value) {
            super(parent, value);
        }
        //是否叶子节点
        protected boolean isLeaf() {
            return ((lesser == null) && (greater == null));
        }
        //更新节点height
        protected int updateHeight() {
            int lesserHeight = 0;
            if (lesser != null) {
                AVLNode<T> lesserAVLNode = (AVLNode<T>) lesser;
                lesserHeight = lesserAVLNode.height;
            }
            int greaterHeight = 0;
            if (greater != null) {
                AVLNode<T> greaterAVLNode = (AVLNode<T>) greater;
                greaterHeight = greaterAVLNode.height;
            }

            if (lesserHeight > greaterHeight) {
                height = lesserHeight + 1;
            } else {
                height = greaterHeight + 1;
            }
            return height;
        }

        /**
         *获取节点平衡因子
         * 
         * @return 左孩子比有孩子长时，平衡因子小于0
         */
        protected int getBalanceFactor() {
            int lesserHeight = 0;
            if (lesser != null) {
                AVLNode<T> lesserAVLNode = (AVLNode<T>) lesser;
                lesserHeight = lesserAVLNode.height;
            }
            int greaterHeight = 0;
            if (greater != null) {
                AVLNode<T> greaterAVLNode = (AVLNode<T>) greater;
                greaterHeight = greaterAVLNode.height;
            }
            return greaterHeight - lesserHeight;
        }
    }
```
    
## AVL树的增删改查
### 新增节点
```java
protected Node<T> addValue(T id) {
    //新增节点（lesser/greater）
    Node<T> nodeToReturn = super.addValue(id);
    AVLNode<T> nodeAdded = (AVLNode<T>) nodeToReturn;
    //更新节点高度
    nodeAdded.updateHeight();
    //平衡树
    balanceAfterInsert(nodeAdded);
	
	//从当前新增节点，自下而上遍历，更新节点height，对不平衡节点进行旋转操作，使树保存平衡
    nodeAdded = (AVLNode<T>) nodeAdded.parent;
    while (nodeAdded != null) {
        int h1 = nodeAdded.height;

        nodeAdded.updateHeight();
        balanceAfterInsert(nodeAdded);

        // If height before and after balance is the same, stop going up the tree
        int h2 = nodeAdded.height;
        if (h1==h2)
            break;

        nodeAdded = (AVLNode<T>) nodeAdded.parent;
    }
    return nodeToReturn;
}
```

### AVL树平衡
```java
/**
 * 插入node时，执行平衡AVL树
 * 
 * @param node 子树的根节点
 */
private void balanceAfterInsert(AVLNode<T> node) {
	//获取平衡因子，如果不为-1,0,1，则需进行平衡处理
    int balanceFactor = node.getBalanceFactor();
    if (balanceFactor > 1 || balanceFactor < -1) {
        AVLNode<T> child = null;
        Balance balance = null;
        //左孩子长
        if (balanceFactor < 0) {
            child = (AVLNode<T>) node.lesser;
            balanceFactor = child.getBalanceFactor();
            //左孩子长
            if (balanceFactor < 0)
                balance = Balance.LEFT_LEFT;
            else 
                balance = Balance.LEFT_RIGHT;
        } else {//右孩子长
            child = (AVLNode<T>) node.greater;
            balanceFactor = child.getBalanceFactor();
            //左孩子长
            if (balanceFactor < 0)
                balance = Balance.RIGHT_LEFT;
            else
                balance = Balance.RIGHT_RIGHT;
        }
		// 左孩子，右孩子长
        if (balance == Balance.LEFT_RIGHT) {
            // Left-Right (Left rotation, right rotation)
            rotateLeft(child);
            rotateRight(node);
        } else if (balance == Balance.RIGHT_LEFT) {
            // Right-Left (Right rotation, left rotation)
            rotateRight(child);
            rotateLeft(node);
        } else if (balance == Balance.LEFT_LEFT) {
            // Left-Left (Right rotation)
            rotateRight(node);
        } else {
            // Right-Right (Left rotation)
            rotateLeft(node);
        }

        child.updateHeight();
        node.updateHeight();
    }
}
```

### 旋转类型
```java
    private enum Balance {
        //（单右旋）
        LEFT_LEFT, 
        //（先右孩子左旋，再自身右旋）
        LEFT_RIGHT, 
        //（先左孩子右旋，再自身左旋）
        RIGHT_LEFT, 
        //（单左旋）
        RIGHT_RIGHT
    }
```
### 左旋
```java

    /**
     * 以node及其children为轴作左旋
     *
     * @param node Root of tree to rotate left.
     */
    protected void rotateLeft(Node<T> node) {
        Node<T> parent = node.parent;
        Node<T> greater = node.greater;
        Node<T> lesser = greater.lesser;
        
        //节点的右孩子的左孩子=节点
        greater.lesser = node;
        //节点的父节点=节点的右孩子
        node.parent = greater;

        //节点的右孩子=节点的右孩子的左孩子
        node.greater = lesser;

        if (lesser != null)
            lesser.parent = node;

        //非root节点
        if (parent != null) {
            if (node == parent.lesser) {
                //当前节点是左孩子
                parent.lesser = greater;
            } else if (node == parent.greater) {
                //当前节点是右孩子
                parent.greater = greater;
            } else {
                throw new RuntimeException("Yikes! I'm not related to my parent. " + node.toString());
            }
            //旋转后的root节点指向旋转前的parent节点
            greater.parent = parent;
        } else {
            root = greater;
            root.parent = null;
        }
    }
```

### 右旋
``` java 

    /**
     * 以node及其children为轴作右旋
     *
     * @param node Root of tree to rotate right.
     */
    protected void rotateRight(Node<T> node) {
        Node<T> parent = node.parent;
        Node<T> lesser = node.lesser;
        Node<T> greater = lesser.greater;

        //节点的左孩子的右孩子=节点
        lesser.greater = node;
        //节点的父节点=节点的左孩子
        node.parent = lesser;

        //节点的左孩子=节点的左孩子的右孩子
        node.lesser = greater;
        //若存在右孩子，节点的左孩子的右孩子的父节点=节点
        if (greater != null)
            greater.parent = node;

        //非root节点
        if (parent != null) {
            if (node == parent.lesser) {
                //当前节点是左孩子
                parent.lesser = lesser;
            } else if (node == parent.greater) {
                //当前节点是右孩子
                parent.greater = lesser;
            } else {
                throw new RuntimeException("Yikes! I'm not related to my parent. " + node.toString());
            }
            //旋转后的root节点指向旋转前的parent节点
            lesser.parent = parent;
        } else {
            root = lesser;
            root.parent = null;
        }
    }
```

### 删除节点
```java

    protected Node<T> removeValue(T value) {
        //找到待删除节点
        Node<T> nodeToRemoved = this.getNode(value);
        if (nodeToRemoved == null)
            return null;

        //找到替换节点（左子树最大/右子树最小/左子树/右子树）
        Node<T> replacementNode = this.getReplacementNode(nodeToRemoved);

        // 替换父节点处理
        AVLNode<T> nodeToRefactor = null;
        if (replacementNode != null)
            nodeToRefactor = (AVLNode<T>) replacementNode.parent;
        if (nodeToRefactor == null)
            nodeToRefactor = (AVLNode<T>) nodeToRemoved.parent;
        if (nodeToRefactor != null && nodeToRefactor == nodeToRemoved)
            nodeToRefactor = (AVLNode<T>) replacementNode;

        //替换节点
        replaceNodeWithNode(nodeToRemoved, replacementNode);

        //遍历替换节点2度内的子节点进行重平衡处理
        while (nodeToRefactor != null) {
            nodeToRefactor.updateHeight();
            balanceAfterDelete(nodeToRefactor);

            nodeToRefactor = (AVLNode<T>) nodeToRefactor.parent;
        }
        return nodeToRemoved;
    }
```

### 更新节点


## 性能
时间复杂度：O(log(n))	
空间复杂度：O(n)	

##应用场景
AVL是一种高度平衡的二叉树，所以通常的结果是，维护这种高度平衡所付出的代价比从中获得的效率收益还大，故而实际的应用不多，更多的地方是用追求局部而不是非常严格整体平衡的红黑树。
当然，如果场景中对插入删除不频繁，只是对查找特别有要求，AVL还是优于红黑的。
 