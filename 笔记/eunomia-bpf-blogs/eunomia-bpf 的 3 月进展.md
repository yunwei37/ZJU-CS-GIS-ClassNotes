# eunomia-bpf 的 3 月进展

eunomia-bpf 项目是一个开源项目，旨在提供一组工具，用于在 Linux 内核中更方便地编写和运行 eBPF 程序。在过去一个月中，该项目取得了一些新的进展，以下是这些进展的概述。

首先，eunomia-bpf 动态加载库进行了一些重要的更新。该库现在支持 btf hub，这使得在低内核版本上移植 eBPF 程序更加容易。ecli 程序也进行了完全的重写，现在是使用 Rust 编写的，已经取代了原本使用 C++ 编写的版本。此外，该库还修复了使用 JSON 动态加载 eBPF 程序的输出问题，并在 CI 中自动发布 Docker 镜像。

其次，Wasm-bpf 项目也进行了一些更新。该项目添加了一系列的 examples，这些 examples 关注于安全、网络、追踪等多个方向。Wasm-bpf 项目还添加了 Rust 语言的 Guest SDK 支持，并尝试添加了 Go 语言的 Guest SDK 支持。Rust 和 wasmtime 的运行时实现也已经加入了该项目，并为 WasmEdge 添加了运行时插件。此外，该项目进行了一系列的修复和文档重构，并完善了 CI 和测试等内容。该项目还尝试使用 Wasm 组件模型，并添加了一个工具，用于添加在 wasm 模块中定义的表导出。最后，该项目还产生了三篇博客和演示视频等相关内容。

最后，eunomia-bpf 还新增了一个名为 GPTtrace 的 demo 项目。该项目使用 ChatGPT 自动化生成 eBPF 程序和追踪，有助于用户更轻松地创建和追踪自定义的系统事件。该项目还更新了教程文档，使其更易于使用。

总体来看，eunomia-bpf 项目在 3 月份取得了一些重要的进展。这些更新和改进有助于使该项目更加易于使用和灵活，扩展了其功能和适用范围。如果你对该项目感兴趣，可以关注它的最新动态和更新。

以下是更详细的更新列表：

- eunomia-bpf 动态加载库
    - 添加对 btf hub 的支持，允许更好地在低内核版本上移植 eBPF 程序 [link](https://github.com/eunomia-bpf/eunomia-bpf/pull/150)
    - 使用 Rust 编写的 ecli 完全替换了原先使用 C++ 编写的版本 [link](https://github.com/eunomia-bpf/eunomia-bpf/pull/139)
    - 修复了使用 JSON 动态加载 eBPF 程序的输出问题 [link](https://github.com/eunomia-bpf/eunomia-bpf/pull/149) [link](https://github.com/eunomia-bpf/eunomia-bpf/pull/136)
    - 在 CI 中自动发布 Docker 镜像 [link](https://github.com/eunomia-bpf/eunomia-bpf/pull/129) [link](https://github.com/eunomia-bpf/eunomia-bpf/pull/135)
    - 尝试在其他平台上添加支持，以及在 RISC-V 上进行更多的测试 [link](https://github.com/eunomia-bpf/eunomia-bpf/discussions/147)
- Wasm-bpf
    - 添加了一系列 examples，关注于安全、网络、追踪等多个方向 [link](https://github.com/eunomia-bpf/wasm-bpf/pull/11) [link](https://github.com/eunomia-bpf/wasm-bpf/pull/4) [link](https://github.com/eunomia-bpf/wasm-bpf/pull/26)
    - 添加了 Rust 语言的 Guest SDK 支持 [link](https://github.com/eunomia-bpf/wasm-bpf/pull/9)
    - 尝试添加了 Go 语言的 Guest SDK 支持 [link](https://github.com/eunomia-bpf/wasm-bpf/pull/37)
    - 添加了 Rust 和 wasmtime 的运行时实现 [link](https://github.com/eunomia-bpf/wasm-bpf/pull/33)
    - 为 WasmEdge 添加了运行时插件 [link](https://github.com/WasmEdge/WasmEdge/pull/2314)
    - 一系列小修复和文档重构 [link](https://github.com/eunomia-bpf/wasm-bpf/pull/51) [link](https://github.com/eunomia-bpf/wasm-bpf/pull/39) [link](https://github.com/eunomia-bpf/wasm-bpf/pull/40) [link](https://github.com/eunomia-bpf/wasm-bpf/pull/51) [link](https://github.com/eunomia-bpf/wasm-bpf/pull/17)
    - CI 和测试等的完善 [link](https://github.com/eunomia-bpf/wasm-bpf/pull/44) [link](https://github.com/eunomia-bpf/wasm-bpf/pull/33)
    - Wasm component model 的尝试 [link](https://github.com/eunomia-bpf/c-rust-component-test)
    - A tool to add an export of the table defined in the wasm module [link](https://github.com/eunomia-bpf/add-table-export)
    - 三篇 blog 和演示视频等产出
- 新 demo 项目: GPTtrace: Generate eBPF programs and tracing with ChatGPT and natural language [link](https://github.com/eunomia-bpf/GPTtrace)
    - 教程文档的完善：[link](https://github.com/eunomia-bpf/bpf-developer-tutorial)
