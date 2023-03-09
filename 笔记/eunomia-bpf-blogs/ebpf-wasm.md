#!<https://zhuanlan.zhihu.com/p/573941739>

# 当 Wasm 遇见 eBPF ：使用 WebAssembly 编写、分发、加载运行 eBPF 程序

当今云原生世界中两个最热门的轻量级代码执行沙箱/虚拟机是 eBPF 和 WebAssembly。它们都运行从 C、C++ 和 Rust 等语言编译的高性能字节码程序，并且都是跨平台、可移植的。二者最大的区别在于： eBPF 在 Linux 内核中运行，而 WebAssembly 在用户空间中运行。我们希望能做一些将二者相互融合的尝试：使用 Wasm 来编写通用的 eBPF 程序，然后可以将其分发到任意不同版本、不同架构的 Linux 内核中，无需重新编译即可运行。

## WebAssembly vs. eBPF

WebAssembly(缩写 Wasm)是基于堆栈虚拟机的二进制指令格式。Wasm 是为了一个可移植的目标而设计的，可作为 C/C+/RUST 等高级语言的编译目标，使客户端和服务器应用程序能够在 Web 上部署。Wasm 的运行时有多种实现，包括浏览器和独立的系统，它可以用于视频和音频编解码器、图形和 3D、多媒体和游戏、密码计算或便携式语言实现等应用。

尽管 Wasm 是为了提高网页中性能敏感模块表现而提出的字节码标准, 但是 Wasm 却不仅能用在浏览器(broswer)中, 也可以用在其他环境中。Wasm 已经发展成为一个轻量级、高性能、跨平台和多语种的软件沙盒环境，被运用于云原生软件组件。与 Linux 容器相比，WebAssembly 的启动速度可以提高 100 倍，内存和磁盘占用空间要小得多，并且具有更好定义的安全沙箱。然而，权衡是 WebAssembly 需要自己的语言 SDK 和编译器工具链，使其成为比 Linux 容器更受限制的开发环境。WebAssembly 越来越多地用于难以部署 Linux 容器或应用程序性能至关重要的边缘计算场景。

Wasm 的编译和部署流程如下：

![wasm-compile-deploy](../img/wasm-compile.png)

通常可以将 C/C+/RUST 等高级语言编译为 Wasm 字节码，在 Wasm 虚拟机中进行加载运行。Wasm 虚拟机会通过解释执行或 JIT 的方式，将 Wasm 字节码翻译为对应平台（ x86/arm 等）的机器码运行。

eBPF 源于 BPF，本质上是处于内核中的一个高效与灵活的虚拟机组件，以一种安全的方式在许多内核 hook 点执行字节码。BPF 最初的目的是用于高效网络报文过滤，经过重新设计，eBPF 不再局限于网络协议栈，已经成为内核顶级的子系统，演进为一个通用执行引擎。开发者可基于 eBPF 开发性能分析工具、软件定义网络、安全等诸多场景。eBPF 有一些编程限制，需要经过验证器确保其在内核应用场景中是安全的（例如，没有无限循环、内存越界等），但这也意味着 eBPF 的编程模型不是图灵完备的。相比之下，WebAssembly 是一种图灵完备的语言，具有能够打破沙盒和访问原生 OS 库的扩展 WASI (WebAssembly System Interface, Wasm 系统接口) ，同时 Wasm 运行时可以安全地隔离并以接近原生的性能执行用户空间代码。二者的领域主体上有不少差异，但也有不少相互重叠的地方。

有一些在 Linux 内核中运行 WebAssembly 的尝试，然而基本上不太成功。 eBPF 是这个应用场景下更好的选择。但是 WebAssembly 程序可以处理许多类内核的任务，可以被 AOT 编译成原生应用程序。来自 CNCF 的 WasmEdge Runtime 是一个很好的基于 LLVM 的云原生 WebAssembly 编译器。原生应用程序将所有沙箱检查合并到原生库中，这允许 WebAssembly 程序表现得像一个独立的 unikernel “库操作系统”。此外，这种 AOT 编译的沙盒 WebAssembly 应用程序可以在微内核操作系统（如 seL4）上运行，并且可以接管许多“内核级”任务[1]。

