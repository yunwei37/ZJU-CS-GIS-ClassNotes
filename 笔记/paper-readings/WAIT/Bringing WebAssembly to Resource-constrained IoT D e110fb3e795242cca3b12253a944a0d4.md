# 论文阅读：Bringing WebAssembly to Resource-constrained IoT Devices for Seamless Device-Cloud Integration

> 本文来自 eunomia-bpf 社区，我们正在探索 eBPF 和 WebAssembly 相互结合的工具链和运行时: <https://github.com/eunomia-bpf/wasm-bpf> 社区关注于简化 eBPF 程序的编写、分发和动态加载流程，以及探索 eBPF 和 Wasm 相结合的工具链、运行时和运用场景等技术。

将WebAssembly引入资源受限的物联网设备，实现无缝设备-云集成

近年来，物联网（IoT）设备和云服务器之间不断推进集成，这促进了IoT应用的效率和互操作性。因其性能和可移植性而闻名的WebAssembly被认为是连接设备和服务器之间异构性的一种有前途的技术。然而，常见于野外部署的资源受限设备很难有效地运行WebAssembly，因此难以参与设备-云集成。
因此，我们提出了WAIT，一种用于资源受限IoT设备的轻量级WebAssembly运行时，用于设备-云集成应用。**WAIT是第一个通过利用几种方法来减少内存使用量，在资源受限设备上实现WebAssembly的Ahead-of-Time（AOT）编译的工作。**此外，WAIT在编译时引入各种安全检查，以保证WebAssembly的沙箱执行，并优化IoT设备的能源消耗。结果显示，WAIT相比最先进的WebAssembly AOT运行时，RAM使用量降低了84.8倍，同时保证了WebAssembly模块的沙箱执行，将能源消耗降低了1.2倍~4.9倍。

challenges 

本文讨论了将WebAssembly引入资源受限的物联网设备以实现无缝设备云集成所面临的挑战。这些挑战包括在低端设备上支持高效执行、保证沙盒执行和优化能源消耗。

因此，我们提出了WAIT，一种轻量级WebAssembly运行时，适用于资源受限的物联网设备，用于设备-云集成应用程序。使用WAIT，用户可以使用各种高级语言编写设备-云集成应用程序，并将它们编译为WebAssembly模块。然后，通过有线或无线方式传播在物联网设备上执行的应用程序逻辑。收到模块后，WAIT执行设备上的AOT编译，检查沙盒保证，并执行模块。更具体地说，WAIT提出了相应的解决方案来应对三个挑战。

解决方案1：WAIT提倡使用加载代理与云服务器定期通信，并在可用时加载WebAssembly模块。代理内部包含轻量级AOT编译器和一系列内存优化，以在资源受限的设备上正确高效地执行WebAssembly。为了应对有限的资源，WAIT通过流式回溯编译减少编译时的内存占用，并通过后编译内存修剪和常量重映射来优化运行时内存布局，以支持复杂应用程序。

解决方案2:为了在资源受限的设备上提供安全和确定性的集成执行环境，WAIT引入了内存安全和控制流完整性检查。为了在执行期间最小化开销，WAIT将大部分检查移动到AOT编译阶段，并精心选择被检查的指令。

解决方案3:对于开发人员，WAIT提供了与物联网相关的API，用于外设访问和占空比控制，以便于完整的物联网编程。此外，WAIT采用批量指令编写和I/O直接访问方法，以减少编译和运行时的能量消耗。

