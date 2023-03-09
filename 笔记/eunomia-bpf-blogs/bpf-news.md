# eBPF 进阶: 内核新特性进展一览

Linux 内核在 2022 年主要发布了 5.16-5.19 以及 6.0 和 6.1 这几个版本，每个版本都为 eBPF 引入了大量的新特性。本文将对这些新特性进行一点简要的介绍，更详细的资料请参考对应的链接信息。总体而言，eBPF 在内核中依然是最活跃的模块之一，它的功能特性也还在高速发展中。某种意义上说，eBPF 正朝着一个完备的内核态可编程接口快速进化。
<!-- TOC -->

- [eBPF 进阶: 内核新特性进展一览](#ebpf-进阶-内核新特性进展一览)
  - [BPF kfuncs](#bpf-kfuncs)
  - [Bloom Filter Map：5.16](#bloom-filter-map516)
  - [Compile Once – Run Everywhere：Linux 5.17](#compile-once--run-everywherelinux-517)
  - [bpf\_loop() 辅助函数：5.17](#bpf_loop-辅助函数517)
  - [BPF\_LINK\_TYPE\_KPROBE\_MULTI：5.18](#bpf_link_type_kprobe_multi518)
  - [动态指针和类型指针：5.19](#动态指针和类型指针519)
  - [USDT：5.19](#usdt519)
  - [bpf panic：6.1](#bpf-panic61)
  - [BPF 内存分配器、链表：6.1](#bpf-内存分配器链表61)
  - [user ring buffer 6.1](#user-ring-buffer-61)

<!-- /TOC -->

## BPF kfuncs

BPF子系统暴露了内核内部算法和数据结构的许多方面；这自然导致了对在内核变化时保持接口稳定性的关注。长期以来，BPF对用户空间不提供接口稳定性保证的立场似乎一直有点问题；过去，内核开发者发现他们不得不维护那些不打算稳定的接口。现在BPF社区开始考虑至少为它的一些接口提供明确的稳定性承诺可能意味着什么。

BPF允许由用户空间加载的程序被附加到大量钩子中的任何一个，并在内核中运行--在子系统的验证器得出这些程序不会损害系统的结论之后。一个程序将获得由它所连接的钩子提供给它的内核数据结构的访问权。在某些情况下，程序可以直接修改这些数据，从而直接影响内核的运行；在其他情况下，内核将对BPF程序返回的值采取行动，例如，允许或不允许某项操作。

还有两种机制，内核可以通过它们使BPF程序获得额外的功能。帮助函数（或 "helpers"）是为提供给BPF程序而编写的特殊函数；它们从扩展BPF时代开始就存在了。被称为kfuncs的机制比较新；它允许任何内核函数被提供给BPF，可能会有一些限制。Kfuncs更简单、更灵活；如果它们首先被实现，那么似乎不太可能有人会在后来添加帮助器。也就是说，kfuncs有一个重要的限制，即它们只能被JIT编译的BPF代码访问，所以它们在缺乏JIT支持的架构上是不可用的（这个列表目前包括32位Arm和RISC-V，尽管增加这两种支持的补丁正在开发中）. 每个kfunc都为BPF程序提供了一些有用的功能，但几乎每个kfunc都暴露了内核内部工作方式的某些方面。

- Reconsidering BPF ABI stability: <https://mp.weixin.qq.com/s/wYDSXuwVgmGw-wmFgBNJcA>
- Documentation/bpf: Add a description of "stable kfuncs" <https://www.spinics.net/lists/kernel/msg4676660.html>

## Bloom Filter Map：5.16

布隆过滤器是一种节省空间的概率数据结构，用于快速测试一个元素是否存在于一个集合中。在布隆过滤器中，假阳性是可能的，而假阴性则不可能。

这个补丁集包括布隆过滤器中可配置数量的哈希值和条目的基准测试。这些基准大致表明，平均而言，使用3个哈希函数是最理想的选择之一。当比较hashmap查找中使用3个哈希值的bloom filter和不使用bloom filter的hashmap查找时，使用bloom filter的查找对于5万个条目大约快15%，对于10万个条目快25%，对于5万个条目快180%，对于1百万个条目快200%。

- BPF: Implement bloom filter map <https://lwn.net/Articles/868024/>

## Compile Once – Run Everywhere：Linux 5.17

Linux 5.17 为 eBPF 添加了一次编译到处执行（Compile Once – Run Everywhere，简称 CO-RE），大大简化了 eBPF 程序处理多版本内核兼容时的复杂性以及循环逻辑的处理。

eBPF 的一次编译到处执行（简称 CO-RE）项目借助了 BPF 类型格式（BPF Type Format, 简称 BTF）提供的调试信息，再通过下面的四个步骤，使得 eBPF 程序可以适配不同版本的内核：

- 第一，在 bpftool 工具中提供了从 BTF 生成头文件的工具，从而摆脱了对内核头文件的依赖。
- 第二，通过对 BPF 代码中的访问偏移量进行重写，解决了不同内核版本中数据结构偏移量不同的问题。
- 第三，在 libbpf 中预定义不同内核版本中数据结构的修改，解决了不同内核中数据结构不兼容的问题。
- 第四，在 libbpf 中提供一系列的内核特性探测库函数，解决了 eBPF 程序在不同内核内版本中需要执行不同行为的问题。比如，你可以用 bpf_core_type_exists() 和bpf_core_field_exists() 分别检查内核数据类型和成员变量是否存在，也可以用类似 extern int LINUX_KERNEL_VERSION __kconfig 的方式查询内核的配置选项。

采用这些方法之后，CO-RE 就使得 eBPF 程序可以在开发环境编译完成之后，分发到不同版本内核的机器中运行，并且也不再需要目标机器安装各种开发工具和内核头文件。所以，Linux 内核社区更推荐所有开发者使用 CO-RE 和 libbpf 来构建 eBPF 程序。实际上，如果你看过 BCC 的源代码，你会发现 BCC 已经把很多工具都迁移到了 CO-RE。

- eBPF多内核版本兼容详解： <https://time.geekbang.org/column/article/534577>
- BPF CO-RE reference guide：<https://nakryiko.com/posts/bpf-core-reference-guide/>

## bpf_loop() 辅助函数：5.17

扩展的BPF虚拟机的主要特征之一是内置于内核的验证器，它确保所有BPF程序都能安全运行。不过，BPF开发者常常认为验证器有点喜忧参半；虽然它能在很多问题发生之前抓住它们，但它也很难让人满意。将其与一个善意但受规则约束且挑剔的官僚机构相提并论并不是完全错的。Joanne Koong提出的 bpf_loop() 建议是为了让一种类型的循环结构更容易取悦BPF的官僚们。

简而言之，这就是Koong的补丁的目的。它增加了一个新的辅助函数，可以从BPF代码中调用。

```c
    long bpf_loop(u32 iterations, long (*loop_fn)(u32 index, void *ctx),
          void *ctx, u64 flags);
```

对 bpf_loop() 的调用将导致对 loop_fn() 的迭代调用，迭代数和传入的 ctx 作为参数。flags 值目前未使用，必须为零。loop_fn() 通常将返回0；返回值为1将立即结束迭代。不允许有其他的返回值。

不像 bpf_for_each_map_elem() 受限于 bpf map 大小，bpf_loop() 的循环次数高达 1<<23 = 8388608（超过 8 百万）次；大大地扩展了 bpf_loop() 的应用场景。不过，bpf_loop() 并没有受限于 BPF 指令数（1 百万条），这是因为循环发生在 bpf_loop() 帮助函数内部。

- A different approach to BPF loops：<https://lwn.net/Articles/877062/>
- eBPF Talk: 实战经验之 loop：<https://mp.weixin.qq.com/s/neOVsMNVWFbwpTSek-_YsA>

## BPF_LINK_TYPE_KPROBE_MULTI：5.18

这个补丁集增加了新的链接类型BPF_TRACE_KPROBE_MULTI，它通过Masami制作的fprobe API [1]来连接kprobe程序。fprobe API允许一次在多个函数上附加探针，速度非常快，因为它工作在ftrace之上。另一方面，它将探测点限制在函数入口或返回。

- bpf: Add kprobe multi link：<https://lwn.net/Articles/885811/>

## 动态指针和类型指针：5.19

BPF程序中的所有内存访问都使用验证器进行安全性静态检查，验证器在允许程序运行之前对其进行全面分析。虽然这允许 BPF 程序在内核空间中安全运行，但它限制了该程序如何使用指针。直到最近，一个这样的限制是在 BPF 程序中被指针引用的内存区域的大小必须在加载 BPF 程序时静态知道。Joanne Koong 最近设置的一个补丁集增强了 BPF，以支持使用指向动态大小的内存区域的指针加载程序。

Koong 的补丁集增加了对访问 BPF 程序中动态大小的内存区域的支持，其中包含一个名为 dynptrs 的新特性。dynptrs 背后的主要思想是将指向动态大小的数据区域的指针与验证器和一些 BPF 辅助函数使用的元数据相关联，以确保对该区域的访问是有效的。Koong 的补丁集在一个新定义的类型中创建了这种关联，称为struct bpf_dynptr。这种结构对 BPF 程序是不透明的。

- <https://mp.weixin.qq.com/s/rz4pd41Y-Cet5YVSAKmCRw>

## USDT：5.19

静态跟踪点（tracepoint），在用户空间也被称为 USDT（用户静态定义的跟踪）探针（应用程序中感兴趣的特定位置），跟踪器可以在此处挂载检查代码执行和数据。它们由开发人员在源代码中明确定义，通常在编译时用 “–enable-trace” 等标志启用。静态跟踪点的优势在于它们不会经常变化：开发人员通常会保持稳定的静态跟踪 ABI，所以跟踪工具在不同的应用程序版本之间工作，这很有用，例如当升级 PostgreSQL 安装并遇到性能降低时。

- eBPF 概述：第 5 部分：跟踪用户进程：<https://www.ebpf.top/post/ebpf-overview-part-5/>
- Using user-space tracepoints with BPF：<https://lwn.net/Articles/753601/>

## bpf panic：6.1

BPF子系统的关键卖点之一是加载BPF程序是安全的：BPF验证器在允许加载之前确保该程序不会伤害内核。随着更多的功能被提供给BPF程序，这种保证也许会失去一些力量，但即便如此，看到 Artem Savkov 的这个提议加入了一个明确设计为使系统崩溃的BPF助手，可能会让人有点吃惊。如果这个补丁集以类似于目前的形式被合并，它将是一个新时代的预兆，即至少在某些情况下，BPF程序被允许公开地进行破坏。

正如 Savkov 所指出的，BPF 的主要用例之一是内核调试，这项任务也经常因为存在一个适时的崩溃转储而得到帮助。通过使内核的panic() 函数对BPF程序可用，Savkov试图将这两者结合起来，允许BPF程序在检测到表明开发人员正在寻找的问题的条件时导致崩溃，并创建崩溃转储。Savkov似乎不是唯一想要这种能力的人；Jiri Olsa指出，他也收到了关于这种功能的请求。

- The BPF panic function: <https://lwn.net/Articles/901284/>

## BPF 内存分配器、链表：6.1

本系列介绍了用户定义的BPF对象在程序中的 BTF 类型。这允许BPF程序分配他们自己的对象，建立他们的自己的对象层次，并使用由BPF 运行时提供的基本构件来灵活地建立自己的数据结构。

然后，我们介绍了对单一所有权BPF链表的支持。它可以放在BPF映射或分配的对象中，并把这些被分配的对象作为元素。它作为一个侵入性的集合工作。这样做的目的是为了在将来使分配的对象成为多个数据结构的一部分。

这个补丁和未来补丁的最终目标是允许人们在 BPF C 中做一些有限的内核式编程，并允许程序员灵活地从基本的构建块中灵活地构建自己的复杂数据结构。

关键的区别在于，这种程序是经过验证的，是安全的，保存系统的运行时完整性，并被证明是没有错误的

具体的功能包含

- 分配对象
- bpf_obj_new, bpf_obj_drop 来分配和释放对象
- 单一所有权的BPF链表
  - 在 BPF maps 中支持它们
  - 在分配的对象中支持它们
- 全局自旋锁。
- 在被分配对象中的自旋锁。

参考：<https://lwn.net/Articles/914833/>

## user ring buffer 6.1

这个补丁集定义了一个新的映射类型，BPF_MAP_TYPE_USER_RINGBUF，它在一个环形缓冲器上提供了单用户空间生产者/单内核消费者的语义。  除了新的映射类型外，还增加了一个名为bpf_user_ringbuf_drain()的辅助函数，它允许BPF程序指定一个具有如下签名的回调，样本由辅助函数发布到该回调。

```c
void（struct bpf_dynptr *dynptr, void *context）。
```

然后程序可以使用bpf_dynptr_read()或bpf_dynptr_data()辅助函数来安全地从dynptr中读取样本。目前没有可用的辅助函数来确定样本的大小，但是如果需要的话，可以很容易地添加一个。

libbpf 也添加了一些对应的 API:

```c
struct ring_buffer_user *
ring_buffer_user__new(int map_fd,
                      const struct ring_buffer_user_opts *opts);
void ring_buffer_user__free(struct ring_buffer_user *rb);
void *ring_buffer_user__reserve(struct ring_buffer_user *rb,
        uint32_t size);
void *ring_buffer_user__poll(struct ring_buffer_user *rb, uint32_t size,
           int timeout_ms);
void ring_buffer_user__discard(struct ring_buffer_user *rb, void *sample);
void ring_buffer_user__submit(struct ring_buffer_user *rb, void *sample);
```

- bpf: Add user-space-publisher ring buffer map type： <https://lwn.net/Articles/907056/>

> - 本文由 eunomia-bpf 团队完成，我们正在探索 eBPF 和 WebAssembly 相互结合的工具链和运行时: <https://github.com/eunomia-bpf/wasm-bpf>
> - 以及在 Wasm 和 eBPF 之上，尝试构建一些有趣的应用场景：
