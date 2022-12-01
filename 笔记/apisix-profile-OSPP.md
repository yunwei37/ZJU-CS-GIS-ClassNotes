# 项目申请书

> 项目名称：Apache APISIX profile 工具
> 
> 项目导师：厉辉
> 
> 申请人：郑昱笙
>
> 日期：2022.5.27
> 
> 邮箱：3180102760@zju.edu.cn

<!-- TOC -->

- [项目申请书](#项目申请书)
  - [项目背景](#项目背景)
    - [项目基本需求](#项目基本需求)
      - [项目产出要求：](#项目产出要求)
      - [项目技术要求](#项目技术要求)
    - [项目相关仓库](#项目相关仓库)
    - [关于我自己](#关于我自己)
      - [基本介绍](#基本介绍)
      - [技术栈与开源贡献](#技术栈与开源贡献)
      - [APISIX 相关实践：](#apisix-相关实践)
  - [技术背景、方法和可行性](#技术背景方法和可行性)
    - [关于 Apache APISIX profile 工具的实现背景](#关于-apache-apisix-profile-工具的实现背景)
    - [linux 性能分析工具，以及 perf](#linux-性能分析工具以及-perf)
      - [perf](#perf)
    - [ebpf 技术](#ebpf-技术)
      - [Why is eBPF](#why-is-ebpf)
      - [LibBPF](#libbpf)
      - [hook 点：](#hook-点)
      - [ebpf 性能分析](#ebpf-性能分析)
      - [ebpf 性能分析实现原理](#ebpf-性能分析实现原理)
    - [/openresty-systemtap-toolkit](#openresty-systemtap-toolkit)
    - [lua 性能分析相关参考资料](#lua-性能分析相关参考资料)
  - [项目实现细节梳理](#项目实现细节梳理)
    - [项目要点和难点：](#项目要点和难点)
  - [项目完成规划](#项目完成规划)
    - [第一阶段（7.1 - 7.20）](#第一阶段71---720)
    - [第二阶段（7.20 - 8.10）](#第二阶段720---810)
    - [第三阶段（8.10 - 结束）](#第三阶段810---结束)

<!-- /TOC -->

## 项目背景

### 项目基本需求

目前，`Apache APISIX` 没有一个非常有用的配置文件工具来分析CPU或内存，开发人员只能使用基准测试或打印日志来分析 `Apache APISIX`。因此，我们可以使用使用 `eBPF` 为 `Apache APISIX` 创建配置文件工具，使用 `eBPF` 捕获 `Apache APISIX` 中的 `Lua` 调用堆栈信息，并将其绘制成 CPU火焰图。

#### 项目产出要求：

使用eBPF捕获和解析 `Apache APISIX` 中的 lua 调用堆栈信息，对其进行汇总并生成cpu火焰图：
- 利用eBPF同时捕获和解析C和Lua混合调用堆栈信息，对其进行总结，生成cpu火焰图。
- 支持获取在Docker中运行的 `Apache APISIX` 进程
- 支持获取 Apache APISIX Openresty luajit 32/luajit 64 模式

#### 项目技术要求

熟悉Lua/C：
- 对 eBPF 和 Openresty 有一些了解。
- 对 profiling 有一定了解

### 项目相关仓库

- 项目成果仓库：https://github.com/apache/apisix
- 参考仓库：https://github.com/openresty/openresty-systemtap-toolkit
- 实现的 demo 仓库：https://github.com/yunwei37/nginx-lua-ebpf
- 工具整合仓库：https://github.com/yunwei37/Eunomia

### 关于我自己

#### 基本介绍

我叫郑昱笙，是浙江大学的23届本科生，目前的专业是地理信息科学，平常在杭州/上海。我一直以来就对开源项目非常感兴趣，自己也写过一些小型的开源项目放在 Github 上（目前供给已经获得 800+ star），并且也为一些开源项目做过贡献，因此也非常希望能长期、更深层次地参与到著名的开源项目中，成为相关的项目维护者。

#### 技术栈与开源贡献

- 对操作系统有清晰地理解和实践知识：参加过 rcore （一个用 rust 写的类linux内核）开源社区的暑期活动，在 ZCore（一个由清华大学主导的 rust 编写的开源实验性操作系统内核：https://github.com/rcore-os/zCore ）中贡献过不少代码，实现了大部分异步进程间通信机制；完成过 MIT 6.828（2018）课程的 Lab，并且也给 rcore 操作系统教程提过 PR 贡献；
- 熟悉 ebpf 技术，并且基于 ebpf 技术开发过相关监测工具: 使用 C/现代C++ 主导开发了一个基于 ebpf 的监控工具：https://github.com/yunwei37/Eunomia，基于 Libbpf + eBPF CO-RE 技术对多种操作系统指标进行监控，帮助用户了解容器的各项行为、监控可疑的容器安全事件；该工具也集成了基本的 profiling 功能。
- 熟练使用 C 语言进行开发，并且使用 perf 等工具做过相关性能分析实践，以此解决实习工作中碰到的 C 代码相关性能问题；有编译、静态分析相关的实习经验，主要在 llvm/clang 相关工具链上开发，也为知名的开源 go 静态分析器（[github.com/securego/gosec](github.com/securego/gosec)）贡献过代码；对编译器/jit相关实现机制有一些认知；
- 了解 lua 语言和 openresty 技术；

#### APISIX 相关实践：

- 给 APISIX 提过 PR，修复了关于 APISIX 性能分析文档的一些问题：https://github.com/apache/apisix/pull/7035
- 对 APISIX 的基本架构和使用场景有相关理解和动手实践；
- 参考 APISIX 的 ci，使用 systemtap 在本地复现了相关火焰图生成：

    ```
    git clone https://github.com/apache/apisix
    cd apisix
    sudo apt-get install -y libpcre3 libpcre3-dev
    sudo apt-get install -y openssl libssl-dev unzip zlib*
    sudo ./ci/performance_test.sh install_dependencies
    sudo ./ci/performance_test.sh install_wrk2
    sudo ./ci/performance_test.sh install_stap_tools
    ./ci/performance_test.sh run_performance_test
    ```

    结果如下：

    ![flamegraph](img/fix-lua-bt.png)

- 同时使用 bcc/libbpf 中已经存在的 ebpf 工具对 APISIX 中的 openresty 生成了初步的火焰图，但 lua 相关信息还未获得：

    ![flamegraph](img/unknown.png)

- 目前已经进行了一定程度上的 demo 开发：https://github.com/yunwei37/nginx-lua-ebpf/blob/master/bcc_nginx_lua.c 主要使用 uprobe 技术和 perf 接口；

## 技术背景、方法和可行性


### 关于 Apache APISIX profile 工具的实现背景

Apache APISIX是一个动态、实时、高性能的API网关。提供了丰富的流量管理功能，如负载均衡、动态上游、canary释放、断路、认证、可观察性等。 `apisix` 基于 `openresty` 开发，目前 `openresty` 社区中已经有一个实时分析和诊断工具：

- [github.com/openresty/openresty-systemtap-toolkit](github.com/openresty/openresty-systemtap-toolkit)

其中也覆盖了不少性能监测和分析工具，目前大部分的 `openresty` 和 lua/luajit 相关分析借由该项目进行。可以通过 [ngx-sample-lua-bt](https://github.com/openresty/openresty-systemtap-toolkit#ngx-sample-lua-bt) 工具来生成相关火焰图，例如这是我自己进行的尝试：

![flamegraph](img/fix-lua-bt.png)

但该项目已经不再维护，同时这些脚本基于 systemtap 和 perl 编写，对于 lua64 的支持也还未合并进入主线，所使用的内核版本相对来说也比较老旧，在较新的系统上并没有很好的支持，尤其是对于容器和云原生环境下的支持很困难。因此需要有一个工具对于 `Apache APISIX` 中的调用堆栈信息进行分析。

openresty-systemtap-toolkit 有一个替代工具，https://openresty.com/en/xray ，但它是商业化的闭源工具，对相关社区的支持并不好。

本项目希望能够使用 ebpf 实现 openresty-systemtap-toolkit 的一个功能子集，并且尽可能地完善和接近 openresty-systemtap-toolkit 的相关功能。


### linux 性能分析工具，以及 perf

常见的 linux 下性能分析工具：

- vmstat--虚拟内存统计
- iostat--用于报告中央处理器统计信息
- dstat--系统监控工具
- iotop--LINUX进程实时监控工具
- pidstat--监控系统资源情况
- top,htop,mpstat 等等等等

![profiles](img/profiles.jpg)

#### perf

perf是Linux kernel自带的系统性能优化工具。优势在于与Linux Kernel的紧密结合，它可以最先应用到加入Kernel的new feature，用于查看热点函数，查看cashe miss的比率，从而帮助开发者来优化程序性能。

性能调优工具如 perf，Oprofile 等的基本原理都是对被监测对象进行采样，最简单的情形是根据 tick 中断进行采样，即在 tick 中断内触发采样点，在采样点里判断程序当时的上下文。假如一个程序 90% 的时间都花费在函数 foo() 上，那么 90% 的采样点都应该落在函数 foo() 的上下文中。运气不可捉摸，但我想只要采样频率足够高，采样时间足够长，那么以上推论就比较可靠。因此，通过 tick 触发采样，我们便可以了解程序中哪些地方最耗时间，从而重点分析。

参考：

- https://www.brendangregg.com/perf.html#Background

### ebpf 技术

#### Why is eBPF

eBPF是一项革命性的技术，可以在Linux内核中运行沙盒程序，而无需更改内核源代码或加载内核模块。通过使Linux内核可编程，基础架构软件可以利用现有的层，从而使它们更加智能和功能丰富，而无需继续为系统增加额外的复杂性层。

* 优点：低开销

  eBPF 是一个非常轻量级的工具，用于监控使用 Linux 内核运行的任何东西。虽然 eBPF 程序位于内核中，但它不会更改任何源代码，这使其成为泄露监控数据和调试的绝佳伴侣。eBPF 擅长的是跨复杂系统实现无客户端监控。 
* 优点：安全

  解决内核观测行的一种方法是使用内核模块，它带来了大量的安全问题。而eBPF 程序不会改变内核，所以您可以保留代码级更改的访问管理规则。此外，eBPF 程序有一个验证阶段，该阶段通过大量程序约束防止资源被过度使用，保障了运行的ebpf程序不会在内核产生安全问题。
* 优点：精细监控、跟踪

  eBPF 程序能提供比其他方式更精准、更细粒度的细节和内核上下文的监控和跟踪标准。并且eBPF监控、跟踪到的数据可以很容易地导出到用户空间，并由可观测平台进行可视化。 
* 缺点：很新

  eBPF 仅在较新版本的 Linux 内核上可用，这对于在版本更新方面稍有滞后的组织来说可能是令人望而却步的。如果您没有运行 Linux 内核，那么 eBPF 根本不适合您。

#### LibBPF

libbpf 是一个比BCC更新的 BPF 开发库，也是最新的 BPF 开发推荐方式，以下是从BCC转向libbpf+BPF CO-RE的理由：

BCC 依靠运行时间汇编，将整个大型 LLVM/Clang 库带入并嵌入其中。这有许多后果，所有这些都不太理想：

编译过程中资源利用量大（内存和 CPU），可能会中断繁忙服务器上的主要工作流;
依赖于内核头包，该包必须安装在每个目标主机上。即便如此，如果您需要从内核中获取不通过public headers暴露的东西，您也需要手工将类型定义复制/粘贴到 BPF 代码中，以完成您的工作;
即使是微不足道的编译时间错误也只在运行时间（在您完全重建并重新启动用户空间应用程序后）检测到：这显著缩短了开发迭代时间（并增加了挫折感水平。。。）
文章BPF Portability and CO-RE 指出，为了提高BPF程序的便携性，即在不同内核版本上正常工作，而无需为每个特定内核重新编译的能力，社区提出了一个称为BPF CO-RE(Compile Once – Run Everywhere)的解决方案。

Libbpf+BPF CO-RE的理念是，BPF程序与任何"正常"用户空间程序没有太大区别：它们应该汇编成小型二进制文件，然后以紧凑的形式进行部署，以瞄准主机。Libbpf 扮演 BPF 程序装载机的角色，执行平凡的设置工作（重定位、加载和验证 BPF 程序、创建 BPF map、连接到 BPF 挂钩等），让开发人员只担心 BPF 程序的正确性和性能。这种方法将开销保持在最低水平，消除沉重的依赖关系，使整体开发人员体验更加愉快。

#### hook 点：

对eBPF来说，和Kernle Module一样，也是通过特定的Hook点监听内核中的特定事件，进而执行用户定义的处理。这些Hook点包括：

- 静态tracepoint
- 动态内核态探针(Dynamic Kernel probes)
- 动态用户态探针(Dynamic User Probes)
- 其他hook点

参考：

- https://github.com/iovisor/bcc
- https://www.brendangregg.com/ebpf.html
- https://www.brendangregg.com/blog/2021-07-03/how-to-add-bpf-observability.html

#### ebpf 性能分析

Bcc(BPF Compiler Collection): 一个用于创建高效的内核跟踪和操作程序的工具包，包括几个有用的工具和示例。bcc 已经提供了许多性能分析工具，其中能生成火焰图的有：

- 基于 bcc 的性能工具：参考 https://www.brendangregg.com/blog/2016-10-21/linux-efficient-profiler.html，目前已经被弃用

    - 代码：https://github.com/iovisor/bcc/blob/master/tools/profile.py

目前更推荐使用的是基于 libbpf 的性能工具：

和过去常用的 BCC 不同， Libbpf 是 BPF CO-RE（一次编译，到处运行）。Libbpf 作为 BPF 程序加载器，接管了重定向、加载、验证等功能，BPF 程序开发者只需要关注 BPF 程序的正确性和性能即可。这种方式将开销降到了最低，且去除了庞大的依赖关系，使得整体开发流程更加顺畅。

- 基于 libbpf 的性能工具：https://www.brendangregg.com/blog/2020-11-04/bpf-co-re-btf-libbpf.html

    - https://github.com/iovisor/bcc/blob/master/libbpf-tools/offcputime.c
    - 还有一个基于 libbpf 的性能工具已经基本开发完成，但还未合并进入主线：https://github.com/iovisor/bcc/pull/3782


#### ebpf 性能分析实现原理

在 libbpf 中，我们同样可以通过 ebpf 去获取 perf event 的相关数据，例如：

```
struct {
	__uint(type, BPF_MAP_TYPE_STACK_TRACE);
	__type(key, u32);
} stackmap SEC(".maps");

struct {
	__uint(type, BPF_MAP_TYPE_HASH);
	__type(key, struct key_t);
	__type(value, sizeof(u64));
	__uint(max_entries, MAX_ENTRIES);
} counts SEC(".maps");

SEC("perf_event")
int do_perf_event(struct bpf_perf_event_data *ctx)
{
	u64 id = bpf_get_current_pid_tgid();
	u32 pid = id >> 32;
	u32 tid = id;
	u64 *valp;
	static const u64 zero;
	struct key_t key = {};

	key.pid = pid;
	bpf_get_current_comm(&key.name, sizeof(key.name));

		key.user_stack_id = bpf_get_stackid(&ctx->regs, &stackmap, BPF_F_USER_STACK);

	valp = bpf_map_lookup_or_try_init(&counts, &key, &zero);
	if (valp)
		__sync_fetch_and_add(valp, 1);

	return 0;
}
```

本质上来说，使用这种技术也是通过 perf event 完成对用户态的跟踪的。但和 perf 不同，这是一个高效的分析器，因为堆栈跟踪是频率计数的内核上下文，而不是将每个堆栈都传递给用户空间以获得频率在那里数。只有唯一的堆栈和计数被传递到用户空间。在配置文件的末尾，大大减少了内核<->用户转移。

要求：Linux 4.9+（BPF_PROG_TYPE_PERF_EVENT 支持）

我之前已经尝试实现过使用 ebpf 工具捕获 Openresty 相关调用图，但是由于缺少 lua 相关符号信息，所以暂时并不完整，接下来需要将 lua 的 jit 符号信息整合到 ebpf profile 工具中。

### /openresty-systemtap-toolkit

nginx-systemtap-toolkit - 基于 SystemTap 为 NGINX 打造的实时分析和诊断工具集

- ngx-active-reqs 这个工具会列出来指定的 NGINX worker 或者 master 进程正在处理的所有活跃请求的详细信息。
- ngx-req-distr 这个工具分析（下游）请求和连接，在指定的 NGINX master 进程的所有 NGINX worker 进程中的分布。
- ngx-shm 这个工具分析在指定的正在运行的 NGINX 进程中，所有的共享内存区域。
- ngx-cycle-pool 这个工具计算在指定的 NGINX
- ngx-leaked-pools 跟踪 NGINX 内存池的创建和销毁，以及给出泄露池前 10 的调用栈。
- ngx-backtrace 从 ngx-leaked-pools 之类的工具生成的 16 进制地址的原始调用栈，转换为人类可读的格式。
- ngx-body-filters 按照实际运行的顺序，打印出所有输出体过滤器。
- ngx-header-filters 按照实际运行的顺序，打印出所有输出头过滤器。
- ngx-pcrejit 这个脚本跟踪指定 NGINX worker 进程里面 PCRE 编译的正则表达式的执行（即 pcre_exec 的调用）， 并且检测它们是否被 JIT 执行。
- ngx-sample-bt 这个工具已经被重命名为 sample-bt，因为这个工具并不只针对 NGINX，所以保留 ngx- 这个前缀没有什么意义。
- ngx-sample-lua-bt 
- fix-lua-bt 
- ngx-lua-bt 这个工具可以把 NGINX worker 进程中 Lua 的当前调用栈 dump 出来。
- sample-bt-off-cpu 
- sample-bt-vfs 这个工具是在虚拟文件系统（VFS）之上采样用户空间调用栈，以便渲染出文件 I/O 火焰图
- accessed-files 通过指定 -p 选项，找出来任意用户进程（对的，不限于 NGINX！）最常读写的文件名。
- ngx-pcre-stats 这个工具会展示一个正在运行的 NGINX worker 进程中，PCRE 正则表达式执行效率的各类统计分析。
- tcp-accept-queue 对于那些监听 --port 选项指定的本地端口的 socket，这个工具会采样它们的 SYN 队列和 ACK backlog 队列。
- tcp-recv-queue 这个工具可以分析涉及 TCP receive 队列的排队延迟。
- ngx-lua-shdict 对于指定的正在运行的 NGINX 进程，这个工具可以分析它的共享内存字典并且追踪字典的操作。
- ngx-lua-conn-pools 导出 ngx_lua 的连接池状态, 报告连接池内外的连接数, 统计连接池内连接的重用次数，并打印出每个连接池的容量。
- check-debug-info 对于指定的正在运行的进程，这个工具可以检测它里面哪些可执行文件没有包含调试信息。

我们首先重点关注 **ngx-sample-lua-bt** 工具，并进行 ebpf 移植。

另外比如 accessed-files，sample-bt-off-cpu，sample-bt，tcp-accept-queue 等工具， libbpf tools/bcc 中已经有了一些现成的实现。某些工具相关的功能已经被集成到我写的 Eunimoa 中，例如 accessed-files。

其中部分还未实现的工具，可以使用动态用户态探针(uprobe) 对 NGINX 进行分析，或 kprobe 等方法对内核进行跟踪，基于 ebpf 实现。

### lua 性能分析相关参考资料

- http://www.javashuo.com/article/p-wqgnoodo-kn.html
- https://github.com/Patrick08T/LuaProfiler
- https://blog.openresty.com/en/lua-cpu-flame-graph/

systemtap的脚本，它的原理是在运行时 hook nginx 中某些特定的函数，然后拿到全局的 lua_state 指针，然后在 profile 的时候再通过 map 拿到之前保存下来的 lua_state 指针，通过这个 state 去遍历 frame 找到对应的函数信息；

```
function lua_getstack(L, level) {
    ci = \@cast(L, "lua_State", "$lua_path")->ci
    base_ci = \@cast(L, "lua_State", "$lua_path")->base_ci
    //printf("L=%x, ci=%x, base_ci=%x\\n", L, ci, base_ci)
    if (ci_offset == 0) {
        ci_offset = &\@cast(0, "CallInfo", "$lua_path")[1]
    }
    //printf("ci offset: %d\\n", ci_offset)
    for (; level > 0 && ci > base_ci; ci -= ci_offset) {
        level--;
        //tt = \@cast(ci, "CallInfo", "$lua_path")->func->tt
        //printf("ci tt: %d\\n", tt)
        if (f_isLua(ci)) { /* Lua function? */
            tailcalls = \@cast(ci, "CallInfo", "$lua_path")->tailcalls
            //printf("it is a lua func! tailcalls=%d\\n", tailcalls)
            level -= tailcalls;  /* skip lost tail calls */
        }
    }
    if (level == 0 && ci > base_ci) {  /* level found? */
        //printf("lua_getstack: ci=%x\\n", ci);
        //tt = \@cast(ci, "CallInfo", "$lua_path")->func->tt
        //printf("ci tt: %d\\n", tt)
        //ff = &\@cast(ci, "CallInfo", "$lua_path")->func->value->gc->cl
        //isC = \@cast(ci, "CallInfo", "$lua_path")->func->value->gc->cl->c->isC
        //printf("isC: %d, %d ff=%x\\n", isC, \@cast(ff, "Closure", "$lua_path")->c->isC, ff)
        //f = ci_func(ci)
        //printf("lua_getstack: ci=%x, f=%x, isLua=%d\\n", ci, f, f_isLua(ci));
        return ci - base_ci;
    }
    if (level < 0) {  /* level is of a lost tail call? */
        return 0;
    }
    return -1;
}

```

我用 bcc/ebpf 实现了类似的前半部分过程的demo（主要是测试了一下能不能把 lua_state 指针保存到全局的 map里面，之后在另一个 hook 中再提取出来访问到lua_state里面的信息）

可以通过 https://github.com/yunwei37/nginx-lua-ebpf/blob/master/bcc_nginx_lua.c 访问

## 项目实现细节梳理

项目实现主要分为几个部分：

1. ebpf 性能分析工具整理和完善：

    - 需要仔细调研并且确认目前已有的 ebpf 工具对于 openresty 的性能分析帮助，以及逐个试用，并且产出分析报告；
    - 在调研的基础上由于 libbpf 的性能分析工具尚未完成，相关工具链也不成熟，因此需要进行一定的整理和基于所提供的工具集的修改开发；

2. 尝试将 lua 的堆栈追踪整合到 ebpf 的性能分析工具中，并且基于 Openresty 场景进行深度定制：

    - 虽然 libbpf-tools 工具集已经有了不少性能分析相关工具，但并没有很适合 openresty 这个场景的性能工具。目前的 ebpf 工具大部分是通用的性能分析模块功能，需要有基于 openresty 和 APISIX 的场景进行深度定制的解决方案，并且对 Apache APISIX Openresty luajit 32/luajit 64 提供良好的支持；
    - 这部分将主要基于 C/C++ 语言。我选择使用现代 C++ 语言（cpp20）开发 Eunomia 的时候也主要是看中和 libbpf 库以及 bpf 代码的良好兼容性，libbpf 库目前还在迅速更新迭代过程中，我可以直接基于 libbpf 库进行开发，不需要被其他语言（go/rust）的运行时 bpf 库所限制。现代 C++ 的开发速度和安全性应该并不会比其他语言差太多（要是编译提示能像 rust 那样好点就更好了...用了 concept 还是不够好）。

3. 将上述工具进行整合和完善：

    - 整理并发布工具集：之前实现和整理的工具集会被开源发布为类似 [openresty-systemtap-toolkit](https://github.com/openresty/openresty-systemtap-toolkit) 的一个个二进制工具版本，并且提供完整的文档和示例；该项目会被合并进入入 APISIX 的相关仓库。
    - 目前我自己正在开发一套基于 ebpf 的开源轻量级监控工具：https://github.com/yunwei37/Eunomia ，其中已经整合了数个基于 libbpf-tools 的内核观测工具，例如文件访问，系统调用，进程执行，网络连接，进程间通信等等，并且已经实现了一些性能分析指标分析。该工具基于现代 C++ 构建，可以非常方便的整合 libbpf-tools 工具的功能，并且可以集成现代的 prometheus 和 Grafana，作为指标监控可视化和预警平台；可以通过外接时序数据库进行性能指标存储和分析；我也希望能把上述工具整合进入我所实现的工具，提供开箱即用的 APISIX 性能监控解决方案。

### 项目要点和难点：

使用eBPF捕获和解析 `Apache APISIX` 中的 lua 调用堆栈信息，对其进行汇总并生成cpu火焰图：

- 利用eBPF同时捕获和解析C和Lua混合调用堆栈信息，对其进行总结，生成cpu火焰图。

    这部分还需要完成的事情主要是需要获取和补全缺少的 lua 相关符号信息，并且和 C 语言的相关信息进行整理：

    它的原理是在运行时 hook nginx 中某些特定的函数，然后拿到全局的 lua_state 指针，然后在 profile 的时候再通过 map 拿到之前保存下来的 lua_state 指针，通过这个 state 去遍历 frame 找到对应的函数信息；这一部分已接近实现，在 https://github.com/yunwei37/nginx-lua-ebpf/blob/master/bcc_nginx_lua.c 中，接下来需要把两个部分整合起来变成一个完整的工具就好了。

- 支持获取在Docker中运行的 `Apache APISIX` 进程：

    这部分在我做的工具（Eunomia）中已经实现了，其原理主要是通过 ebpf hook 每次进程的执行过程，并且输出 pid/ppid/namespace/cgroups/comm 等相关信息。从 comm （一般来说是执行的命令名称）即可捕捉到 `Apache APISIX` 的相关特征，进而通过 pid/ppid 捕捉到它进程组的一系列进程活动。

    或者在一个单一的命令行工具中也可以手动为其指定 pid，实现功能解耦。

- 支持获取 Apache APISIX Openresty luajit 32/luajit 64 模式

    需要对 luajit 32/luajit 64 的行为模式进行梳理，主要是涉及 lua_state 相关的一些指针信息，这部分难度并不高，只是需要注意细节 。

## 项目完成规划

### 第一阶段（7.1 - 7.20）

- [ ] 第一周：借助现有的 ebpf 工具进行简单改进，实现使用 eBPF 捕获和解析一次 `Apache APISIX` 中的 lua 调用堆栈信息，对其进行汇总并生成cpu火焰图
- [ ] 第二周：整理对于 luajit 32/luajit 64 的相关分析代码，改进测试场景，确保在不同内核版本，不同lua/nginx版本中，所实现的工具的可用性，并且产出相关文档；
- [ ] 第三周：需要仔细调研并且确认目前已有的 ebpf 工具对于 openresty 的性能分析帮助，以及逐个试用，并且产出分析报告；

### 第二阶段（7.20 - 8.10）

- [ ] 第一周：确认余下时间，以及需要重新整理实现的 openresty-systemtap-toolkit 工具，并按照优先级和实现的难易程度排序；尝试通过 ebpf 实现其功能；
- [ ] 第二周：尝试通过 ebpf 实现 openresty-systemtap-toolkit 的功能，并且设计相关的测试场景和性能分析场景；
- [ ] 第三周：对于所实现的 openresty-systemtap-toolkit 工具集的功能，完善相关文档，并进行充分的测试；

### 第三阶段（8.10 - 结束）

- [ ] 第一周：整理并发布工具集：之前实现和整理的工具集会被开源发布为类似 [openresty-systemtap-toolkit](https://github.com/openresty/openresty-systemtap-toolkit) 的一个个二进制工具版本，并且提供完整的文档和示例；
- [ ] 第二周：将该工具集进行集成，提供 docker 容器的版本以便进行分发；提供 prometheus 和 Grafana 作为性能指标监控工具；提供时序数据库存储连接；
- [ ] 第三周：解决在验收阶段中发现的问题，进行后续的维护和完善；