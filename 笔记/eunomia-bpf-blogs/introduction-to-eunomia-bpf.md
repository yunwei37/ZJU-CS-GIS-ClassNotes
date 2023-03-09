# 社区简介

eunomia-bpf 是一个 eBPF 和 Wasm 程序的开发框架，帮助你使用 CO-RE、 WebAssembly 和 GPT 更容易地构建、分发和部署 eBPF 程序。使用 eunomia-bpf ，可以：

- 在编写 eBPF 程序或工具时只编写内核态代码，自动获取内核态导出信息，自动构建简单的 eBPF 程序；
- 使用 Wasm 进行用户态交互程序的开发，在 Wasm 虚拟机内部控制整个 eBPF 程序的加载和执行，以及处理相关数据；
- eunomia-bpf 可以将预编译的 eBPF 程序打包为通用的 JSON 或 Wasm 模块，在集群中或边缘端场景跨架构和内核版本进行分发，并且可以作为插件在大型可观测性平台中动态加载，无需重新编译即可动态加载运行；只需一行代码，即可从云端获取 eBPF 程序并加载运行。

eunomia-bpf 社区关注于简化 eBPF 程序的编写、分发和动态加载流程，以及探索 eBPF 和 Wasm 相结合的工具链、运行时等技术。
社区在阿里龙蜥社区 eBPF 技术探索 SIG 中发起和孵化，并由中科院软件所程序语言与编译技术实验室（PLCT）赞助和持续维护。社区由西安邮电大学陈莉君教授、华南理工大学赖晓铮副教授，来自阿里、腾讯、Deepflow 等的国内外 eBPF 领域知名专家和多位内核贡献者担任 Maintainer。社区其中包含的一些工具链、运行时等项目也在阿里、三度观测云等企业中初步落地和使用。

eunomia-bpf is a development framework for eBPF and Wasm programs that helps you build, distribute, and deploy eBPF programs more easily using CO-RE, WebAssembly. With eunomia-bpf, you can:

- Simplify building eBPF applications using CO-RE libbpf by writing eBPF kernel code only. Data can be automatically exposed from kernel.
- Build eBPF programs with Wasm in C/C++, Rust, Go, etc. using the Wasm-bpf project, which contains a runtime, libraries, and toolchains.
- simplify `distributing` eBPF programs: allows you to run eBPF programs from the cloud or URL with just one line of bash without recompiling. You can also dynamically load eBPF programs with a JSON config file or Wasm module.

The eunomia-bpf community focuses on simplifying the process of writing, distributing, and dynamically loading eBPF programs, as well as exploring toolchains, runtimes, and other technologies that combine eBPF and Wasm.