我们实现了WAIT并广泛评估了其性能。结果表明:(1)最先进的WebAssembly解释器[50]和AOT运行时[9]分别比WAIT多消耗13.6×和84.8×RAM。(2)WAIT的能量优化方法实现了1.2×~4.9×的功率降低。(3)WAIT仅产生19.1%的平均运行时开销，以确保WebAssembly的沙箱执行。WAIT在[https://github.com/liborui/WAIT](https://github.com/liborui/WAIT)上是开源的。

3.1 Design goals

在设计WAIT系统时，我们考虑了物联网设备（内存和能源有限）和设备-云集成带来的安全问题。因此，WAIT的设计和实现必须满足以下目标：
• 内存效率。WAIT的首要目标是执行WebAssembly。与Linux兼容设备上的GB级RAM相比，物联网设备上的内存缩小到KB级别，这使得大多数现有的执行WebAssembly的方法不可用。因此，WAIT必须在编译时和运行时最小化内存占用。
• 执行安全。执行安全对于设备-云集成计算方案至关重要。这是因为集成带来了更广泛的攻击面，除了由于在网络上传输代码而带来的性能提升。
• 能源效率。物联网设备通常由电池供电，特别是那些在野外部署的设备。微小的能耗增加可能导致数天的寿命差异。因此，我们认识到能源效率是设计目标之一。

![Untitled](Bringing%20WebAssembly%20to%20Resource-constrained%20IoT%20D%20e110fb3e795242cca3b12253a944a0d4/Untitled.png)

4.2 Two-phase sandbox checks

WAIT在编译阶段和执行阶段都进行沙箱检查。
WAIT沙箱检查的高层目标是在执行WebAssembly模块期间保证控制流完整性(CFI)和内存安全性。具体来说，WAIT通过将执行限制为遵循WebAssembly定义的编译汇编代码或由WAIT提供的代码来保护CFI，并通过禁止对线性存储器和堆栈的非法读写来确保内存安全性。我们在表2中列出了WAIT执行的完整检查列表，按照检查约束的阶段进行分类。

6.1 Methodology

本文讨论了一项实验，旨在将WebAssembly带到资源受限的物联网设备中，以实现无缝的设备-云集成。使用来自现实世界物联网应用程序的六个综合基准来评估该系统的性能，该系统称为WAIT。这些基准包括二分查找、快速傅里叶变换、无损数据压缩以及使用热传感器进行对象跟踪等应用程序。这些基准是使用wasi-sdk-12.0在优化级别-Os下编译的。本文还将WAIT与现有的工作（如WAMR和Wasm3）以及两种基于软件的安全保护方法（t-kernel和Harbor）进行了比较。

7.1 Usage scenarios of WAIT

本文介绍了WAIT系统，它使用WebAssembly来促进物联网应用程序的无缝设备-云集成。 WAIT对于涉及具有不同指令集架构的设备以及由具有不同语言背景的程序员开发的应用程序特别有用。 通过将函数部署为WebAssembly模块，WAIT可以在各种设备上支持函数即服务计算，包括资源受限的物联网设备。

7.2 Design alternatives of WAIT
We now discuss the alternatives we considered during the design
and implementation of WAIT, and why we adopted the current
design.

LLVM还是从头开始构建？现有的WebAssembly AOT运行时[9, 51]通常使用LLVM [38]将WebAssembly翻译为本地汇编。由于LLVM的模块化和可重用性，这些运行时可以相对轻松地移植到不同的硬件平台。然而，LLVM的使用会导致显著的资源占用，特别是在执行之前的AOT阶段，如第6.2节所示。因此，WAIT选择从头开始构建一个资源友好的WebAssembly AOT运行时。如果计算资源丰富，则LLVM是一个很好的选择，而WAIT则是IoT设备的更好选择，因为它们通常受到资源的限制。正如我们在第5节中所描述的那样，我们在整个设计过程中考虑了WAIT的可移植性。我们还考虑了将WAIT自动移植到新平台的方法作为我们未来的工作（例如，类似于[23]），以消除人为干预并增加WAIT的可移植性。

作者比较了设备上的AOT（提前编译）和云端的AOT编译，并认为前者提供了更大的可移植性，并且对于某些类型的应用程序是必要的，例如需要点对点计算迁移或具有双向安全要求的应用程序。

7.3 Tradeoff of the lightweight design of WAIT

正如我们在第4节中所描述的，WAIT采用了几种轻量级方法来运行在资源受限的设备上。由于这种轻量级设计，一些高端的WebAssembly功能在WAIT中并没有包含。
我们通过它们与核心WebAssembly规范的距离来将不支持的功能进行分类。(1)最小可行产品(MVP)功能。MVP功能是WebAssembly的初始发布版本，包括二进制格式、线性内存等。WAIT实现了WebAssembly的所有MVP功能并为开发人员添加了物联网相关的API。(2)MVP后续功能。在MVP的基础上，WebAssembly继续进化并添加新的功能。在MVP后续功能中，WAIT目前不支持线程、128位SIMD（单指令多数据）和64位寻址。我们认为这些高端功能在物联网应用中几乎没有使用，甚至不受物联网设备支持。(3)未包含在规范中或仍处于提案阶段的额外功能。这些功能尚未标准化，可能会在未来有所变化，例如支持GPU加速器。因此，我们在WAIT中也省略了这些高端功能以实现轻量级。

summary

本文介绍了一种名为WAIT的轻量级WebAssembly运行时，旨在将WebAssembly引入资源受限的物联网设备以实现无缝设备-云集成。WAIT解决了在低端设备上支持高效执行、保证沙盒执行和优化能源消耗等挑战，并通过实验表明，相比最先进的WebAssembly AOT运行时，WAIT的RAM使用量降低了84.8倍，能源消耗降低了1.2倍~4.9倍。WAIT对于涉及具有不同指令集架构的设备以及由具有不同语言背景的程序员开发的应用程序特别有用。