虽然 WebAssembly 可以下降到内核级别，但 eBPF 也可以上升到应用程序级别。在 sidecar 代理中，Envoy Proxy 开创了使用 Wasm 作为扩展机制对数据平面进行编程的方法。开发人员可以用 C、C++、Rust、AssemblyScript、Swift 和 TinyGo 等语言编写特定应用的代理逻辑，并将该模块编译到 Wasm 中。通过 proxy-Wasm 标准，代理可以在 Wasmtime 和 WasmEdge 等高性能运行机制中执行那些 Wasm 插件[2]。

尽管目前有不少应用程序同时使用了二者，但大多数时候这两个虚拟机是相互独立并且没有交集的：例如在可观测性应用中，通过 eBPF 探针获取数据，获取数据之后在用户态引入 Wasm 插件模块，进行可配置的数据处理。Wasm 模块和 eBPF 程序的分发、运行、加载、控制相互独立，仅仅存在数据流的关联。

## 我们的一次尝试

一般来说，一个完整的 eBPF 应用程序分为用户空间程序和内核程序两部分：

- 用户空间程序负责加载 BPF 字节码至内核，或负责读取内核回传的统计信息或者事件详情，进行相关的数据处理和控制；
- 内核中的 BPF 字节码负责在内核中执行特定事件，如需要也会将执行的结果通过 maps 或者 perf-event 事件发送至用户空间

用户态程序可以在加载 eBPF 程序前控制一些 eBPF 程序的参数和变量，以及挂载点；也可以通过 map 等等方式进行用户态和内核态之间的双向通信。通常来说用户态的 eBPF 程序可以基于 `libbpf` 库进行开发，来控制内核态 eBPF 程序的装载和运行。那么，如果将用户态的所有控制和数据处理逻辑全部移到 Wasm 虚拟机中，通过 Wasm module 打包和分发 eBPF 字节码，同时在 Wasm 虚拟机内部控制整个 eBPF 程序的加载和执行，也许我们就可以将二者的优势结合起来，让任意 eBPF 程序能有如下特性：

- `可移植`：让 eBPF 工具和应用完全平台无关、可移植，不需要进行重新编译即可以跨平台分发；
- `隔离性`：借助 Wasm 的可靠性和隔离性，让 eBPF 程序的加载和执行、以及用户态的数据处理流程更加安全可靠；事实上一个 eBPF 应用的用户态控制代码通常远远多于内核态；
- `包管理`：借助 Wasm 的生态和工具链，完成 eBPF 程序或工具的分发、管理、加载等工作，目前 eBPF 程序或工具生态可能缺乏一个通用的包管理或插件管理系统；
- `跨语言`：目前 eBPF 程序由多种用户态语言开发（如 Go\Rust\C\C++\Python 等），超过 30 种编程语言可以被编译成 WebAssembly 模块，允许各种背景的开发人员（C、Go、Rust、Java、TypeScript 等）用他们选择的语言编写 eBPF 的用户态程序，而不需要学习新的语言；
- `敏捷性`：对于大型的 eBPF 应用程序，可以使用 Wasm 作为插件扩展平台：扩展程序可以在运行时直接从控制平面交付和重新加载。这不仅意味着每个人都可以使用官方和未经修改的应用程序来加载自定义扩展，而且任何 eBPF 程序的错误修复和/或更新都可以在运行时推送和/或测试，而不需要更新和/或重新部署一个新的二进制；
- `轻量级`：WebAssembly 微服务消耗 1% 的资源，与 Linux 容器应用相比，冷启动的时间是 1%：我们也许可以借此实现 eBPF as a service，让 eBPF 程序的加载和执行变得更加轻量级、快速、简便易行；

