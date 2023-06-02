# GLCC

项目名称：整理和发布 Learn eBPF by examples 教程文档

难度：中

<https://github.com/eunomia-bpf/bpf-developer-tutorial> 是一个基于 CO-RE（一次编译，到处运行）的 eBPF 的开发教程，提供了从入门到进阶的 eBPF 开发实践，包括基本概念、代码实例、实际应用等内容，目前已经有将近 30 个可观测性、网络、安全等等方面的 eBPF 示例，涵盖多种程序类型和应用场景。

这个教程不会进行复杂的概念讲解和场景介绍，主要希望提供一些 eBPF 小工具的案例（非常短小，从二十行代码开始入门！），来帮助 eBPF 应用的开发者快速上手 eBPF 的开发方法和技巧。目前在 Github 上已经有 500+ star，但还有一些章节还未完全完成，以及可能存在一些错漏之处，需要进一步完善。

我们希望能更好的组织对应的文档和代码，并且添加 CI 和测试，同时将其移植到 LMP 的 eBPF Hub 中去，提供一个通用、规范化的 eBPF 程序软件包，可供直接下载使用，并且可视化展示 eBPF 程序的运行结果。

项目要求：

1. 补全 bpf-developer-tutorial 尚未完成的章节，修改部分错误和不合理的地方
2. 为 bpf-developer-tutorial 中的示例应用添加构建和测试的 CI
3. 将其移植到 LMP 的 eBPF Hub 中，作为即插即用的软件包发布，并且获取可视化的运行结果。

项目名称：完善 eBPF Hub 的实现和前端界面

难度：中

在 LMP 的 eBPF Hub 中，我们希望提供一个通用、规范化的 eBPF 程序/应用插件/工具的托管平台或应用商店，以及包管理器，可以在本地一行命令拉下来即可启动，不需要配置管理环境和重新编译，即可通过 exporter 获得可视化信息。目前 eBPF Hub 项目已经有一部分的进展，但还有一些功能需要完善，具体可以参考 <https://github.com/linuxkerneltravel/lmp/tree/develop/eBPF_Hub>

项目要求：

1. 为 eBPF Hub 提供一个较为完善的前端界面，包含首页和项目列表、项目详情页面等，可以供使用者浏览对应的 eBPF 程序/应用插件/工具的信息，选择希望使用的软件包；
2. 使用 Docker 或者 Wasm 模块/JSON 信息打包现有的 eBPF Hub 的内容，存储到 OCI 镜像仓库，可以在本地使用命令行工具一键拉取并使用。需要将现有的 eBPF Supermarket 的内容打包为 Docker 镜像或者 Wasm 模块，存储在 eBPF Hub 中。目前这一部分已经有一些进展，但使用起来还不够便捷，需要进一步改进，可以参考：<https://github.com/linuxkerneltravel/lmp_cli>
