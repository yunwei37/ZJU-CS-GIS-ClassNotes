# 300+ 行从零开始实现超轻量级 Wasm + eBPF 通用运行时平台

## wasm-bpf中ebpf和wasm的通信过程

libbpf API 为 wasm 程序提供了一个仅包含头文件的库，您可以在 libbpf-wasm.h（wasm-include/libbpf-wasm.h）中找到它。wasm 程序可以使用 libbpf API 和 syscall 操作 BPF 对象，例如：

```
/* Load and verify BPF application */
skel = bootstrap_bpf__open();
/* Parameterize BPF code with minimum duration parameter */
skel->rodata->min_duration_ns = env.min_duration_ms * 1000000ULL;
/* Load & verify BPF programs */
err = bootstrap_bpf__load(skel);
/* Attach tracepoints */
err = bootstrap_bpf__attach(skel);
```

rodata 部分用于存储 BPF 程序中的全局变量，bss 部分用于存储用户空间代码中的全局变量，这些全局变量将在 bpftool gen skeleton time 映射到正确的偏移量，因此不需要在 Wasm 中编译 libelf 库，运行时仍可动态加载和操作 BPF 对象。

Wasm 端的 C 代码与本地 libbpf 代码略有不同，但它可以从 eBPF 端提供大部分功能，例如，从环形缓冲区或 perf 缓冲区轮询，从 Wasm 端和 eBPF 端访问映射，加载、附加和分离 BPF 程序等。它可以支持大量的 eBPF 程序类型和映射，涵盖从跟踪、网络、安全等方面的大多数 eBPF 程序的使用场景。

由于wasm端缺少一些功能，例如信号处理程序还不支持（2023年2月），原始的C代码无法直接编译为wasm，您需要稍微修改代码以使其工作。我们将尽最大努力使wasm端的libbpf API与本机libbpf API尽可能相似，以便用户空间代码可以在未来直接编译为wasm。我们还将尽快提供更多语言绑定（Rust，Go等）的wasm端bpf API。

该轮询API将是环形缓冲区和性能缓冲区的一个封装，用户空间代码可以使用相同的API从环形缓冲区或性能缓冲区中轮询事件，具体取决于BPF程序中指定的类型。例如，环形缓冲区轮询定义为BPF_MAP_TYPE_RINGBUF的映射：

```
struct {
    __uint(type, BPF_MAP_TYPE_RINGBUF);
    __uint(max_entries, 256 * 1024);
} rb SEC(".maps");
```

你可以使用以下代码从环形缓冲区轮询事件：

```
rb = bpf_buffer__open(skel->maps.rb, handle_event, NULL);
/* Process events */
printf("%-8s %-5s %-16s %-7s %-7s %s\n", "TIME", "EVENT", "COMM", "PID",
       "PPID", "FILENAME/EXIT CODE");
while (!exiting) {
    // poll buffer
    err = bpf_buffer__poll(rb, 100 /* timeout, ms */);
```

环形缓冲区轮询不需要序列化开销。bpf_buffer__poll API 将调用 handle_event 函数来处理环形缓冲区中的事件数据。

运行时基于 libbpf CO-RE（编译一次-随处运行）API，用于将 bpf 对象加载到内核中，因此 wasm-bpf 程序不受它编译的内核版本的影响，可以在任何支持 BPF CO-RE 的内核版本上运行。

## wasm-bpf是如何工作的？

`wasm-bpf` 运行时需要两个部分: `主机侧`(Wasm 运行时之外) 以及 `Wasm 客户侧`(Wasm 运行时内)。

