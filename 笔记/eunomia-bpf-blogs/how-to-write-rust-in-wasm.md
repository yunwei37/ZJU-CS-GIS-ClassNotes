# 在 WebAssembly 中使用 Rust 编写 eBPF 程序并发布 OCI 镜像

> 作者：于桐，郑昱笙

eBPF（extended Berkeley Packet Filter）是一种高性能的内核虚拟机，可以运行在内核空间中，以收集系统和网络信息。随着计算机技术的不断发展，eBPF 的功能日益强大，并且已经成为各种效率高效的在线诊断和跟踪系统，以及构建安全的网络、服务网格的重要组成部分。

WebAssembly（Wasm）最初是以浏览器安全沙盒为目的开发的，发展到目前为止，WebAssembly 已经成为一个用于云原生软件组件的高性能、跨平台和多语言软件沙箱环境，Wasm 轻量级容器也非常适合作为下一代无服务器平台运行时，或在边缘计算等资源受限的场景高效执行。

现在，借助 Wasm-bpf 编译工具链和运行时，我们可以使用 Wasm 将 eBPF 程序编写为跨平台的模块，使用 C/C++ 和 Rust 编写程序。通过在 WebAssembly 中使用 eBPF 程序，我们不仅让 Wasm 应用获得 eBPF 的高性能、对系统接口的访问能力，还可以让 eBPF 程序享受到 Wasm 的沙箱、灵活性、跨平台性、和动态加载的能力，并且使用 Wasm 的 OCI 镜像来方便、快捷地分发和管理 eBPF 程序。例如，可以类似 docker 一样，从云端一行命令获取 Wasm 轻量级容器镜像，并运行任意 eBPF 程序。通过结合这两种技术，我们将会给 eBPF 和 Wasm 生态来一个全新的开发体验！

## 使用 Wasm-bpf 工具链在 Wasm 中编写、动态加载、分发运行 eBPF 程序

在前两篇短文中，我们已经介绍了 Wasm-bpf 的设计思路，以及如何使用 C/C++ 在 Wasm 中编写 eBPF 程序:

- Wasm-bpf: 架起 Webassembly 和 eBPF 内核可编程的桥梁: <https://mp.weixin.qq.com/s/2InV7z1wcWic5ifmAXSiew>
- 在 WebAssembly 中使用 C/C++ 和 libbpf 编写 eBPF 程序: <https://zhuanlan.zhihu.com/p/605542090>

基于 Wasm，我们可以使用多种语言构建 eBPF 应用，并以统一、轻量级的方式管理和发布。以我们构建的示例应用 bootstrap.wasm 为例，使用 C/C++ 构建的镜像大小最小仅为 ~90K，很容易通过网络分发，并可以在不到 100ms 的时间内在另一台机器上动态部署、加载和运行，并且保留轻量级容器的隔离特性。运行时不需要内核特定版本头文件、LLVM、clang 等依赖，也不需要做任何消耗资源的重量级的编译工作。对于 Rust 而言，编译产物会稍大一点，大约在 2M 左右。

本文将以 Rust 语言为例，讨论：

- 使用 Rust 编写 eBPF 程序并编译为 Wasm 模块
- 使用 OCI 镜像发布、部署、管理 eBPF 程序，获得类似 Docker 的体验

我们在仓库中提供了几个示例程序，分别对应于可观测、网络、安全等多种场景。

## 编写 eBPF 程序并编译为 Wasm 的大致流程

一般说来，在非 Wasm 沙箱的用户态空间，使用 libbpf-bootstrap 脚手架，可以快速、轻松地使用 C/C++构建 BPF 应用程序。编译、构建和运行 eBPF 程序（无论是采用什么语言），通常包含以下几个步骤：

- 编写内核态 eBPF 程序的代码，一般使用 C/C++ 或 Rust 语言
- 使用 clang 编译器或者相关工具链编译 eBPF 程序（要实现跨内核版本移植的话，需要包含 BTF 信息）。
- 在用户态的开发程序中，编写对应的加载、控制、挂载、数据处理逻辑；
- 在实际运行的阶段，从用户态将 eBPF 程序加载进入内核，并实际执行。

