#! https://zhuanlan.zhihu.com/p/589784489
# 如何在 Linux 显微镜（LMP）项目中开启 eBPF 之旅？

eBPF 为 Linux 内核提供了可扩展性，使开发人员能够对 Linux 内核进行编程，以便根据他们的业务需求快速构建智能的或丰富的功能。

我们的 [LMP(Linux Microscope) 项目](https://github.com/linuxkerneltravel/lmp) 是为了充分挖掘 ebpf 的可能性而建立的，项目以构建 eBPF 学习社区、成为 eBPF 工具集散地、孵化 eBPF 想法和项目为目标，正在大力建设中。之前我们在 LMP 其中的 eBPF Supermarket 中包含了大量由个人开发者编写的 eBPF 工具，覆盖了网络、性能分析、安全等多种功能，我们正在尝试把其中的一些程序迁移到 eBPF Hub，一些规范化的 eBPF 程序库，可以随时下载运行，或嵌入大型应用程序中作为插件使用。

我们尝试在 eBPF Hub 中，基于 eunomia-bpf 开发框架创建符合 OCI 标准的 Wasm 和 eBPF 程序，并利用 ORAS 简化扩展 LMP 的 eBPF 分发、加载、运行能力。

## 快速使用

如果您想快速开始 eBPF，可以使用我们开发的轻量级框架之上的命令行程序 lmp-cli。当使用脚本安装好我们的框架之后，您只需要一条命令，无需任何编译，即可体会到 eBPF 的强大之处：

```console
$ lmp run sigsnoop
download with curl: https://linuxkerneltravel.github.io/lmp/sigsnoop/package.json
running and waiting for the eBPF events from perf event...
time pid tpid sig ret comm
00:21:41 109955 112863 28 0 gnome-terminal-
00:21:41 109955 112862 28 0 gnome-terminal-
...
```

如果您使用过 bcc 等 eBPF 开发工具，您一定会惊喜于 LMP 的便捷性。LMP 中包含了各种各样的 eBPF 程序，这种便捷的运行，离不开我们基于的底层框架 eunomia-bpf，它完全实现了“一次编译，处处运行”的 eBPF 跨平台目标。在 eunomia-bpf 框架下，LMP 开发的 eBPF 应用不仅可以适配任意架构和不同内核版本，而且还具有轻量级、良好的隔离性等优点，可以作为插件到嵌入大型应用之中。

## eunomia-bpf：结合 eBPF 和 Wasm 的轻量级开发框架

作为一个 eBPF 程序的轻量级开发加载框架，eunomia-bpf 基于 Wasm 运行时和 BTF 技术，包含了一个用户态动态加载框架/运行时库，以及一个简单的编译 Wasm 和 eBPF 字节码的工具链容器。

Wasm 是为了一个可移植的目标而设计的，可作为 C/C+/RUST 等高级语言的编译目标，使客户端和服务器应用程序能够在 Web 上部署。目前已经发展成为一个轻量级、高性能、跨平台和多语种的软件沙盒环境，被运用于云原生软件组件。 eunomia-bpf 将 eBPF 用户态的所有控制和数据处理逻辑全部移到 Wasm 虚拟机中，通过 Wasm module 打包和分发 eBPF 字节码，同时在 Wasm 虚拟机内部控制整个 eBPF 程序的加载和执行，将二者的优势结合了起来。

在 Wasm 模块中编写 eBPF 代码和通常熟悉的使用 libbpf 框架或 Coolbpf 开发 eBPF 程序的方式是基本一样的，Wasm 的复杂性会被隐藏在 eunomia-bpf 的编译工具链和运行时库中，开发者可以专注于 eBPF 程序的开发和调试，不需要了解 Wasm 的背景知识，也不需要担心 Wasm 的编译环境配置。

大致来说，eunomia-bpf 在 Wasm 运行时和用户态的 libbpf 中间多加了一层抽象层，使得一次编译、到处运行的 eBPF 代码可以从 JSON 对象中动态加载。JSON 对象会在编译时被包含在 Wasm 模块中，因此在运行时，我们可以通过解析 JSON 对象来获取 eBPF 程序的信息，然后动态加载 eBPF 程序。通过 Wasm module 打包和分发 eBPF 字节码，同时在 Wasm 虚拟机内部控制整个 eBPF 程序的加载和执行，eunomia-bpf 就可以将二者的优势结合起来，让任意 eBPF 程序能有如下特性：

- 可移植：让 eBPF 工具和应用不需要进行重新编译即可以跨平台分发，省去了复杂的交叉编译流程；
- 隔离性：让 eBPF 程序的加载和执行、以及用户态的数据处理流程更加安全可靠。
- 包管理：完成 eBPF 程序或工具的分发、管理、加载等工作。
- 敏捷性：使每个人都可以使用官方和未经修改的应用程序来加载自定义扩展，任何 eBPF 程序的错误修复和/或更新都可以在运行时推送和/或测试，而不需要更新和/或重新部署一个新的二进制。
- 轻量级：与 Linux 容器应用相比，Wasm 微服务冷启动的时间是 1%，可以实现 eBPF as a service，让 eBPF 程序的加载和执行变得更加轻量级、快速、简便易行。

我们已经测试了在 x86、ARM 等不同架构不同内核版本的 Linux 系统上，eunomia-bpf 框架都可以使用同一个预编译 eBPF 程序二进制，从云端一行命令获取到本地之后运行。之后 eunomia-bpf 还会添加 RISC-V 等更多架构的支持。

## 使用 lmp-cli 构建一个 eBPF 项目

如果您是一个 eBPF 工具的使用者，您可以无需任何编译流程，也不需要了解任何 eBPF 和 Wasm 的相关知识，使用 `lmp run <name>` 就可以直接运行 LMP 仓库的小程序，其中会调用`lmp pull <name>`命令从云端从库中下载对应的小程序。

如果您是一个 eBPF 程序的开发者，让我们开始创建、编译并运行一个简单的程序。在这里，我们使用基简单命令行工具 lmp-cli，概述如何从四个步骤开始构建。

### **1. 准备你的环境**

eBPF 本身是一种 Linux 内核技术，因此任何实际的 BPF 程序都必须在 Linux 内核中运行。我建议您从内核 5.4 或更新的版本开始。从 SSH 终端，检查内核版本，并确认您已经启用了 CONFIG_DEBUG_INFO_BTF：

```bash
uname -r
cat /boot/config-$(uname -r) | grep CONFIG_DEBUG_INFO_BTF
```

你会看到类似这样的输出：

```console
$ uname -r
5.15.0-48-generic

$ cat /boot/config-$(uname -r) | grep CONFIG_DEBUG_INFO_BTF
CONFIG_DEBUG_INFO_BTF=y
CONFIG_DEBUG_INFO_BTF_MODULES=y
```

安装命令行工具 lmp-cli：

```bash
curl https://github.com/GorilaMond/lmp_cli/releases/download/lmp/install.sh | sh
```

### **2. 创建**项目的内核部分

使用`lmp init`创建一个项目模板，来初始化你的内核程序，快速地投入到代码的编写中：

```bash
lmp init hello
```

成功创建项目后，您将看到如下类似的输出：

```console
$ lmp init hello
Cloning into 'ebpm-template'...
```

它实际上创建了一个项目名对应的文件夹，里面有这些文件：

```console
$ cd hello/
$ ll
...
-rw-rw-r--  1 a a 2910 10月 17 23:18 bootstrap.bpf.c
-rw-rw-r--  1 a a  392 10月 17 23:18 bootstrap.h
-rw-rw-r--  1 a a  221 10月 17 23:18 config.json
drwxrwxr-x  8 a a 4096 10月 17 23:18 .git/
drwxrwxr-x  3 a a 4096 10月 17 23:18 .github/
-rw-rw-r--  1 a a   21 10月 17 23:18 .gitignore
-rw-rw-r--  1 a a 2400 10月 17 23:18 README.md
```

内核程序模板 bootstrap.bpf.c 中默认的跟踪点为 `tp/sched/sched_process_exec`和`tp/sched/sched_process_exit`，用来跟踪新程序的执行和退出，这里不做修改。

构建内核项目，如下所示。保存您的更改，使用 `sudo lmp build` 构建内核程序，这会创建一个名为 package.json 的对象文件。

```console
$ sudo lmp build
make
  ...
  BINARY   client
  DUMP_LLVM_MEMORY_LAYOUT
  DUMP_EBPF_PROGRAM
  FIX_TYPE_INFO_IN_EBPF
  GENERATE_PACKAGE_JSON
```

### **3. 运行**内核程序

可以使用`lmp run package.json`运行内核程序，没有用户端程序对数据的处理的情况下，该框架下内核程序将会输出所有被 output 的数据：

```console
$ sudo lmp run ./package.json
running and waiting for the ebpf events from ring buffer...
time pid ppid exit_code duration_ns comm filename exit_event
```

一开始您不会看到任何数据，只有当内核的跟踪点被触发时，这里是新的进程被创建或退出时，才会输出数据。这里新建了一个虚拟终端，输出了如下数据：

```console
23:31:31 111788 109955 0 0 bash /bin/bash 0
23:31:31 111790 111788 0 0 lesspipe /usr/bin/lesspipe 0
...
```

### **4. 添加**用户态程序

我们提供的是 demo 是 C 语言版本的 Wasm 开发框架，在构建好的内核项目文件夹内，使用 `sudo lmp gen-wasm-skel` 生成一个 Wasm 用户态项目模板，app.c、eunomia-include、ewasm-skel.h 这些文件会被生成。ewasm-skel.h 是被打包为头文件的内核程序，app.c 是用户态程序的模板文件，我们可以修改它来进行自定义的数据处理，这里不做修改。

```console
$ sudo lmp gen-wasm-skel
make
  BPF      .output/client.bpf.o
...
```

使用`sudo lmp build-wasm`构建用户态程序，生成 app.wasm 文件

```console
$ sudo lmp build-wasm
make
  BPF      .output/client.bpf.o
...
```

使用`lmp run app.wasm`运行用户态程序，json 格式的输出为通用的数据处理做好了准备：

```console
$ lmp run app.wasm
running and waiting for the ebpf events from ring buffer...
{"pid":112665,"ppid":109955,"exit_code":0,"duration_ns":0,"comm":"bash","filename":"/bin/bash","exit_event":0}
{"pid":112667,"ppid":112665,"exit_code":0,"duration_ns":0,"comm":"lesspipe","filename":"/usr/bin/lesspipe","exit_event":0}
{"pid":112668,"ppid":112667,"exit_code":0,"duration_ns":0,"comm":"basename","filename":"/usr/bin/basename","exit_event":0}
...
```

## 另一个例子：使用 eBPF 打印进程内存使用状况

可以将 bootstrap.bpf.c 重命名为 procstat.bpf.c，将 bootstrap.h 重命名为 procstat.h，然后编译运行。对应的源代码如下：

procstat.bpf.c

```c
#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>
#include <bpf/bpf_core_read.h>
#include "procstat.h"

char LICENSE[] SEC("license") = "Dual BSD/GPL";

struct {
 __uint(type, BPF_MAP_TYPE_RINGBUF);
 __uint(max_entries, 256 * 1024);
} rb SEC(".maps");


SEC("kprobe/finish_task_switch")
int BPF_KPROBE(finish_task_switch, struct task_struct *prev)
{
 struct event *e;
 struct mm_rss_stat rss = {};
 struct mm_struct *mms;
 long long *t;

 e = bpf_ringbuf_reserve(&rb, sizeof(*e), 0);
 if (!e)
  return 0;

 e->pid = BPF_CORE_READ(prev, pid);
 e->vsize = BPF_CORE_READ(prev, mm, total_vm);
 e->Vdata = BPF_CORE_READ(prev, mm, data_vm);
 e->Vstk = BPF_CORE_READ(prev, mm, stack_vm);
 e->nvcsw = BPF_CORE_READ(prev, nvcsw);
 e->nivcsw = BPF_CORE_READ(prev, nivcsw);

 rss = BPF_CORE_READ(prev, mm, rss_stat);
 t = (long long *)(rss.count);
 e->rssfile = *t;
 e->rssanon = *(t + 1);
 e->vswap = *(t + 2);
 e->rssshmem = *(t + 3);
 e->size = *t + *(t + 1) + *(t + 3);

 bpf_ringbuf_submit(e, 0);
 return 0;
}
```

proc.h

```c
#ifndef __BOOTSTRAP_H
#define __BOOTSTRAP_H

#define TASK_COMM_LEN 16
#define MAX_FILENAME_LEN 127

struct event {
/*进程内存状态报告*/
    pid_t pid;
    long nvcsw;
    long nivcsw;
    long vsize;              //虚拟内存
    long size;               //物理内存
    long long rssanon;       //匿名页面
    long long rssfile;       //文件页面
    long long rssshmem;      //共享页面
    long long vswap;         //交换页面
    long long Hpages;        //hugetlbPages
    long Vdata;              //Private data segments
    long Vstk;               //User stack
    long long VPTE;
};
#endif /* __BOOTSTRAP_H */
```

具体的上报事件信息在 event 结构体中定义：

| 参数     | 含义                     |
| -------- | ------------------------ |
| vsize    | 进程使用的虚拟内存       |
| size     | 进程使用的最大物理内存   |
| rssanon  | 进程使用的匿名页面       |
| rssfile  | 进程使用的文件映射页面   |
| rssshmem | 进程使用的共享内存页面   |
| vswap    | 进程使用的交换分区大小   |
| vdata    | 进程使用的私有数据段大小 |
| vpte     | 进程页表大小             |
| vstk     | 进程用户栈大小           |

挂载点与挂载原因分析：

- 首先，获取进程级别内存使用信息需要获取到进程的 task_struct 结构体，其中在 mm_struct 成员中存在一个保存进程当前内存使用状态的数组结构，因此有关进程的大部分内存使用信息都可以通过这个数组获得。
- 其次，需要注意函数的插入点，插入点的选取关系到数据准确性是否得到保证，而在进程的内存申请，释放，规整等代码路径上都存在页面状态改变，但是数量信息还没有更新的相关结构中的情况，如果插入点这两者中间，数据就会和实际情况存在差异，所有在确保可以获取到进程 PCB 的前提下，选择在进程调度代码路径上考虑。而 finish_task_switch 函数是新一个进程第一个执行的函数，做的事却是给上一个被调度出去的进程做收尾工作，所以这个函数的参数是上一个进程的 PCB，从这块获得上一个进程的内存信息就可以确保在它没有再次被调度上 CPU 执行的这段时间内的内存数据稳定性。
- 因此最后选择将程序挂载到 finish_task_switch 函数上。数据来源有两部分，一个是 mm_struc 结构本身存在的状态信息，另一个是在 mm_rss_stat 结构中。

也可以在 bolipi 的平台中在线编译，在线体验运行 eBPF 程序：<https://bolipi.com/ebpf/home/online>

完整的代码、文档和运行结果可以在 LMP 中 eBPF_Supermarket 处找到：[eBPF_Supermarket/Memory_Subsystem/memstat/procstat](https://github.com/linuxkerneltravel/lmp/tree/develop/eBPF_Supermarket/Memory_Subsystem/memstat/procstat)

## 相关背景

LMP 项目的成立初衷是：

- 面向 eBPF 初学者和爱好者，提供 eBPF 学习资料、程序/项目案例，构建 eBPF 学习社区
- 成为 eBPF 工具集散地，我们相信每一位 eBPF 初学者和爱好者都有无限的创造力
- 孵化 eBPF 想法、相关工具、项目

LMP 目前分为四个子项目：

- eBPF_Supermarket 中包含了大量由个人开发者编写的 eBPF 工具，覆盖了网络、性能分析、安全等多种功能；
- eBPF_Hub 是规范化的 eBPF 程序库，可以随时下载运行；
- eBPF_Visualization 是为 eBPF 程序管理而开发的 web 管理系统，聚焦 eBPF 数据可视化和内核可视化；
- eBPF_Documentation 为社区收集、梳理和原创的 eBPF 相关资料和文档。

当前 LMP 项目也存在一些问题，例如对于 eBPF 工具的开发者，存在非常多而且复杂的用户态可视化、展示方案，有许多套系统提供可视化的实现并且有多种语言混合，缺乏展示标准、也难以进行可视化的整合等。因此，我们希望尝试借助 eunomia-bpf 提供的符合 OCI 标准的 Wasm 和 eBPF 程序，提供标准化、高可扩展性的基于 eBPF 的可视化、数据展示、分析平台，利用 ORAS 简化扩展 eBPF 的分发、加载、运行能力，为 eBPF 工具的开发者和使用者提供更加简单、高效的体验。

### WebAssembly

WebAssembly 是一种新的编码方式，可以在现代的网络浏览器中运行 － 它是一种低级的类汇编语言，具有紧凑的二进制格式，可以接近原生的性能运行，并为诸如 c\c++ 等语言提供一个编译目标，以便它们可以在 Web 上运行。它也被设计为可以与 JavaScript 共存，允许两者一起工作。而且，更棒的是，这是通过 W3C WebAssembly Community Group 开发的一项网络标准，并得到了来自各大主要浏览器厂商的积极参与。

尽管 WebAssembly 是为运行在 Web 上设计的，它也可以在其它的环境中良好地运行。包括从用作测试的最小化 shell ，到完全的应用环境 —— 例如：在数据中心的服务器、物联网（IoT）设备或者是移动/桌面应用程序。甚至，运行嵌入在较大程序里的 WebAssembly 也是可行的。通常，通过维持不需要 Web API 的非 Web 路径，WebAssembly 能够在许多平台上用作便携式的二进制格式，为移植性、工具和语言无关性带来巨大的好处。（因为它支持 c\c++ 级语义）

Wasm 的编译和部署流程如下：

![xxx](https://mmbiz.qpic.cn/mmbiz_png/xHicTWic3y1Dtt9CBh8SCA6QQdW7jTrAibKoxAVrXfe0slwf8iav97kbxe2bRVXclfias4hlTDI4fNBQ2RXvFBe9BEA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)​
_wasm-compile-deploy_

### OCI(Open Container Initiative)

开放容器协议(OCI)是一个轻量级，开放的治理结构，为容器技术定义了规范和标准。在 Linux 基金会的支持下成立，由各大软件企业构成，致力于围绕容器格式和运行时创建开放的行业标准。其中包括了使用 Container Registries 进行工作的 API，正式名称为 OCI 分发规范(又名“distribution-spec”)。这个发布规范是基于 Docker 公司最初发布的开源注册服务器编写的，它存在于 GitHub 的[distribution/distribution](https://github.com/distribution/distribution)（现在是[CNCF](https://www.cncf.io/)项目）上。

OCI 目前提出的规范有如下这些：

| 名称                                                                              | 版本   |
| --------------------------------------------------------------------------------- | ------ |
| [Runtime Specification](https://github.com/opencontainers/runtime-spec)           | v1.0.2 |
| [Image Format](https://github.com/opencontainers/image-spec)                      | v1.0.2 |
| [Distribution Specification](https://github.com/opencontainers/distribution-spec) | v1.0.1 |

其中 runtime 和 image 的规范都已经正式发布，而 distribution 的还在工作之中。runtime 规范中介绍了如何运行解压缩到磁盘上的 [`Filesystem Bundle`](https://github.com/opencontainers/runtime-spec/blob/master/bundle.md)。在 OCI 标准下，运行一个容器的过程就是下载一个 OCI 的镜像，将其解压到某个 `Filesystem Bundle` 中，然后某个 OCI Runtime 就会运行这个 Bundle。

伴随着 image spec 与 distribution spec 的演化，人们开始逐步认识到除了 Container Images 之外，Registries 还能够用来分发 Kubernetes Deployment Files, Helm Charts, docker-compose, [CNAB](https://cnab.io/) 等产物。它们可以共用同一套 API，同一套存储，将 Registries 作为一个云存储系统。这就为带来了 OCI Artifacts 的概念，用户能够把所有的产物都存储在 OCI 兼容的 Registiry 当中并进行分发。为此，Microsoft 将 [oras](https://github.com/deislabs/oras) 作为一个 client 端实现捐赠给了社区，包括 Harbor 在内的多个项目都在积极的参与。

### ORAS(OCI Registry As Storage)

Registries 正在逐渐演变为通用的组件存储库。为了实现这一目标，ORAS 项目提供了一种将 OCI Artifacts 从 OCI Registries 提交和拉取的方法。正在寻求通用 Registries 客户端的用户可以从[ORAS CLI](https://oras.land/CLI/)中得到帮助，而开发人员可以在[ORAS 客户端的开发库](https://oras.land/client_libraries/)之上构建自己的客户端。

ORAS 的工作原理与您可能已经熟悉的工具(如 docker)类似。它允许您向 OCI Registries 推送(上传)和提取(下载)内容，并处理登录(身份验证)和令牌流(授权)。ORAS 的不同之处在于将焦点从容器映像转移到其他类型的组件上。

因此，鼓励新的 OCI Artifacts 的作者定义他们自己的组件媒体类型，以使得他们的用户知道如何对其进行操作。

如果您希望立即开始发布 OCI Artifacts，请查看[ORAS CLI](https://oras.land/CLI/)。希望提供给自己用户体验的开发人员应该使用一个 ORAS 客户端开发库。

## 未来的发展方向

未来 LMP 会专注于更多的基于 eBPF 的应用工具和实践的开发：

1. 进一步完善 ORAS 和 OCI 镜像相关的支持；
2. 重构并迁移现有的 eBPF 工具，提供完整的、开箱即用的分析工具组件，例如性能工程等方面；
3. 探索和孵化更多的 eBPF 想法、相关工具、项目；

我们所基于的 eunomia-bpf 项目也会继续完善，专注于提供一个底层的 eBPF 开发平台和运行时基础设施，力求带来更好的开发和移植体验：

1. 测试更多平台和内核版本的支持，目前已经在 `ARM64` 和 `x86_64` 上成功移植并运行，接下来会对低内核版本、Android、RISC-V 等平台，以及嵌入式、边缘计算相关的设备进行更进一步的测试；也许在未来，我们还可以提供 Windows 上的 eBPF 程序支持和类似的开发体验；
2. 提供标准化、稳定的 JSON 和 Wasm 接口协议规范以及 OCI 镜像规范，不和任何的供应商或云服务绑定。如果不使用 eunomia-bpf 相关的底层运行时，或使用自定义的 Wasm 运行时，也可以通过标准化的接口来使用 LMP 中已经有的大量 eBPF 程序生态。
3. 提供更友好的用户态开发接口，以及更多的用户态开发语言 SDK，例如 Go、Rust、Python 等；
4. 进行更多关于 Wasm 和 eBPF 结合的探索；

## 参考资料 & 推荐阅读

- [eunomia-bpf: 一个 eBPF 程序动态加载框架](https://github.com/eunomia-bpf/eunomia-bpf)
- [LMP project: Linux 显微镜](https://github.com/linuxkerneltravel/lmp)
- [OCI Registry As Storage (oras.land)](https://oras.land/)
- [当 Wasm 遇见 eBPF：使用 WebAssembly 编写、分发、加载运行 eBPF 程序 | 龙蜥技术 (qq.com)](https://mp.weixin.qq.com/s/ryT7OqWngCjcCkfeSKjutA)
- [开放容器标准(OCI) 内部分享 (xuanwo.io)](https://xuanwo.io/2019/08/06/oci-intro/)
- [WebAssembly | MDN (mozilla.org)](https://developer.mozilla.org/zh-CN/docs/WebAssembly)
- [非网络嵌入 - WebAssembly 中文网|Wasm 中文文档](http://webassembly.org.cn/docs/non-web/)
- [eBPF 在线学习平台：bolipi.com/ebpf/home/online](https://bolipi.com/ebpf/home/online)
