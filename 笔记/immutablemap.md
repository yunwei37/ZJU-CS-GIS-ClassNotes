---
title: 用 rust 实现可持久化 AVL 树：ImmutableMap
date: 2022-03-17T18:41:06-08:00
tags: notes
---

> 这几篇想简单谈谈一下自己在写代码时遇见的，或者阅读 llvm 相关代码时见到的数据结构实现。

本文源代码：[https://github.com/yunwei37/immutable-map-rs](https://github.com/yunwei37/immutable-map-rs)

## 关于 ImmutableMap

ImmutableMap 是一种可持久化数据结构，在进行插入或删除操作时并不对原先的数据结构进行改动，而是创建一个新的拷贝。关于可持久化数据结构，可以参考维基百科[1]：[Persistent_data_structure](https://en.wikipedia.org/wiki/Persistent_data_structure)

这里参考的是 llvm 中的 ImmutableMap/ImmutableSet 实现，采用一个平衡因子为 2 的 AVL 树[2]:

<!-- more -->

> ImmutableSet is an immutable (functional) set implementation based on an AVL tree. Adding or removing elements is done through a Factory object and results in the creation of a new ImmutableSet object. If an ImmutableSet already exists with the given contents, then the existing one is returned; equality is compared with a FoldingSetNodeID. The time and space complexity of add or remove operations is logarithmic in the size of the original set.
> There is no method for returning an element of the set, you can only check for membership.

ImmutableSet 是基于 AVL 树的不可变（功能）集实现。添加或删除元素是通过 Factory 对象完成的，并导致创建新的 ImmutableSet 对象。如果具有给定内容的 ImmutableSet 已经存在，则返回现有的；通过与 FoldingSetNodeID 进行比较判断是否相等。添加或删除操作的时间和空间复杂度与原始集合的大小成对数。

没有返回集合元素的方法，您只能检查元素是否存在。

关于 llvm 中 ImmutableSet 的原理和源代码实现，可以参考：[clang static analyzer中的数据结构及内存分配策略 - ImmutableMap & ImmutableSet篇](https://blog.csdn.net/dashuniuniu/article/details/79981500)

感觉 llvm 里面实现的非常漂亮。

## 用 rust 实现

之所以要用 rust 写，很大一个方面是因为我很久没写 rust 了，需要重新复健一下（x），另外也是增加一点理解。

rust 的所有权模型实际上非常适合写这种不可变数据结构，比可变的 AVL tree 实现起来要方便和直观地多。另外，使用引用计数智能指针虽然会带来一些额外的开销，但实际上极大地减轻了内存管理的压力。借由 `RC` 甚至可以把它当成可变 AVL 树来使用，比如：

```rs
let map = ImmutableMap::new();
let map = map.insert(1, "abc");
let map = map.delete(1, "abc");
let size = new_map.size();
let data = new_map.get_val_as_ref(1);
```

和原版比起来，Factory 我还没有实现。同样，我是在一个 Set 的基础上包装成一个 Map 的，使用 `path-copying` 来实现可持久化，即在从根节点到插入节点的路径上把每个节点复制一遍。

### 类型定义

先来看看类型实现的定义：

1. AVL 树节点：

```rs
type AvlTreeImpl<T> = Option<Rc<TreeNode<T>>>;

#[derive(Clone, Debug)]
struct TreeNode<T: PartialOrd + Clone> {
    val: T,
    height: u32,
    left: AvlTreeImpl<T>,
    right: AvlTreeImpl<T>,
}
```

2. 树的包装:

```rs
#[derive(Clone, Debug)]
pub struct ImmutAvlTree<T: PartialOrd + Clone> {
    root: AvlTreeImpl<T>,
}
```

### 插入

ImmutAvlTree 上面的函数入口：

```rs
impl<T: PartialOrd + Clone> ImmutAvlTree<T> {
    pub fn insert(&self, val: T) -> Self {
        match self.root {
            None => ImmutAvlTree {
                root: TreeNode::new(val, None, None),
            },
            Some(ref root) => ImmutAvlTree {
                root: root.as_ref().do_insert(val),
            },
        }
    }
```

接下来是每个节点的递归实现：

- 如果左右子树非空，则继续递归插入；
- 如果为空，则创建一个新节点
- 不管是空还是非空，最后都会通过 balance_tree 重新平衡，和完成 `path-copying` 的创建节点。

```rs
impl<T: PartialOrd + Clone> TreeNode<T> {
    fn do_insert(&self, val: T) -> AvlTreeImpl<T> {
        if val < self.val {
            if let Some(ln) = &self.left {
                TreeNode::balance_tree(self.val.clone(), ln.do_insert(val), self.right.clone())
            } else {
                TreeNode::balance_tree(
                    self.val.clone(),
                    TreeNode::new(val, None, None),
                    self.right.clone(),
                )
            }
        } else if val > self.val {
            if let Some(rn) = &self.right {
                TreeNode::balance_tree(self.val.clone(), self.left.clone(), rn.do_insert(val))
            } else {
                TreeNode::balance_tree(
                    self.val.clone(),
                    self.left.clone(),
                    TreeNode::new(val, None, None),
                )
            }
        } else {
            TreeNode::new(val, self.left.clone(), self.right.clone())
        }
    }
```

### 再平衡

接下来是 AVL 树的旋转：

- 如果需要旋转，则复制所有相关节点；
- 如果不需要，则只创建对应的父节点；

```rs
impl<T: PartialOrd + Clone> TreeNode<T> {
    /// rebalance tree or create new nodes
    fn balance_tree(val: T, left: AvlTreeImpl<T>, right: AvlTreeImpl<T>) -> AvlTreeImpl<T> {
        let left_height = TreeNode::get_height(&left);
        let right_height = TreeNode::get_height(&right);
        if left_height > right_height + BALANCE_FACTOR {
            let left_node = left.as_ref().unwrap();
            let ll_height = TreeNode::get_height(&left_node.left);
            let lr_height = TreeNode::get_height(&left_node.right);
            if ll_height > lr_height {
                TreeNode::new(
                    left_node.val.clone(),
                    left_node.left.clone(),
                    TreeNode::new(val, left_node.right.clone(), right),
                )
            } else {
                let lr_node = left_node.right.as_ref().unwrap();
                TreeNode::new(
                    lr_node.val.clone(),
                    TreeNode::new(
                        left_node.val.clone(),
                        left_node.left.clone(),
                        lr_node.left.clone(),
                    ),
                    TreeNode::new(val, lr_node.right.clone(), right),
                )
            }
        } else if right_height > left_height + BALANCE_FACTOR {
            let right_node = right.as_ref().unwrap();
            let rl_height = TreeNode::get_height(&right_node.left);
            let rr_height = TreeNode::get_height(&right_node.right);
            if rr_height > rl_height {
                TreeNode::new(
                    right_node.val.clone(),
                    TreeNode::new(val, left, right_node.left.clone()),
                    right_node.right.clone(),
                )
            } else {
                let rl_node = right_node.left.as_ref().unwrap();
                TreeNode::new(
                    rl_node.val.clone(),
                    TreeNode::new(val, left, rl_node.left.clone()),
                    TreeNode::new(
                        rl_node.val.clone(),
                        rl_node.right.clone(),
                        right_node.right.clone(),
                    ),
                )
            }
        } else {
            TreeNode::new(val, left, right)
        }
    }
```

### 删除

同样，类似插入：

```rs
    fn do_delete(&self, val: T) -> AvlTreeImpl<T> {
        if val < self.val {
            if let Some(ln) = &self.left {
                TreeNode::balance_tree(self.val.clone(), ln.do_delete(val), self.right.clone())
            } else {
                // not found val
                None
            }
        } else if val > self.val {
            if let Some(rn) = &self.right {
                TreeNode::balance_tree(self.val.clone(), self.left.clone(), rn.do_delete(val))
            } else {
                // not found val
                None
            }
        } else {
            self.combine_trees(&self.left, &self.right)
        }
    }
```

接下来是寻找一个节点替代：

```rs
    fn remove_min(&self) -> (AvlTreeImpl<T>, T) {
        if let Some(ln) = &self.left {
            let left = ln.remove_min();
            (TreeNode::balance_tree(self.val.clone(), left.0, self.right.clone()), left.1)
        } else {
            (self.right.clone(), self.val.clone())
        }
    }
    fn combine_trees(&self, left: &AvlTreeImpl<T>, right: &AvlTreeImpl<T>) -> AvlTreeImpl<T> {
        if let None = left {
            right.clone()
        } else if let None = right {
            left.clone()
        } else {
            if let Some(right) = &self.right {
                let new_right = right.remove_min();
                TreeNode::balance_tree(new_right.1, left.clone(), new_right.0)
            } else {
                left.clone()
            }
        }
    }
```

还有入口代码：

```rs
impl<T: PartialOrd + Clone> ImmutAvlTree<T> {
    pub fn delete(&self, val: T) -> Self {
        match self.root {
            None => ImmutAvlTree { root: None },
            Some(ref root) => {
                let result = root.as_ref().do_delete(val);
                if let Some(_) = result {
                    ImmutAvlTree { root: result }
                } else {
                    ImmutAvlTree {
                        root: self.root.clone(),
                    }
                }
            }
        }
    }
```

### 查找

正常的二叉树查找：

```rs
    pub fn get_as_ref(&self, val: T) -> Option<&T> {
        if val < self.val {
            if let Some(ln) = &self.left {
                ln.get_as_ref(val)
            } else {
                None
            }
        } else if val > self.val {
            if let Some(rn) = &self.right {
                rn.get_as_ref(val)
            } else {
                None
            }
        } else {
            Some(&self.val)
        }
    }
```

## 参考

本文完整源代码：[immutable-map-rs](https://github.com/yunwei37/immutable-map-rs)

1. [Persistent_data_structure](https://en.wikipedia.org/wiki/Persistent_data_structure)
2. [AVL树](https://zh.wikipedia.org/zh-hans/AVL%E6%A0%91)
3. [https://llvm.org/docs/ProgrammersManual.html#llvm-adt-immutableset-h](https://llvm.org/docs/ProgrammersManual.html#llvm-adt-immutableset-h)
4. [clang static analyzer中的数据结构及内存分配策略 - ImmutableMap & ImmutableSet篇](https://blog.csdn.net/dashuniuniu/article/details/79981500)