- host 侧: （见 [src](src) 以及 [include](include) 文件夹）
  - 主机侧是一个构建在 [libbpf](https://github.com/libbpf/libbpf) 和 [WAMR](https://github.com/bytecodealliance/wasm-micro-runtime) 之上的运行时。
  - 使用同一套工具链，任何人用任何 wasm 运行时或者任何 ebpf 用户态库，以及任何语言，都可以在两三百行三四百行内轻松实现一套 wasm+ebpf 运行时平台，运行几乎所有的 ebpf 应用场景。

- wasm 侧：
  - 一个用于给 Wasm 客户侧 `C/C++` 代码提供 libbpf API的头文件库([`libbpf-wasm`](wasm-include/libbpf-wasm.h))。
  - 一个用来生成 Wasm-eBPF `skeleton` 头文件以及生成用于在主机侧和 Wasm 客户侧传递数据的 C 结构体定义的 [`bpftool`](https://github.com/wasm-bpf/bpftool/tree/wasm-bpftool)。
  - 更多编程语言支持(比如 `Rust`、 `Go` 等)还在开发中。

## 编译流程

依赖只有 git submodule 里面的 libbpf 和 wasm-micro-runtime

```sh
git submodule update --init --recursive
```

构建示例需要用到 `clang`, `libelf` 和 `zlib` 。包名在不同的发行版间可能不同。

在 Ubuntu/Debian，需要安装如下安装包：

```shell
apt install clang libelf1 libelf-dev zlib1g-dev
```

在 CentOS/Fedora，需要安装如下安装包：

```shell
dnf install clang elfutils-libelf elfutils-libelf-devel zlib-devel
```

运行 `make` 来构建这些示例。 构建结果会被放在 `build` 文件夹里（构建运行时需要用到 `cmake`）。

```sh
make build
```

可以查阅 [CI](.github/workflows/c-cpp.yml) 来详细了解如何编译运行这些示例。

## wasm程序中对bpf程序的配置方式

首先，使用clang和llvm-strip构建BPF程序，以剥离调试信息：

```
clang -g -O2 -target bpf -D__TARGET_ARCH_x86 -I../../third_party/vmlinux/x86/ -idirafter /usr/lib/llvm-15/lib/clang/15.0.2/include -idirafter /usr/local/include -idirafter /usr/include/x86_64-linux-gnu -idirafter /usr/include -c bootstrap.bpf.c -o bootstrap.bpf.o
```

BPF程序的内核部分与libbpf完全相同（或者可以使用clang编译的任何其他风格）。一旦完成了 [bcc to libbpf converter](https://github.com/iovisor/bcc/issues/4404)，就可以以这种方式编译BCC风格。

随后，从BPF程序生成C头文件：

```
../../third_party/bpftool/src/bpftool gen skeleton -j bootstrap.bpf.o > bootstrap.skel.h
```

C skel包含一个 BPF 程序的skeleton，用于操作 BPF 对象，并控制 BPF 程序的生命周期，例如：

```
struct bootstrap_bpf {
    struct bpf_object_skeleton *skeleton;
    struct bpf_object *obj;
    struct {
        struct bpf_map *exec_start;
        struct bpf_map *rb;
        struct bpf_map *rodata;
    } maps;
    struct {
        struct bpf_program *handle_exec;
        struct bpf_program *handle_exit;
    } progs;
    struct bootstrap_bpf__rodata {
        unsigned long long min_duration_ns;
    } *rodata;
    struct bootstrap_bpf__bss {
        uint64_t /* pointer */ name_ptr;
    } *bss;
};
```

因为主机（或 eBPF 侧）的结构体布局可能与目标（Wasm 侧）的结构体布局不同，所以所有指针都将根据主机的指针大小转换为整数。例如，`name_ptr` 是指向 `struct exec_start_`t 结构体中的 `name` 字段的指针。此外，填充字节将明确添加到结构体中以确保结构体布局与目标端相同，例如使用 `char __pad0[4];`。这是我们为 Wasm 修改的 `bpftool` 工具生成的。

最后，构建用户态的wasm代码

```sh
/opt/wasi-sdk/bin/clang -O2 --sysroot=/opt/wasi-sdk/share/wasi-sysroot -Wl,--allow-undefined -o bootstrap.wasm bootstrap.c
```

需要wasi-sdk才能构建wasm二进制文件。您也可以使用emcc工具链来构建wasm二进制文件，命令应该是相似的。

您可以运行以下命令来安装 wasi-sdk：

```
wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-17/wasi-sdk-17.0-linux.tar.gz
tar -zxf wasi-sdk-17.0-linux.tar.gz
sudo mkdir -p /opt/wasi-sdk/ && sudo mv wasi-sdk-17.0/* /opt/wasi-sdk/
```

## wasm-bpf的展望

eunomia-bpf 的团队在 2023 年也希望尝试探索、改进、完善 eBPF 程序开发、编译、打包、发布、安装、升级等的流程和工具、SDK，并积极向上游社区反馈，进一步增强 eBPF 的编程体验和语言能力；以及更进一步地和 WebAssembly 相结合，在可观测性、serverless、可编程内核等诸多方面做更多的探索和实践，朝着图灵完备和更完善的语言支持迈进。
