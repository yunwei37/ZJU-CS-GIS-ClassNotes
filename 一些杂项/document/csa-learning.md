---
title: Clang static analyzer Checker 初探

date: 2022-03-27T08:41:06-08:00
tags: notes
---

> 这里只是我刚开始学习静态分析时的一些粗浅的理解和经验之谈，以及相关资料整理，并不能确保正确，还请多多补充指正

<!-- TOC -->

- [1. 关于 Clang static analyzer](#1-关于-clang-static-analyzer)
  - [1.1. Clang static analyzer](#11-clang-static-analyzer)
  - [1.2. How it works](#12-how-it-works)
- [2. 如何添加一个最简单的 Checker](#2-如何添加一个最简单的-checker)
  - [2.1. Hello World](#21-hello-world)
  - [2.2. 注册编译](#22-注册编译)
- [3. 教程：进行不同类型的检查](#3-教程进行不同类型的检查)
  - [3.1. PointerSubChecker.cpp](#31-pointersubcheckercpp)
  - [3.2. SimpleStreamChecker.cpp](#32-simplestreamcheckercpp)
  - [3.3. Taint.cpp](#33-taintcpp)
  - [3.4. 其他一些常用的检查实现](#34-其他一些常用的检查实现)
- [4. 如何写一个更好的检查器](#4-如何写一个更好的检查器)
    - [4.0.1. 良好的编码习惯](#401-良好的编码习惯)
    - [4.0.2. 常见的崩溃来源](#402-常见的崩溃来源)
    - [4.0.3. 即使在技术上没有错误，您也应该避免的模式](#403-即使在技术上没有错误您也应该避免的模式)
- [5. 有哪些资料可以进一步参考？](#5-有哪些资料可以进一步参考)
  - [5.1. llvm 官方文档和论坛](#51-llvm-官方文档和论坛)
  - [5.2. 代码](#52-代码)
  - [5.3. 论文/主要文档](#53-论文主要文档)
  - [5.4. 博客](#54-博客)
    - [5.4.1. 某个 clang static analyzer 源码分析博客：dashuniuniu](#541-某个-clang-static-analyzer-源码分析博客dashuniuniu)
    - [5.4.2. 知乎：VVKoishi](#542-知乎vvkoishi)
    - [5.4.3. 其他](#543-其他)

<!-- /TOC -->

## 1. 关于 Clang static analyzer

> 这是 `naive systems` 的一个静态分析工具： https://www.naivesystems.com/ 其中一些对于 MISRA C 的检查器就是基于 ``Clang static analyzer`` 构建的。

### 1.1. Clang static analyzer

Clang 是 LLVM 的一个“前端”，意思是底层依赖于 LLVM 架构。Xcode 使用 Clang 。

LLVM 不是一个缩写，它是一个工具集，用于构建编译器、优化器、运行时环境。Clang 只是在其基础上建立的 C语系（C/C++/Objective C）编译器，该计划最初设想提供一种基于SSA编译策略的，支持任意编程语言的静态和动态编译，现今该计划已经发展出多个模块化的子项目，成为编译器和相关工具链的合集。

`Clang Static Analyzer` 是 Clang 项目的一部分，在 Clang 基础上构建，静态分析引擎被实现为可重用的C++库，可以在多种环境下使用（Xcode、命令行、接口调用等）。静态分析会自动检查源代码中的隐含bug，并产生编译器警告。随着静态分析技术的发展，其已经从简单的语法检查，步进到深层的代码语义分析。要注意到，由于使用最新的技术深入分析代码，因此静态分析可能比编译慢得多（即使启用编译优化），查找错误所需的某些算法在最坏的情况下需要指数时间。静态分析还可能会存在假阳性问题（False Positives）。如果需要更多 Checker 来让静态分析引擎执行特定检查，需要在源码中实现

### 1.2. How it works

静态分析最初由一些基础研究论文启发。

简而言之，分析器是一个源码的模拟器，追踪其可能的执行路径。程序状态（变量和表达式的值）被封装为 `ProgramState` 。程序中的位置被叫做 ProgramPoint 。state 和 program point 的组合是 ExplodedGraph 中的节点。术语“exploded”来自控制流图（control-flow graph，CFG）中爆炸式增长的控制流连边。

概念上讲，分析器会沿着 ExplodedGraph 执行可达性分析（reachability analysis）。从具有 entry program point 和 initial state 的根节点开始，分析模拟每个单独表达式的转移。表达式分析会产生状态改变，使用更新后的 program point 和 state 创建新节点。当满足某些 bug 条件时（违反检测不变量，checking invariant），就认为发现了 bug 。

分析器通过推理分支（branches）追踪多条路径（paths），分叉状态：在 true 分支上认为分支条件为 true，在 false 分支上认为分支条件为 false 。这种“假设”创建了程序中的值的约束（constraints），这些约束被记录在 ProgramState 对象（通过 ConstraintManager 修改）。如果假设分支条件会导致不能满足约束，这条分支就被认为不可行，路径也不会被选取。这就是我们实现路径敏感（path-sensitivity）的方式。我们降低了缓存节点的指数爆炸。如果和已存在节点含相同 state 和 program point 的新节点将被生成，路径会“出缓存”（caches out），我们只简单重用已有节点。因此 ExplodedGraph 不是有向无环图（DAG），它可以包含圈（cycles），当路径相互循环，以及出缓存。

ProgramState 和 ExploledNodes 在创建后基本上是不可变的。当产生新状态时，需要创建一个新的 ProgramState 。这种不变性是必要的，因为 ExplodedGraph 表示了从入口点开始分析的程序的行为。为了高效表达，我们使用了函数式数据结构（比如 ImmutableMaps ）在实例间共享数据。

最终，每个单独检查器（Checkers）也通过操作分析状态来工作。分析引擎通过访问者接口（visitor interface）与之沟通。比如，PreVisitCallExpr() 方法被 GRExprEngine 调用，来告诉 Checker 我们将要分析一个 CallExpr ，然后这个检查器被请求检查任意前置条件，这些条件可能不会被满足。检查器不会做除此之外的任何事情：生成一个新的 ProgramState 和包含更新后的检查器状态的 ExplodedNode 。如果它发现了一个 bug ，它会把错误告诉 BugReporter 对象，提供引发该问题的路径上的最后一个 ExplodedNode 节点。

## 2. 如何添加一个最简单的 Checker

以一个最简单的 checker ，禁用 `malloc` 为例:

### 2.1. Hello World

在 `clang/lib/StaticAnalyzer/Checkers/` ，新建 `MyChecker.cpp`:

```cpp
#include "clang/StaticAnalyzer/Checkers/BuiltinCheckerRegistration.h"
#include "clang/StaticAnalyzer/Core/BugReporter/BugType.h"
#include "clang/StaticAnalyzer/Core/Checker.h"
#include "clang/StaticAnalyzer/Core/CheckerManager.h"
#include "clang/StaticAnalyzer/Core/PathSensitive/CheckerContext.h"
#include "clang/StaticAnalyzer/Core/PathSensitive/CallEvent.h"

using namespace clang;
using namespace ento;

namespace {
class MyChecker : public Checker< check::PreCall > {
  mutable std::unique_ptr<BuiltinBug> BT;
  void reportBug(const char *Msg, const CallEvent &Call, CheckerContext &C) const;

public:
  // process malloc(0)
  void checkPreCall(const CallEvent &Call, CheckerContext &C) const;
};
} // end anonymous namespace

void MyChecker::reportBug(const char *Msg, const CallEvent &Call, ProgramStateRef StateZero, CheckerContext &C) const 
{
  if (ExplodedNode *N = C.generateErrorNode(StateZero)) {
    if (!BT)
      BT.reset(new BuiltinBug(this, "call to malloc"));

    auto R = std::make_unique<PathSensitiveBugReport>(*BT, Msg, N);
    R->addRange(Call.getSourceRange());
    C.emitReport(std::move(R));
  }
}

void MyChecker::checkPreCall(const CallEvent &Call, CheckerContext &C) const 
{
  if (!Call.isGlobalCFunction("malloc"))
    return;

    reportBug("V: Allocation of zero bytes", Call, C);    
    return;
}

void ento::registerMyChecker(CheckerManager &mgr) {
  mgr.registerChecker<MyChecker>();
}

bool ento::shouldRegisterMyChecker(const CheckerManager &mgr) {
  return true;
}
```

### 2.2. 注册编译

在 `clang/include/clang/StaticAnalyzer/Checkers/Checkers.td` 文件中，把新建的 `MyChecker` 放入待注册列表:

```
let ParentPackage = Core in {
// ...
def MyChecker : Checker<"MyChecker">,
  HelpText<"Check for zero malloc">,
  Documentation<HasDocumentation>;
// ...
} // end "core"
```

之后，需要把` MyChecker.cpp` 添加进 `clang/lib/StaticAnalyzer/Checkers/CMakeLists.txt` 检查器构建列表。

```CMakeLists.txt
add_clang_library(clangStaticAnalyzerCheckers
  MyChecker.cpp
  ...
  )
```

## 3. 教程：进行不同类型的检查

举几个例子：

（TODO: 待完善）

### 3.1. PointerSubChecker.cpp

检查程序某个特定的节点中，两个指针是否指向了同一个内存区域：

```cpp
#include "clang/StaticAnalyzer/Checkers/BuiltinCheckerRegistration.h"
#include "clang/StaticAnalyzer/Core/BugReporter/BugType.h"
#include "clang/StaticAnalyzer/Core/Checker.h"
#include "clang/StaticAnalyzer/Core/CheckerManager.h"
#include "clang/StaticAnalyzer/Core/PathSensitive/CheckerContext.h"

using namespace clang;
using namespace ento;

namespace {
class PointerSubChecker
  : public Checker< check::PreStmt<BinaryOperator> > {
  mutable std::unique_ptr<BuiltinBug> BT;

public:
  void checkPreStmt(const BinaryOperator *B, CheckerContext &C) const;
};
}

void PointerSubChecker::checkPreStmt(const BinaryOperator *B,
                                     CheckerContext &C) const {
  // When doing pointer subtraction, if the two pointers do not point to the
  // same memory chunk, emit a warning.
  if (B->getOpcode() != BO_Sub)
    return;

  SVal LV = C.getSVal(B->getLHS());
  SVal RV = C.getSVal(B->getRHS());

  const MemRegion *LR = LV.getAsRegion();
  const MemRegion *RR = RV.getAsRegion();

  if (!(LR && RR))
    return;

  const MemRegion *BaseLR = LR->getBaseRegion();
  const MemRegion *BaseRR = RR->getBaseRegion();

  if (BaseLR == BaseRR)
    return;

  // Allow arithmetic on different symbolic regions.
  if (isa<SymbolicRegion>(BaseLR) || isa<SymbolicRegion>(BaseRR))
    return;

  if (ExplodedNode *N = C.generateNonFatalErrorNode()) {
    if (!BT)
      BT.reset(
          new BuiltinBug(this, "Pointer subtraction",
                         "Subtraction of two pointers that do not point to "
                         "the same memory chunk may cause incorrect result."));
    auto R =
        std::make_unique<PathSensitiveBugReport>(*BT, BT->getDescription(), N);
    R->addRange(B->getSourceRange());
    C.emitReport(std::move(R));
  }
}

void ento::registerPointerSubChecker(CheckerManager &mgr) {
  mgr.registerChecker<PointerSubChecker>();
}

bool ento::shouldRegisterPointerSubChecker(const CheckerManager &mgr) {
  return true;
}
```

（TODO: 待完善）

### 3.2. SimpleStreamChecker.cpp

跟踪状态传递：[SimpleStreamChecker.cpp]https://github.com/llvm/llvm-project/blob/main/clang/lib/StaticAnalyzer/Checkers/SimpleStreamChecker.cpp)

Defines a checker for proper use of fopen/fclose APIs.

- If a file has been closed with fclose, it should not be accessed again.
  Accessing a closed file results in undefined behavior.
- If a file was opened with fopen, it must be closed with fclose before
  the execution ends. Failing to do so results in a resource leak.

（TODO: 待完善）

### 3.3. Taint.cpp

Defines basic, non-domain-specific mechanisms for tracking tainted values.

https://github.com/llvm/llvm-project/blob/main/clang/lib/StaticAnalyzer/Checkers/Taint.cpp

（TODO: 待完善）

### 3.4. 其他一些常用的检查实现

https://b.corp.naive.systems:9443/projects/misra-c-2012/wiki/一些简单的可供参考的代码片段
## 4. 如何写一个更好的检查器

> 部分翻译和整理自 https://clang-analyzer.llvm.org/checker_dev_manual.html：Making Your Checker Better，也有一部分是经验总结。这部分值得好好阅读，我们在这上面栽过不少坑

#### 4.0.1. 良好的编码习惯

- 警告和注意信息应该清晰易懂，即使有点长。
    - 消息应以大写字母开头（与 Clang 警告不同！）且不应以 .. 结尾
    - 引入 `BugReporterVisitor` 以发出额外的注释，更好地向用户解释警告。有一些现有的访问者可能对您的检查有用，例如 `trackNullOrUndefValue` 。例如， `SimpleStreamChecker` 应该在报告文件描述符泄漏时突出显示打开文件的事件。
- 如果 checker 跟踪程序状态中的任何内容，则需要实现 checkDeadSymbols回调来清理状态。
- 当跟踪的未知符号被传递给 checker 时，检查应该保守地假设程序是正确的。 `checkPointerEscape` 回调可以帮助您处理这种情况。
- 使用安全便捷的 API！
    - 始终使用 `CheckerContext::generateErrorNode` 和 `CheckerContext::generateNonFatalErrorNode` 来发出错误报告。最重要的是，永远不要针对 `CheckerContext::getPredecessor` 发出报告。
    - Prefer `checkPreCall` and `checkPostCall` to `checkPreStmt<CallExpr>` and `checkPostStmt<CallExpr>`.
    - 使用 `CallDescription` 检测程序中的硬编码 API 调用。
    - 将 `C.getState ()->getSVal(E, C.getLocationContext())` 简化为 `C.getSVal(E)`。

#### 4.0.2. 常见的崩溃来源

- `CallEvent::getOriginExpr` 可以为空 - 例如，它为变量的自动析构函数返回 null。这同样适用于模拟调用时生成的一些值，例如， `SymbolConjured::getStmt` 可以为空。
- `CallEvent::getDecl` 可以为空 - 例如，它为调用符号函数指针返回 null。
- `addTransition` `generateSink` `generateNonFatalErrorNode` `generateErrorNode` 可以为空，因为您可以转换到您已经访问过的节点。
- 当参数越界时，返回参数的 `CallExpr/FunctionDecl/CallEvent` 方法会崩溃。如果您检查了函数名称，这并不意味着该函数具有预期的参数数量！这就是您应该使用CallDescription的原因。
- 不同种类的符号和区域中不同实体的可空性通常通过其构造函数中的断言来记录。
- 如果声明的名称不是单个标记，例如对于析构函数，`NamedDecl::getName` 将失败。对于这些情况，您可以使用 `NamedDecl::getNameAsString` 。请注意，此方法要慢得多，应谨慎使用，例如仅在生成报告时而不是在分析期间使用。
- `-analyzer -checker=core` 是否包含在所有测试RUN:行中？从未支持在禁用核心检查的情况下运行分析器。它可能会导致意外行为和崩溃。您应该在启用核心检查的情况下进行所有测试。

除了上述 CSA 中常见的 崩溃可能性，还应当注意 llvm 中的类型转换和空指针检查。

#### 4.0.3. 即使在技术上没有错误，您也应该避免的模式

- `BugReporterVisitor` 很可能与当前程序点的 AST 不匹配，以决定何时发出注释。通过观察 `program state` 的变化来确定这一点要容易得多。
- 在 `State->getSVal(Region)` 中，如果 `Region` 不是 `TypedValueRegion` 并且未指定可选类型参数，则检查器可能会意外尝试取消引用 void 指针。
- 检查器逻辑不应依赖于某个值是 `Loc` 还是 `NonLoc` 。根据正在检查的 AST， `SVal` 是 `Loc` 还是 `NonLoc` 应该立即显而易见。检查一个值是 `Loc` 还是 `Unknown/Undefined` 或者该值是 `NonLoc` 还是` Unknown/Undefined` 完全没问题。
- 不应通过直接调用 `SymbolManager` 在检查器中构造新符号，除非它们属于检查器标记的 `SymbolMetadata` 类，或者它们代表新创建的值，例如 `evalCall` 中的返回值。对于模拟算术/按位/比较操作，应使用 `SValBuilder` 。
- 不应在检查器中创建自定义 `ProgramPointTag` 。检查器通常没有充分的理由将多个节点链接在一起，因为检查器不是 `worklists` 算法。
- 鼓励检查者通过与分析器的其余部分分享他们关于程序状态的知识来积极参与分析，但他们不应不必要地破坏分析：
- 如果检查器拆分程序状态，这必须基于新出现的分支绝对是可能的并且值得从用户的角度探索的知识。否则，状态拆分应该延迟，直到有迹象表明采取了其中一条路径，或者需要完全删除其中一条路径。例如，只要x在每条路径上受到相应的约束，就可以在建模isalpha(x)时急切地分割路径。同时，在为调用建模时，在printf()的返回值上分割路径并不是一个好主意，因为没有人检查printf中的错误；充其量，它只会使剩余的分析时间增加一倍。
- 使用 `CheckerContext::generateNonFatalErrorNode` 时建议小心， 因为它会生成一个独立的转换，很像 `addTransition` 。使用时很容易意外拆分路径。理想情况下，尝试对代码进行结构化，以便每个 `addTransition` 或 `generateNonFatalErrorNode` （或如果要拆分的情况下的序列）之后立即从检查器回调返回。
- 不同检查器中 `evalCall` 的多个实现不应冲突。
- 实现 `evalAssume` 时，检查器应始终为真假设或假假设（或两者）返回非空状态。
- 检查器不得改变表达式的值，即使用 `ProgramState::BindExpr` API，除非它们完全负责计算值。在任何情况下，他们都不应更改表达式的非未知值。目前，此 API 在检查器中的唯一有效用例是在 `evalCall` 回调中对返回值进行建模。如果表达式值不正确，则需要修复 `ExprEngine` 。

## 5. 有哪些资料可以进一步参考？

### 5.1. llvm 官方文档和论坛

> 一切以官方文档为准。

- https://github.com/llvm/llvm-project 

    llvm 的官方 monorepo，clang 和 CSA 的代码也在其中；

- https://llvm.org/docs/ProgrammersManual.html

    这个文档旨在强调 LLVM 源代码库中可用的一些重要类和接口，由于 clang 是 llvm-project 的一部分，在对 CSA 进行修改和开发时最好也能阅读一下这部分的内容；

- https://clang-analyzer.llvm.org/checker_dev_manual.html

    在 CSA 中写 checker 主要的参考文档，这部分需要仔细阅读；

- 相关 issue 和讨论：
  - https://discourse.llvm.org/c/clang/static-analyzer/49
  - https://github.com/llvm/llvm-project/issues?q=is%3Aissue+is%3Aopen+static+analyzer+label%3A%22clang%3Astatic+analyzer%22

- https://clang-analyzer.llvm.org/potential_checkers.html

    此页面包含要在静态分析器中实现的潜在检查器列表。如果您有兴趣为 CSA 的开发做出贡献，这是帮助您入门的好资源。

- https://clang-analyzer.llvm.org/open_projects.html

    此页面列出了几个可以提高 CSA 可用性和功能的项目。此处列出的大多数项目都与基础设施相关，因此此列表是潜在检查列表的补充。

- [CSA 的一些开发文档](https://github.com/llvm/llvm-project/tree/main/clang/docs/analyzer/developer-docs)

    开发 CSA 的一些常用文档，讲解了一些内部的原理机制和 debug 方式，包含以下几个方面：
    - Debug Checks：a number of checkers which can aid in debugging
    - Inlining
    - Initializer List
    - Region Store
    - Nullability Checks

### 5.2. 代码

这一部分是在 [llvm-project](https://github.com/llvm/llvm-project/) 代码库中可见的一些参考资料：

- [README](https://github.com/llvm/llvm-project/blob/main/clang/lib/StaticAnalyzer/README.txt)

    一个简要介绍 CSA 的 README 文件，包含了库结构，工作原理等。

- [documentation](https://github.com/llvm/llvm-project/blob/main/clang/lib/StaticAnalyzer/Checkers/CheckerDocumentation.cpp)

    This checker lists all the checker callbacks and provides documentation for checker writers. 提供了所有的回调钩子的文档。

### 5.3. 论文/主要文档

- [Precise interprocedural dataflow analysis via graph reachability](http://web.stanford.edu/class/archive/cs/cs295/cs295.1086/papers/p49-reps.pdf)

    CSA 的分析算法原理。论文解读 blog：
    - [IFDS开山之作：Precise Interprocedual Dataflow Analysis via Graph Reachability](https://blog.csdn.net/qq_37206105/article/details/119428468)

- [A memory model for static analysis of C programs](https://www.researchgate.net/profile/Zhongxing-Xu/publication/221430855_A_Memory_Model_for_Static_Analysis_of_C_Programs/links/584fb54e08ae4bc8993b322f/A-Memory-Model-for-Static-Analysis-of-C-Programs.pdf)

    clang Static Analyzer 的内存模型基于这篇论文实现。

    有人对这篇论文进行了一定程度的翻译：
    
    - [A Memory Model for Static Analysis of C](https://zhuanlan.zhihu.com/p/381607343)
    - [静态分析C程序的内存模型](https://blog.csdn.net/weixin_42482896/article/details/118761797)

    也可以对照别人写的 [CSA 源码分析博客](https://zhuanlan.zhihu.com/p/24405332) 来进一步理解。

- [clang-analyzer-guide](https://github.com/haoNoQ/clang-analyzer-guide)

    实现 Clang 静态分析器扩展的简单指南，由 CSA 维护者编写，其实比起指南更像手册一点；

- [Building a Checker in 24 hours](https://llvm.org/devmtg/2012-11/Zaks-Rose-Checker24Hours.pdf)
    
    The "Building a Checker in 24 hours" presentation given at the November 2012 LLVM Developer's meeting. Describes the construction of SimpleStreamChecker


### 5.4. 博客

#### 5.4.1. 某个 clang static analyzer 源码分析博客：dashuniuniu

这一部分主要是关于 clang static analyzer 的工作原理分析，虽然稍微有点老旧（约2017年），不过应该大体上还是没有太多变化的；相关系列从源码入手详细分析了 clang static analyzer 的一些基本概念和工作模式，值得一看。

- [clang static analyzer总结](https://blog.csdn.net/dashuniuniu/article/details/103669441)
- [clang static analyzer中的数据结构及内存分配策略 - ImmutableMap & ImmutableSet篇](https://blog.csdn.net/dashuniuniu/article/details/79981500)
- [clang static analyzer源码分析（番外篇）：removeDead() - SVal、Symbol及Environment](https://blog.csdn.net/dashuniuniu/article/details/53173045)
- [clang static analyzer源码分析（番外篇）：RegionStore以及evalCall()中的conservativeEvalCall](https://blog.csdn.net/dashuniuniu/article/details/52849373)
- [clang中的活跃性分析（续）](https://blog.csdn.net/dashuniuniu/article/details/53087374)
- [clang static analyzer源码分析（番外篇）：evalCall()中的inline机制](https://blog.csdn.net/dashuniuniu/article/details/52830592)
- [clang static analyzer源码分析（五）](https://blog.csdn.net/dashuniuniu/article/details/52461196)
- [clang static analyzer源码分析（四）](https://blog.csdn.net/dashuniuniu/article/details/52451025)
- [clang static analyzer源码分析（三）](https://blog.csdn.net/dashuniuniu/article/details/52438233)
- [clang static analyzer源码分析（二）](https://blog.csdn.net/dashuniuniu/article/details/52434781)
- [clang static analyzer源码分析（一）](https://blog.csdn.net/dashuniuniu/article/details/50773316)

同一个人在知乎上也有相关文章，讨论 CSA 相关内存模型：

- [Clang Static Analyzer内存模型(一)：MemRegion.i](https://zhuanlan.zhihu.com/p/24405332)
- [Clang Static Analyzer内存模型(一)：MemRegion.ii](https://zhuanlan.zhihu.com/p/24466787)
- [Clang Static Analyzer内存模型(一)：MemRegion.iii](https://zhuanlan.zhihu.com/p/24466902)
- [Clang Static Analyzer内存模型（二）.i：MemRegion与SVal](https://zhuanlan.zhihu.com/p/24582974)
- [Clang Static Analyzer内存模型（二）.ii：MemRegion与SVal](https://zhuanlan.zhihu.com/p/24777418)

其他部分还可以自行访问其 csdn 和 zhihu 账号。

#### 5.4.2. 知乎：VVKoishi

这一系列文章关注于实现一个简单的 memory.ZeroAlloc Checker，让 Analyzer 引擎提供自定义的静态检查支持；并且也涉及到了一些简单的代码分析，如果你是在 MacOS 下工作的话，这是一个很好的入门文档，写于 2021 年。

Part 1 介绍 Clang Static Analyzer ，以及源码构建 `Clang` 。

Part 2 关注引擎底层实现，包含 Checker 相关源码解读，举例 `DivZeroChecker` 。

Part 3 关注如何添加一个 `Checker` 。

- [Clang Static Analyzer - Part 1](https://zhuanlan.zhihu.com/p/369254889)
- [Clang Static Analyzer - Part 2](https://zhuanlan.zhihu.com/p/369864214)
- [Clang Static Analyzer - Part 3](https://zhuanlan.zhihu.com/p/370190882)

#### 5.4.3. 其他

关于 Live Variables analysis 的源码分析：

- [Clang Static Analyzer—活跃变量分析](https://zhuanlan.zhihu.com/p/378409759)