## 使用 Rust 编写 eBPF 程序并编译为 Wasm

Rust 可能是 WebAssembly 生态系统中支持最好的语言。Rust 不仅支持几个 WebAssembly 编译目标，而且 wasmtime、Spin、Wagi 和其他许多 WebAssembly 工具都是用 Rust 编写的。因此，我们也提供了 Rust 的开发示例：

- Wasm 和 WASI 的 Rust 生态系统非常棒
- 许多 Wasm 工具都是用 Rust 编写的，这意味着有大量的代码可以复用。
- Spin 通常在对其他语言的支持之前就有Rust的功能支持
- Wasmtime 是用 Rust编写的，通常在其他运行时之前就有最先进的功能。
- 可以在 WebAssembly 中使用许多现成的 Rust 库。
- 由于 Cargo 的灵活构建系统，一些 Crates 甚至有特殊的功能标志来启用Wasm的功能（例如Chrono）。
- 由于 Rust 的内存管理技术，与同类语言相比，Rust 的二进制大小很小。

我们同样提供了一个 Rust 的 eBPF SDK，可以使用 Rust 编写 eBPF 的用户态程序并编译为 Wasm。借助 aya-rs 提供的相关工具链支持，内核态的 eBPF 程序也可以用 Rust 进行编写，不过在这里，我们还是复用之前使用 C 语言编写的内核态程序。

首先，我们需要使用 rust 提供的 wasi 工具链，创建一个新的项目：

```sh
rustup target add wasm32-wasi
cargo new rust-helloworld
```

之后，可以使用 `Makefile` 运行 make 完成整个编译流程，并生成 `bootstrap.bpf.o` eBPF 字节码文件。

### 使用 wit-bindgen 生成类型信息，用于内核态和 Wasm 模块之间通信

wit-bindgen 项目是一套着眼于 WebAssembly，并使用组件模型的语言的绑定生成器。绑定是用 *.wit 文件描述的，文件中描述了 Wasm 模块导入、导出的函数和接口。我们可以 wit-bindgen 它来生成多种语言的类型定义，以便在内核态的 eBPF 和用户态的 Wasm 模块之间传递数据。

我们首先需要在 `Cargo.toml` 配置文件中加入 `wasm-bpf-binding` 和 `wit-bindgen-guest-rust` 依赖：

```toml
wasm-bpf-binding = { path = "wasm-bpf-binding" }
```

这个包提供了 wasm-bpf 由运行时提供给 Wasm 模块，用于加载和控制 eBPF 程序的函数的绑定。

- `wasm-bpf-binding` 在 wasm-bpf 仓库中有提供。

```toml
[dependencies]
wit-bindgen-guest-rust = { git = "https://github.com/bytecodealliance/wit-bindgen", version = "0.3.0" }

[patch.crates-io]
wit-component = {git = "https://github.com/bytecodealliance/wasm-tools", version = "0.5.0", rev = "9640d187a73a516c42b532cf2a10ba5403df5946"}
wit-parser = {git = "https://github.com/bytecodealliance/wasm-tools", version = "0.5.0", rev = "9640d187a73a516c42b532cf2a10ba5403df5946"}
```

这个包支持用 wit 文件为 rust 客户程序生成绑定。使用这个包的情况下，我们不需要再手动运行 wit-bindgen。

接下来，我们使用 `btf2wit` 工具，从 BTF 信息生成 wit 文件。可以使用 `cargo install btf2wit` 安装我们提供的 btf2wit 工具，并编译生成 wit 信息：

```console
cd btf
clang -target bpf -g event-def.c -c -o event.def.o
btf2wit event.def.o -o event-def.wit
cp *.wit ../wit/
```

- 其中 `event-def.c` 是包含了我们需要的结构体信息的的 C 程序文件。只有在导出符号中用到的结构体才会被记录在 BTF 中。

对于 C 结构体生成的 wit 信息，大致如下：

