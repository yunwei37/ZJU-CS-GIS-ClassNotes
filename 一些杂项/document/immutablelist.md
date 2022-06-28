---
title: llvm 源码中的数据结构：ImmutableList
date: 2022-03-13T18:41:06-08:00
tags: notes
---

> 这几篇想简单谈谈一下自己在写代码时遇见的，或者阅读 llvm 相关代码时见到的数据结构实现。

## 关于 ImmutableList

ImmutableList 顾名思义，即不可变链表。它是一种可持久化数据结构，在进行插入或删除操作时并不对原先的数据结构进行改动，而是创建一个新的拷贝。关于可持久化数据结构，可以参考维基百科：[Persistent_data_structure](https://en.wikipedia.org/wiki/Persistent_data_structure)

> 在计算中，持久数据结构或非临时数据结构是一种在修改时始终保留其先前版本的数据结构。这样的数据结构实际上是不可变的，因为它们的操作不会（明显地）就地更新结构，而是总是产生一个新的更新结构。该术语是在 Driscoll、Sarnak、Sleator 和 Tarjans 1986 年的文章中引入的。[1]这些类型的数据结构在逻辑和函数式编程中特别常见，[2]因为这些范式中的语言不鼓励（或完全禁止）使用可变数据。

<!-- more -->

在 `clang static analyzer` 里面可能也会遇见到不少使用 `ImmutableList` 的情况，是通过使用 `REGISTER_LIST_WITH_PROGRAMSTATE` 宏，来达成在 `ProgramState` 中添加一个 list 记录相关数据的目的：

```cpp
  #define REGISTER_LIST_WITH_PROGRAMSTATE(Name, Elem) \
    REGISTER_TRAIT_WITH_PROGRAMSTATE(Name, llvm::ImmutableList<Elem>)
```

例如在 PthreadLockChecker.cpp 中，它就被作为一个栈使用：

```cpp
// A stack of locks for tracking lock-unlock order.
REGISTER_LIST_WITH_PROGRAMSTATE(LockSet, const MemRegion *)
```

`ImmutableList` 和 `ImmutableMap` 接口基本相同，但我们实际上在 CSA 中更多时候是通过 `ImmutableMap` 来在 `ProgramState` 中持有一个集合的。

> 关于 ProgramState，可以参考：[https://clang.llvm.org/doxygen/classclang_1_1ento_1_1ProgramState.html](https://clang.llvm.org/doxygen/classclang_1_1ento_1_1ProgramState.html)。
> 在 `clang static analyzer` 中， ProgramState 表示了一个抽象的程序状态。
> ProgramState的目的是作为一个函数式对象来使用；也就是说。一旦它被创建并在FoldingSet中被 "持久化"，它的的值将永远不会改变。

## ImmutableList 的实现

### ImmutableList 类

ImmutableList 是一个单链表，它的实现在 `include/llvm/ADT/ImmutableList.h` 中，总体来说，ImmutableList 本身和一般的链表并没有太大的差别，ImmutableList 是一个链表的通用接口，对外提供了 `contains` 方法：

```cpp
template <typename T>
class ImmutableList {
public:
  using value_type = T;
  using Factory = ImmutableListFactory<T>;

  static_assert(std::is_trivially_destructible<T>::value,
                "T must be trivially destructible!");

private:
  const ImmutableListImpl<T>* X;

public:
  // This constructor should normally only be called by ImmutableListFactory<T>.
  // There may be cases, however, when one needs to extract the internal pointer
  // and reconstruct a list object from that pointer.
  ImmutableList(const ImmutableListImpl<T>* x = nullptr) : X(x) {}

  const ImmutableListImpl<T>* getInternalPointer() const {
    return X;
  }
  ......
  bool contains(const T& V) const {
    for (iterator I = begin(), E = end(); I != E; ++I) {
      if (*I == V)
        return true;
    }
    return false;
  }

  /// isEqual - Returns true if two lists are equal.  Because all lists created
  ///  from the same ImmutableListFactory are uniqued, this has O(1) complexity
  ///  because it the contents of the list do not need to be compared.  Note
  ///  that you should only compare two lists created from the same
  ///  ImmutableListFactory.
  bool isEqual(const ImmutableList& L) const { return X == L.X; }

  bool operator==(const ImmutableList& L) const { return isEqual(L); }

  /// getHead - Returns the head of the list.
  const T& getHead() const {
    assert(!isEmpty() && "Cannot get the head of an empty list.");
    return X->getHead();
  }

  /// getTail - Returns the tail of the list, which is another (possibly empty)
  ///  ImmutableList.
  ImmutableList getTail() const {
    return X ? X->getTail() : nullptr;
  }

  void Profile(FoldingSetNodeID& ID) const {
    ID.AddPointer(X);
  }
};
```

`ImmutableList` 被实现为智能指针（用来包装ImmutableListImpl），因此它始终按值复制，就好像它是指针一样:

```cpp
private:
  const ImmutableListImpl<T>* X;
```

它外在的接口和 `ImmutableSet` 和 `ImmutableMap` 的接口相匹配。

`ImmutableList` 对象几乎不应该被直接创建，而应该由管理一组列表的生命周期的 `ImmutableListFactory` 对象创建。当工厂对象被回收时，该工厂创建的所有链表也会被释放。这点可以参考它构造函数上的注释：

```cpp
  // This constructor should normally only be called by ImmutableListFactory<T>.
  // There may be cases, however, when one needs to extract the internal pointer
  // and reconstruct a list object from that pointer.
  ImmutableList(const ImmutableListImpl<T>* x = nullptr) : X(x) {}
```

### ImmutableListImpl

ImmutableListImpl 是链表的节点实现，Tail 指向下一个节点，head 中存储具体的类型：

```cpp

template <typename T>
class ImmutableListImpl : public FoldingSetNode {
  friend class ImmutableListFactory<T>;

  T Head;
  const ImmutableListImpl* Tail;

  template <typename ElemT>
  ImmutableListImpl(ElemT &&head, const ImmutableListImpl *tail = nullptr)
    : Head(std::forward<ElemT>(head)), Tail(tail) {}

public:
  ImmutableListImpl(const ImmutableListImpl &) = delete;
  ImmutableListImpl &operator=(const ImmutableListImpl &) = delete;

  const T& getHead() const { return Head; }
  const ImmutableListImpl* getTail() const { return Tail; }
...
};
```

### ImmutableListFactory

`ImmutableListFactory` 是用来创建 `ImmutableList` 的工厂类，它有自己的内存分配器并在其中保存着所有分配了的链表：

```cpp

template <typename T>
class ImmutableListFactory {
  using ListTy = ImmutableListImpl<T>;
  using CacheTy = FoldingSet<ListTy>;

  CacheTy Cache;
  uintptr_t Allocator;

  bool ownsAllocator() const {
    return (Allocator & 0x1) == 0;
  }

  BumpPtrAllocator& getAllocator() const {
    return *reinterpret_cast<BumpPtrAllocator*>(Allocator & ~0x1);
  }

public:
  ImmutableListFactory()
    : Allocator(reinterpret_cast<uintptr_t>(new BumpPtrAllocator())) {}

  ImmutableListFactory(BumpPtrAllocator& Alloc)
  : Allocator(reinterpret_cast<uintptr_t>(&Alloc) | 0x1) {}

  ~ImmutableListFactory() {
    if (ownsAllocator()) delete &getAllocator();
  }

  template <typename ElemT>
  LLVM_NODISCARD ImmutableList<T> concat(ElemT &&Head, ImmutableList<T> Tail) {
    // Profile the new list to see if it already exists in our cache.
    FoldingSetNodeID ID;
    void* InsertPos;

    const ListTy* TailImpl = Tail.getInternalPointer();
    ListTy::Profile(ID, Head, TailImpl);
    ListTy* L = Cache.FindNodeOrInsertPos(ID, InsertPos);

    if (!L) {
      // The list does not exist in our cache.  Create it.
      BumpPtrAllocator& A = getAllocator();
      L = (ListTy*) A.Allocate<ListTy>();
      new (L) ListTy(std::forward<ElemT>(Head), TailImpl);

      // Insert the new list into the cache.
      Cache.InsertNode(L, InsertPos);
    }

    return L;
  }

  template <typename ElemT>
  LLVM_NODISCARD ImmutableList<T> add(ElemT &&Data, ImmutableList<T> L) {
    return concat(std::forward<ElemT>(Data), L);
  }

  template <typename ...CtorArgs>
  LLVM_NODISCARD ImmutableList<T> emplace(ImmutableList<T> Tail,
                                          CtorArgs &&...Args) {
    return concat(T(std::forward<CtorArgs>(Args)...), Tail);
  }

  ImmutableList<T> getEmptyList() const {
    return ImmutableList<T>(nullptr);
  }

  template <typename ElemT>
  ImmutableList<T> create(ElemT &&Data) {
    return concat(std::forward<ElemT>(Data), getEmptyList());
  }
};
```

工厂类中主要有两个成员变量：

- `CacheTy Cache;`：包含一系列链表节点的 catch，它里面是一个 `FoldingSet`:

    FoldingSet - This template class is used to instantiate a specialized implementation of the folding set to the node class T. T must be a subclass of FoldingSetNode and implement a Profile function.

    注意 ImmutableListImpl 类继承了 FoldingSetNode 类。

- `uintptr_t Allocator;`：这里实际上是一个 `BumpPtrAllocator` 内存分配器，在构造函数中通过 reinterpret_cast 转化成了 uintptr_t 类型：

    ```cpp
      ImmutableListFactory()
    : Allocator(reinterpret_cast<uintptr_t>(new BumpPtrAllocator())) {}
    ```

    当 ImmutableListFactory 析构时，所有创建的链表内存都会被回收。

ImmutableListFactory 的核心是 concat 函数，它会先判断是否存在相同的链表，如果是则直接返回，不是的话就在头部创建一个新的节点，然后把新的节点插入 Cache 中。这样每次创建一个新的链表实际上的开销只有一个头结点，即 O(1); 

```cpp
    template <typename ElemT>
  LLVM_NODISCARD ImmutableList<T> concat(ElemT &&Head, ImmutableList<T> Tail) {
    // Profile the new list to see if it already exists in our cache.
    FoldingSetNodeID ID;
    void* InsertPos;

    const ListTy* TailImpl = Tail.getInternalPointer();
    ListTy::Profile(ID, Head, TailImpl);
    ListTy* L = Cache.FindNodeOrInsertPos(ID, InsertPos);

    if (!L) {
      // The list does not exist in our cache.  Create it.
      BumpPtrAllocator& A = getAllocator();
      L = (ListTy*) A.Allocate<ListTy>();
      new (L) ListTy(std::forward<ElemT>(Head), TailImpl);

      // Insert the new list into the cache.
      Cache.InsertNode(L, InsertPos);
    }

    return L;
  }
```

最后，像链表插入这样的函数，就直接调用 concat 就好了：

```cpp
 template <typename ElemT>
  LLVM_NODISCARD ImmutableList<T> add(ElemT &&Data, ImmutableList<T> L) {
    return concat(std::forward<ElemT>(Data), L);
  }
```

除了这个 ImmutableList，其实更重要的是一个 ImmutableMap，它是一个可持久化的 AVL 树实现。大佬已经写过 ImmutableMap 的源码解析了[2]，所以我打算用 rust 再实现一下 ImmutableMap，具体可以参考：
[/_posts/immutablemap.md](/_posts/immutablemap.md)


## 参考资料

1. [Persistent_data_structure](https://en.wikipedia.org/wiki/Persistent_data_structure)
2. [clang static analyzer中的数据结构及内存分配策略 - ImmutableMap & ImmutableSet篇](https://blog.csdn.net/dashuniuniu/article/details/79981500)
3. [checker_dev_manual](https://clang-analyzer.llvm.org/checker_dev_manual.html#idea)
4. [classllvm_1_1ImmutableList](https://llvm.org/doxygen/classllvm_1_1ImmutableList.html#details)