eunomia-bpf 是 `eBPF 技术探索 SIG` [3] [5] 中发起并孵化的项目，目前也已经在 [github](https://github.com/eunomia-bpf/eunomia-bpf) [4] 上开源。eunomia-bpf 是一个 eBPF 程序的轻量级开发加载框架，包含了一个用户态动态加载框架/运行时库，以及一个简单的编译 Wasm 和 eBPF 字节码的工具链容器。事实上，在 Wasm 模块中编写 eBPF 代码和通常熟悉的使用 libbpf 框架或 Coolbpf 开发 eBPF 程序的方式是基本一样的，Wasm 的复杂性会被隐藏在 eunomia-bpf 的编译工具链和运行时库中，开发者可以专注于 eBPF 程序的开发和调试，不需要了解 Wasm 的背景知识，也不需要担心 Wasm 的编译环境配置。

### 使用 Wasm 模块分发、动态加载 eBPF 程序

eunomia-bpf 库包含一个简单的命令行工具（ecli），包含了一个小型的 Wasm 运行时模块和 eBPF 动态装载的功能，可以直接下载下来后进行使用：

```console
# download the release from https://github.com/eunomia-bpf/eunomia-bpf/releases/latest/download/ecli
$ wget https://aka.pw/bpf-ecli -O ecli && chmod +x ./ecli
$ sudo ./ecli run https://eunomia-bpf.github.io/eunomia-bpf/sigsnoop/app.wasm
2022-10-11 14:05:50 URL:https://eunomia-bpf.github.io/eunomia-bpf/sigsnoop/app.wasm [70076/70076] -> "/tmp/ebpm/app.wasm" [1]
running and waiting for the ebpf events from perf event...
{"pid":1709490,"tpid":1709077,"sig":0,"ret":0,"comm":"node","sig_name":"N/A"}
{"pid":1712603,"tpid":1717412,"sig":2,"ret":0,"comm":"kworker/u4:3","sig_name":"SIGINT"}
{"pid":1712603,"tpid":1717411,"sig":2,"ret":0,"comm":"kworker/u4:3","sig_name":"SIGINT"}
{"pid":0,"tpid":847,"sig":14,"ret":0,"comm":"swapper/1","sig_name":"SIGALRM"}
{"pid":1709490,"tpid":1709077,"sig":0,"ret":0,"comm":"node","sig_name":"N/A"}
{"pid":1709139,"tpid":1709077,"sig":0,"ret":0,"comm":"node","sig_name":"N/A"}
{"pid":1717420,"tpid":1717419,"sig":17,"ret":0,"comm":"cat","sig_name":"SIGCHLD"}
```

ecli 会自动从网页上下载并加载 sigsnoop/app.wasm 这个 wasm 模块，它包含了一个 eBPF 程序，用于跟踪内核中进程的信号发送和接收。这里我们可以看到一个简单的 JSON 格式的输出，包含了进程的 PID、信号的类型、发送者和接收者，以及信号名称等信息。它也可以附带一些命令行参数，例如：

```console
$ wget https://eunomia-bpf.github.io/eunomia-bpf/sigsnoop/app.wasm
2022-10-11 14:08:07 (40.5 MB/s) - ‘app.wasm.1’ saved [70076/70076]

$ sudo ./ecli run app.wasm -h
Usage: sigsnoop [-h] [-x] [-k] [-n] [-p PID] [-s SIGNAL]
Trace standard and real-time signals.


    -h, --help  show this help message and exit
    -x, --failed  failed signals only
    -k, --killed  kill only
    -p, --pid=<int>  target pid
    -s, --signal=<int>  target signal

$ sudo ./ecli run app.wasm -p 1641
running and waiting for the ebpf events from perf event...
{"pid":1641,"tpid":14900,"sig":23,"ret":0,"comm":"YDLive","sig_name":"SIGURG"}
{"pid":1641,"tpid":14900,"sig":23,"ret":0,"comm":"YDLive","sig_name":"SIGURG"}
```

我们可以通过 -p 控制它追踪哪个进程，在内核态 eBPF 程序中进行一些过滤和处理。同样也可以使用 ecli 来动态加载使用其他的工具，例如 opensnoop：

```console
$ sudo ./ecli run https://eunomia-bpf.github.io/eunomia-bpf/opensnoop/app.wasm
2022-10-11 14:11:56 URL:https://eunomia-bpf.github.io/eunomia-bpf/opensnoop/app.wasm [61274/61274] -> "/tmp/ebpm/app.wasm" [1]
running and waiting for the ebpf events from perf event...
{"ts":0,"pid":2344,"uid":0,"ret":26,"flags":0,"comm":"YDService","fname":"/proc/1718823/cmdline"}
{"ts":0,"pid":2344,"uid":0,"ret":26,"flags":0,"comm":"YDService","fname":"/proc/1718824/cmdline"}
{"ts":0,"pid":2344,"uid":0,"ret":26,"flags":0,"comm":"YDService","fname":"/proc/self/stat"}
```

opensnoop 会追踪进程的 open() 调用，即内核中所有的打开文件操作，这里我们可以看到进程的 PID、UID、返回值、调用标志、进程名和文件名等信息。内核态的 eBPF 程序会被包含在 Wasm 模块中进行分发，在加载的时候通过 BTF 信息和 libbpf 进行重定位操作，以适应不同的内核版本。同时，由于用户态的相关处理代码完全由 Wasm 编写，内核态由 eBPF 指令编写，因此不受具体指令集（x86、ARM 等）的限制，可以在不同的平台上运行。

### 使用 Wasm 开发和打包 eBPF 程序

同样，以上文所述的 sigsnoop 为例，要跟踪进程的信号发送和接收，我们首先需要在 sigsnoop.bpf.c 中编写内核态的 eBPF 代码：

```c
#include <vmlinux.h>
#include <bpf/bpf_helpers.h>
#include "sigsnoop.h"

const volatile pid_t filtered_pid = 0;
.....

struct {
 __uint(type, BPF_MAP_TYPE_PERF_EVENT_ARRAY);
 __uint(key_size, sizeof(__u32));
 __uint(value_size, sizeof(__u32));
} events SEC(".maps");

SEC("tracepoint/signal/signal_generate")
int sig_trace(struct trace_event_raw_signal_generate *ctx)
{
 struct event event = {};
 pid_t tpid = ctx->pid;
 int ret = ctx->errno;
 int sig = ctx->sig;
 __u64 pid_tgid;
 __u32 pid;

 ...
 pid_tgid = bpf_get_current_pid_tgid();
 pid = pid_tgid >> 32;
 if (filtered_pid && pid != filtered_pid)
  return 0;

 event.pid = pid;
 event.tpid = tpid;
 event.sig = sig;
 event.ret = ret;
 bpf_get_current_comm(event.comm, sizeof(event.comm));
 bpf_perf_event_output(ctx, &events, BPF_F_CURRENT_CPU, &event, sizeof(event));
 return 0;
}

char LICENSE[] SEC("license") = "Dual BSD/GPL";
```

这里我们使用 `tracepoint/signal/signal_generate` 这个 tracepoint 来在内核中追踪信号的产生事件。内核态代码通过 BPF_MAP_TYPE_PERF_EVENT_ARRAY 往用户态导出信息，为此我们需要在 sigsnoop.h 头文件，中定义一个导出信息的结构体：

```c
#ifndef __SIGSNOOP_H
#define __SIGSNOOP_H

#define TASK_COMM_LEN 16

struct event {
 unsigned int pid;
 unsigned int tpid;
 int sig;
 int ret;
 char comm[TASK_COMM_LEN];
};

#endif /* __SIGSNOOP_H */
```

可以直接使用 eunomia-bpf 的编译工具链将其编译为 JSON 格式，生成一个 package.json 文件，并且可以直接使用 ecli 加载运行：

```console
$ docker run -it -v `pwd`/:/src/ yunwei37/ebpm:latest
make
  BPF      .output/client.bpf.o
  GEN-SKEL .output/client.skel.h
  CC       .output/client.o
  CC       .output/cJSON.o
  CC       .output/create_skel_json.o
  BINARY   client
  DUMP_LLVM_MEMORY_LAYOUT
  DUMP_EBPF_PROGRAM
  FIX_TYPE_INFO_IN_EBPF
  GENERATE_PACKAGE_JSON

$ sudo ./ecli run package.json
running and waiting for the ebpf events from perf event...
time pid tpid sig ret comm
14:39:39 1723835 1723834 17 0 dirname
14:39:39 1723836 1723834 17 0 chmod
14:39:39 1723838 1723837 17 0 ps
14:39:39 1723839 1723837 17 0 grep
14:39:39 1723840 1723837 17 0 grep
14:39:39 1723841 1723837 17 0 wc
```

我们所有的编译工具链都已经打包成了 docker 镜像的形式并发布到了 docker hub 上，可以直接开箱即用。此时动态加载运行的只有内核态的 eBPF 代码和一些辅助信息，帮助 eunomia-bpf 库自动获取内核态往用户态上报的事件。如果我们想要在用户态进行一些参数配置和调整，以及数据处理流程，我们需要在用户态编写代码，将内核态的 eBPF 代码和用户态的代码打包成一个完整的 eBPF 程序。

可以直接一行命令，生成 eBPF 程序的用户态 WebAssembly 开发框架：

```console
$ docker run -it -v `pwd`/:/src/ yunwei37/ebpm:latest gen-wasm-skel
make
  GENERATE_PACKAGE_JSON
  GEN-Wasm-SKEL
$ ls
app.c eunomia-include ewasm-skel.h package.json README.md  sigsnoop.bpf.c  sigsnoop.h
```

我们提供的是 C 语言版本的 Wasm 开发框架，它包含如下这些文件：

- ewasm-skel.h：用户态 WebAssembly 开发框架的头文件，包含了预编译的 eBPF 程序字节码，和 eBPF 程序框架辅助信息，用来动态加载；
- eunomia-include：一些 header-only 的库函数和辅助文件，用来辅助开发；
- app.c：用户态 WebAssembly 程序的主要代码，包含了 eBPF 程序的主要逻辑，以及 eBPF 程序的数据处理流程。

以 sigsnoop 为例，用户态包含一些命令行解析、配置 eBPF 程序和数据处理的代码，会将根据 signal number 将信号事件的英文名称添加到事件中：

```c
....
int main(int argc, const char** argv)
{
  struct argparse_option options[] = {
        OPT_HELP(),
        OPT_BOOLEAN('x', "failed", &failed_only, "failed signals only", NULL, 0, 0),
        OPT_BOOLEAN('k', "killed", &kill_only, "kill only", NULL, 0, 0),
        OPT_INTEGER('p', "pid", &target_pid, "target pid", NULL, 0, 0),
  OPT_INTEGER('s', "signal", &target_signal, "target signal", NULL, 0, 0),
        OPT_END(),
    };

  struct argparse argparse;
  argparse_init(&argparse, options, usages, 0);
  argparse_describe(&argparse, "Trace standard and real-time signals.\n", "");
  argc = argparse_parse(&argparse, argc, argv);

  cJSON *program = cJSON_Parse(program_data);
  program = set_bpf_program_global_var(program, "filtered_pid", cJSON_CreateNumber(target_pid));
  program = set_bpf_program_global_var(program, "target_signal", cJSON_CreateNumber(target_signal));
  program = set_bpf_program_global_var(program, "failed_only", cJSON_CreateBool(failed_only));
  return start_bpf_program(cJSON_PrintUnformatted(program));
}

int process_event(int ctx, char *e, int str_len)
{
 cJSON *json = cJSON_Parse(e);
 int sig = cJSON_GetObjectItem(json, "sig")->valueint;
 const char *name = sig_name[sig];
 cJSON_AddItemToObject(json, "sig_name", cJSON_CreateString(name));
 char *out = cJSON_PrintUnformatted(json);
 printf("%s\n", out);
 return 0;
}
```

最后使用容器镜像即可一行命令完成 WebAssembly/eBPF 程序的编译和打包，使用 ecli 即可一键运行：

```console
$ docker run -it -v `pwd`/:/src/ yunwei37/ebpm:latest build-wasm
make
  GENERATE_PACKAGE_JSON
  BUILD-Wasm
build app.wasm success
$ sudo ./ecli run app.wasm -h
Usage: sigsnoop [-h] [-x] [-k] [-n] [-p PID] [-s SIGNAL]
```

由于我们基于一次编译、到处运行的 libbpf 框架完成加载和启动 eBPF 程序的操作，因此编译和运行两个步骤是完全分离的，可以通过网络或任意方式直接进行 eBPF 程序的分发和部署，不依赖于特定内核版本。借助 WebAssembly 的轻量级特性，eBPF 程序的启动速度也比通常的使用镜像形式分发的 libbpf 程序快上不少，通常只需不到 100 ms 的时间即可完成，比起使用 BCC 部署启动时，使用 LLVM、Clang 编译运行消耗的时间和大量资源，更是有了质的飞跃。

上面提及的示例程序的完整代码，可以参考这里[6]。

### 演示视频

我们也有一个在 B 站上的演示视频，演示了如何从 bcc/libbpf-tools 中移植一个 eBPF 工具程序到 eunomia-bpf 中，并且使用 Wasm 或 JSON 文件来分发、加载 eBPF 程序：[https://www.bilibili.com/video/BV1JN4y1A76k](https://www.bilibili.com/video/BV1JN4y1A76k)

## 我们是如何做到的

`ecli` 是基于我们底层的 eunomia-bpf 库和运行时实现的一个简单的命令行工具。我们的项目架构如下图所示：

![arch](../img/eunomia-arch.png)

`ecli` 工具基于 `ewasm` 库实现，`ewasm` 库包含一个 WAMR(wasm-micro-runtime) 运行时，以及基于 libbpf 库构建的 eBPF 动态装载模块。大致来说，我们在 `Wasm` 运行时和用户态的 `libbpf` 中间多加了一层抽象层（`eunomia-bpf` 库），使得一次编译、到处运行的 eBPF 代码可以从 JSON 对象中动态加载。JSON 对象会在编译时被包含在 Wasm 模块中，因此在运行时，我们可以通过解析 JSON 对象来获取 eBPF 程序的信息，然后动态加载 eBPF 程序。

使用 Wasm 或 JSON 编译分发 eBPF 程序的流程图大致如下：

![flow](../img/eunomia-bpf-flow.png)

大致来说，整个 eBPF 程序的编写和加载分为三个部分：

1. 用 eunomia-cc 工具链将内核的 eBPF 代码骨架和字节码编译为 JSON 格式
2. 在用户态开发的高级语言（例如 C 语言）中嵌入 JSON 数据，并提供一些 API 用于操作 JSON 形态的 eBPF 程序骨架
3. 将用户态程序和 JSON 数据一起编译为 Wasm 字节码并打包为 Wasm 模块，然后在目标机器上加载并运行 Wasm 程序
4. 从 Wasm 模块中加载内嵌的 JSON 数据，用 eunomia-bpf 库动态装载和配置 eBPF 程序骨架。

我们需要完成的仅仅是少量的 native API 和 Wasm 运行时的绑定，并且在 Wasm 代码中处理 JSON 数据。你可以在一个单一的 `Wasm` 模块中拥有多个 `eBPF` 程序。如果不使用我们提供的 Wasm 运行时，或者想要使用其他语言进行用户态的 eBPF 辅助代码的开发，在我们提供的 `eunomia-bpf` 库基础上完成一些 WebaAssembly 的绑定即可。

另外，对于 eunomia-bpf 库而言，不需要 Wasm 模块和运行时同样可以启动和动态加载 eBPF 程序，不过此时动态加载运行的就只是内核态的 eBPF 程序字节码。你可以手动或使用任意语言修改 JSON 对象来控制 eBPF 程序的加载和参数，并且通过 eunomia-bpf 自动获取内核态上报的返回数据。对于初学者而言，这可能比使用 WebAssembly 更加简单方便：只需要编写内核态的 eBPF 程序，然后使用 eunomia-cc 工具链将其编译为 JSON 格式，最后使用 eunomia-bpf 库加载和运行即可。完全不用考虑任何用户态的辅助程序，包括 Wasm 在内。具体可以参考我们的使用手册[7]或示例代码[8]。

## 未来的方向

目前 eunomia-bpf 的工具链的实现还远远谈不上完善，只是有一个可行性验证的版本。对于一个开发工具链来说，具体的 API 标准和相关的生态是非常重要的，我们希望如果有机会的话，也许可以和 SIG 社区的其他成员一起讨论并形成一个具体的 API 标准，能够基于 eBPF 和 Wasm 等技术，共同提供一个通用的、跨平台和内核版本的插件生态，为各自的应用增加 eBPF 和 Wasm 的超能力。

目前 eunomia-bpf 跨内核版本的动态加载特性还依赖于内核的 BTF 信息，SIG 社区的 Coolbpf 项目[9]本身能提供 BTF 的自动生成、低版本内核的适配功能，未来低版本内核的支持会基于 Coolbpf 的现有的部分完成。同时，我们也会给 Coolbpf 的 API 实现、远程编译后端提供类似于 eunomia-bpf 的内核态编译和运行完全分离的功能，让使用 Coolbpf API 开发 eBPF 的程序，在远程编译一次过后可以在任意内核版本和架构上直接使用，在部署时无需再次连接远程服务器；也可以将编译完成的 eBPF 程序作为 Go、Python、Rust 等语言的开发包直接使用，让开发者能轻松获得 eBPF 程序上报的信息，而完全不需要再次进行任何 eBPF 程序的编译过程。

SIG 社区孵化于高校的 Linux Microscope (LMP) 项目[10]中，也已经有一些基于 eunomia-bpf 提供通用的、规范化、可以随时下载运行的 eBPF 程序或工具库的计划，目前还在继续完善的阶段。

## 参考资料

1. eBPF 和 WebAssembly：哪种 VM 会制霸云原生时代? [https://juejin.cn/post/7043721713602789407](https://juejin.cn/post/7043721713602789407)
2. eBPF 和 Wasm：探索服务网格数据平面的未来: [https://cloudnative.to/blog/ebpf-wasm-service-mesh/](https://cloudnative.to/blog/ebpf-wasm-service-mesh/)
3. eBPF 技术探索 SIG 主页： [https://openanolis.cn/sig/ebpfresearch](https://openanolis.cn/sig/ebpfresearch)
4. eunomia-bpf Github 仓库：<https://github.com/eunomia-bpf/eunomia-bpf>
5. eunomia-bpf 龙蜥社区镜像仓库：[https://gitee.com/anolis/eunomia](https://gitee.com/anolis/eunomia)
6. sigsnoop 示例代码：<https://gitee.com/anolis/eunomia/tree/master/examples/bpftools/sigsnoop>
7. eunomia-bpf 用户手册：<https://openanolis.cn/sig/ebpfresearch/doc/646023027267993641>
8. 更多示例代码：<https://gitee.com/anolis/eunomia/tree/master/examples/bpftools/sigsnoop>
9. Coolbpf 项目介绍：<https://openanolis.cn/sig/ebpfresearch/doc/633529753894377555>
10. LMP 项目介绍：<https://openanolis.cn/sig/ebpfresearch/doc/633661297090877527>