```wit
default world host {
    record event {
         pid: s32,
        ppid: s32,
        exit-code: u32,
        --pad0: list<s8>,
        duration-ns: u64,
        comm: list<s8>,
        filename: list<s8>,
        exit-event: s8,
    }
}
```

`wit-bindgen-guest-rust` 会为 wit 文件夹中的所有类型信息，自动生成 rust 的类型，例如：

```rust
#[repr(C, packed)]
#[derive(Debug, Copy, Clone)]
struct Event {
    pid: i32,
    ppid: i32,
    exit_code: u32,
    __pad0: [u8; 4],
    duration_ns: u64,
    comm: [u8; 16],
    filename: [u8; 127],
    exit_event: u8,
}
```

### 编写用户态加载和处理代码

为了在 WASI 上运行，需要为 main.rs 添加 `#![no_main]` 属性，并且 main 函数需要采用类似如下的形态：

```rust
#[export_name = "__main_argc_argv"]
fn main(_env_json: u32, _str_len: i32) -> i32 {

    return 0;
}
```

用户态加载和挂载代码，和 C/C++ 中类似：

```rust
    let obj_ptr =
        binding::wasm_load_bpf_object(bpf_object.as_ptr() as u32, bpf_object.len() as i32);
    if obj_ptr == 0 {
        println!("Failed to load bpf object");
        return 1;
    }
    let attach_result = binding::wasm_attach_bpf_program(
        obj_ptr,
        "handle_exec\0".as_ptr() as u32,
        "\0".as_ptr() as u32,
    );
    ...
```

polling ring buffer：

```rust
    let map_fd = binding::wasm_bpf_map_fd_by_name(obj_ptr, "rb\0".as_ptr() as u32);
    if map_fd < 0 {
        println!("Failed to get map fd: {}", map_fd);
        return 1;
    }
    // binding::wasm
    let buffer = [0u8; 256];
    loop {
        // polling the buffer
        binding::wasm_bpf_buffer_poll(
            obj_ptr,
            map_fd,
            handle_event as i32,
            0,
            buffer.as_ptr() as u32,
            buffer.len() as i32,
            100,
        );
    }
```

使用 handler 接收返回值：

```rust

extern "C" fn handle_event(_ctx: u32, data: u32, _data_sz: u32) {
    let event_slice = unsafe { slice::from_raw_parts(data as *const Event, 1) };
    let event = &event_slice[0];
    let pid = event.pid;
    let ppid = event.ppid;
    let exit_code = event.exit_code;
    if event.exit_event == 1 {
        print!(
            "{:<8} {:<5} {:<16} {:<7} {:<7} [{}]",
            "TIME",
            "EXIT",
            unsafe { CStr::from_ptr(event.comm.as_ptr() as *const i8) }
                .to_str()
                .unwrap(),
            pid,
            ppid,
            exit_code
        );
        ...
}
```

接下来即可使用 cargo 编译运行：

```console
$ cargo build --target wasi32-wasm
$ sudo wasm-bpf ./target/wasm32-wasi/debug/rust-helloworld.wasm
TIME     EXEC  sh               180245  33666   /bin/sh
TIME     EXEC  which            180246  180245  /usr/bin/which
TIME     EXIT  which            180246  180245  [0] (1ms)
TIME     EXIT  sh               180245  33666   [0] (3ms)
TIME     EXEC  sh               180247  33666   /bin/sh
TIME     EXEC  ps               180248  180247  /usr/bin/ps
TIME     EXIT  ps               180248  180247  [0] (23ms)
TIME     EXIT  sh               180247  33666   [0] (25ms)
TIME     EXEC  sh               180249  33666   /bin/sh
TIME     EXEC  cpuUsage.sh      180250  180249  /root/.vscode-server-insiders/bin/a7d49b0f35f50e460835a55d20a00a735d1665a3/out/vs/base/node/cpuUsage.sh
```

## 使用 OCI 镜像发布和管理 eBPF 程序

开放容器协议 (OCI) 是一个轻量级，开放的治理结构，为容器技术定义了规范和标准。在 Linux 基金会的支持下成立，由各大软件企业构成，致力于围绕容器格式和运行时创建开放的行业标准。其中包括了使用 Container Registries 进行工作的 API，正式名称为 OCI 分发规范 (又名“distribution-spec”)。

Docker 也宣布推出与 WebAssembly 集成 (Docker+Wasm) 的首个技术预览版，并表示公司已加入字节码联盟 (Bytecode Alliance)，成为投票成员。Docker+Wasm 让开发者能够更容易地快速构建面向 Wasm 运行时的应用程序。

借助于 Wasm 的相关生态，可以非常方便地发布、下载和管理 eBPF 程序，例如，使用 `wasm-to-oci` 工具，可以将 Wasm 程序打包为 OCI 镜像，获取类似 docker 的体验：

```console
wasm-to-oci push testdata/hello.wasm <oci-registry>.azurecr.io/wasm-to-oci:v1
wasm-to-oci pull <oci-registry>.azurecr.io/wasm-to-oci:v1 --out test.wasm
```

我们也将其集成到了 eunomia-bpf 的 ecli 工具中，可以一行命令从云端的 Github Packages 中下载并运行 eBPF 程序，或通过 Github Packages 发布：

```bash
# push to Github Packages
ecli push https://ghcr.io/eunomia-bpf/sigsnoop:latest
# pull from Github Packages
ecli pull https://ghcr.io/eunomia-bpf/sigsnoop:latest
# run eBPF program
ecli run https://ghcr.io/eunomia-bpf/sigsnoop:latest
```

我们已经在 LMP 项目的 eBPF Hub 中，有一些创建符合 OCI 标准的 Wasm-eBPF 应用程序，并利用 ORAS 简化扩展 eBPF 应用开发，分发、加载、运行能力的尝试[11]，以及基于 Wasm 同时使用多种不同语言开发 eBPF 的用户态数据处理插件的实践。基于最新的 Wasm-bpf 框架，有更多的探索性工作可以继续展开，我们希望尝试构建一个完整的针对 eBPF 和 Wasm 程序的包管理系统，以及更多的可以探索的应用场景。

## 总结

本文以 Rust 语言为例，讨论了使用 Rust 编写 eBPF 程序并编译为 Wasm 模块以及使用 OCI 镜像发布、部署、管理 eBPF 程序，获得类似 Docker 的体验。更完整的代码，请参考我们的 Github 仓库：<https://github.com/eunomia-bpf/wasm-bpf>.

接下来，我们会继续完善在 Wasm 中使用多种语言开发和运行 eBPF 程序的体验，提供更完善的示例和用户态开发库/工具链，以及更具体的应用场景。

## 参考资料

- wasm-bpf Github 开源地址：<https://github.com/eunomia-bpf/wasm-bpf>
- 什么是 eBPF：<https://ebpf.io/what-is-ebpf>
- WASI-eBPF: <https://github.com/WebAssembly/WASI/issues/513>
- 龙蜥社区 eBPF 技术探索 SIG <https://openanolis.cn/sig/ebpfresearch>
- eunomia-bpf 项目：<https://github.com/eunomia-bpf/eunomia-bpf>
- eunomia-bpf 项目龙蜥 Gitee 镜像：<https://gitee.com/anolis/eunomia>
- Wasm-bpf: 架起 Webassembly 和 eBPF 内核可编程的桥梁：<https://mp.weixin.qq.com/s/2InV7z1wcWic5ifmAXSiew>
- 当 Wasm 遇见 eBPF ：使用 WebAssembly 编写、分发、加载运行 eBPF 程序：<https://zhuanlan.zhihu.com/p/573941739>
- Docker+Wasm技术预览：<https://zhuanlan.zhihu.com/p/583614628>
- LMP eBPF-Hub: <https://github.com/linuxkerneltravel/lmp>
- wasm-to-oci: <https://github.com/engineerd/wasm-to-oci>
- btf2wit: <https://github.com/eunomia-bpf/btf2wit>
