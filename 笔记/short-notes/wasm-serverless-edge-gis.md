# wasm-serverless-edge-gis

## table of contents

<!-- TOC -->

- [wasm-serverless-edge-gis](#wasm-serverless-edge-gis)
  - [table of contents](#table-of-contents)
  - [background](#background)
    - [Introduce to wasm](#introduce-to-wasm)
    - [Introduce to serverless](#introduce-to-serverless)
    - [边缘计算](#边缘计算)
    - [wasm + serverless + edge？](#wasm--serverless--edge)
  - [serverless + gis: 现有进展](#serverless--gis-现有进展)
  - [wasm + gis: 现有进展](#wasm--gis-现有进展)
  - [边缘计算 + GIS？](#边缘计算--gis)
  - [毕设?](#毕设)

<!-- /TOC -->

## background

### Introduce to wasm

WebAssembly(缩写 Wasm)是基于堆栈虚拟机的二进制指令格式。Wasm 是为了一个可移植的目标而设计的，可作为 C/C+/RUST 等高级语言的编译目标，使客户端和服务器应用程序能够在 Web 上部署。WASM 的运行时有多种实现，包括浏览器和独立的系统，它可以用于视频和音频编解码器、图形和 3D、多媒体和游戏、密码计算或便携式语言实现等应用。

尽管 WASM 是为了提高网页中性能敏感模块表现而提出的字节码标准, 但是 WASM 却不仅能用在浏览器(broswer)中, 也可以用在其他环境中。WASM 已经发展成为一个轻量级、高性能、跨平台和多语种的软件沙盒环境，被运用于云原生软件组件。与 Linux 容器相比，WebAssembly 的启动速度可以提高 100 倍，内存和磁盘占用空间要小得多，并且具有更好定义的安全沙箱。然而，权衡是 WebAssembly 需要自己的语言 SDK 和编译器工具链，使其成为比 Linux 容器更受限制的开发环境。WebAssembly 越来越多地用于难以部署 Linux 容器或应用程序性能至关重要的边缘计算场景。

WASM 的编译和部署流程如下：

![wasm-compile-deploy](../img/wasm-compile.png)

通常可以将 C/C+/RUST 等高级语言编译为 WASM 字节码，在 WASM 虚拟机中进行加载运行。WASM 虚拟机会通过解释执行或 JIT 的方式，将 WASM 字节码翻译为对应平台（ x86/arm 等）的机器码运行。

主要往三个方面:

- 让 C/C+ 等现有的工具和算法可以在浏览器中运行，比如 QGIS 之类的大型 GIS 桌面应用，可以达到和 native 差不多的效果；
- 轻量级容器：serverless，性能比现有的基于容器的 serverless 可能好很多；
- 边缘计算，云边协同

关于毕设, 有没有可能找一个把这几个部分都结合起来的 GIS 应用场景?  serverless + edge + wasm + browser? 我调研了一下, 感觉 CS 这块有一些最新的 serverless + edge + wasm 的尝试(我自己最近也在做这些事情, 不过和 GIS 没关系), 但 GIS 好像还不是很多?

### Introduce to serverless

2019年，UC伯克利大学的学者们从研究角度分析并预测，Serverless计算将取代 Serverful传统的模式，成为云计算的新一代范式。

　研究者们之所以这么说，是因为IT计算模式的变化，其实就是从Serverful计算到Serverless计算的演化。从最早的物理服务器开始，我们都在不断地抽象或者虚拟化服务器。我们使用虚拟化技术、云计算IaaS来自动管理这些虚拟化的资源。随着容器技术出现，我们用容器化CaaS实现了更轻量、更易用的虚拟化和自动化。但这些都还是从管理物理服务器到管理虚拟服务器，我们在使用时仍然需要关心背后的服务器资源分配，在程序没有使用时也需要为这些资源付费。

而现在的Serverless计算理念与技术，我们又实现了一次新的飞跃：它使得我们无需管理服务器，只需专注于业务逻辑，就可以更快构建和部署应用程序。

以一个传统Serverful应用为例：它包括业务数据等四层，为了部署这个应用，首先我们需要有一个服务器包括CPU、内存等作为计算资源，基于之上是操作系统、数据库、中间件等软件，再部署相应的业务数据等模块。如果要进行横向扩容，就需要将上述关注面复制一遍。基于容器技术，上述部署工作可以自动化，但概念模型上仍然是服务器计算资源作为基础。

而在Serverless技术支撑的应用架构中，系统四层能力都可以单独部署到可直接使用的云服务中。业务数据可以放到数据库服务中，业务逻辑执行部署到函数计算服务中。我们的服务接口可以部署到 API网关服务上，来响应动态内容的请求。静态的WebApp包部署在对象存储服务上，Web浏览器首先从对象存储中获取到应用页面本身，再发起动态请求给API网关。在这个过程中，我们使用了一系列稳定存在的云服务，并且只在使用时才计费。我们实际上只需要关注在我们的业务函数上，以及如何使用这些服务完成整个开发流程。

因此，Serverless并不意味着幕后真的没有服务器，只是服务器资源由第三方以各种专门服务的形式提供和管理，它们的资源伸缩、故障恢复等工作都由第三方也即这些BaaS/FaaS云服务提供商来负责。因此对我们应用开发者来说只需要使用这些服务即可，不再需要关心幕后的服务器。

我们可以给Serverless无服务器计算一个定义：Serverless无服务器计算是一种新的云计算模型，允许开发人员在构建和运行应用程序时，无需关心或管理服务器等基础设施。

为什么可以做到这一点？是因为云计算服务商提供了两类服务来代替服务器的作用：FaaS和BaaS。其中最关键的是FaaS，函数即服务，它是一种新的算力组织和提供方式，应用的业务逻辑被拆解为一个或多个细粒度函数，这些函数按需执行、伸缩和计费。另一类服务是BaaS，后端即服务，指的是函数执行所需要的通用的后端服务，由FaaS中的函数来按需调用。

Serverless架构对开发者意味着什么？当前，我们处于互联网分布式计算时代，默认Web BS系统，除了写出算法、读写数据，还需要考虑如何分布式部署、如何应对系统高峰时期的大并发请求；我们以AI人工智能为例，它有三个基石：算法、算力、数据。在Serverful架构中，算力由IaaS提供，算法和数据都要自行部署上去并调度管理来应对峰谷流量变化。

而在Serverless架构中，算法所需要的算力由FaaS提供，算法可以解耦成多个更细粒度的函数，开发者只需要简简单单的构思算法，即功能函数即可。数据也解耦，可以按需存储，数据的存储管理由BaaS提供。

Serverless计算尤其是FaaS函数计算，简化了计算资源的供给，极大提升了面向软件开发者的生产力，可以看作是云计算编程模型从汇编语言时代进化到高级语言时代。

基于上述分析，将Serverless无服务器计算的特征进行归纳：资源的解耦和服务化、自动弹性伸缩、按使用量计费等；相应带来的优势有低运维、低成本、高弹性、高可用等。

- https://zhuanlan.zhihu.com/p/425433134

### 边缘计算

无服务计算，也被称为函数即服务(FAAS)， 在过去两年一直是增长最快的云服务类型，仅在2019年就增长了50%。这是由于无服务计算提供了一种新的事件驱动的模型，用户可以在不关心服务配置和资源的前提下跑一些小的，无状态的应用。自动亚马逊在2014年推出了lambda，大量云服务商推出了类似的无服务平台，包括Google Cloud Functions、Microsoft Azure Functions、IBM Cloud Functions和Alibaba Cloud Functions 。虽然它们的实现各有不同，但是大多都是用虚拟机(vms)或容器作为一个沙箱环境来托管租户，并执行他们的函数。这些框架相对较重，在小内存，低延迟的场景下表现不好，尤其是这些函数第一次实例化的时候。最近的趋势和相关的技术挑战，激发了我们对边缘资源高效型无服务器计算的兴趣。其中包括以下几个：

- 物联网的快速发展 物联网引入了大量低成本的设备，通过物理网压倒性的网络，这些设备通过不断的感知数据，产生的庞大的数据量。充分利用物联网的潜力，需要重新梳理计算模型。
- 依赖实时服务的新型应用程序 工业物联网和下一代技术的兴起，导致计算模型需要支持极低（10ms）的延迟处理，例如：
- 在智慧城市中，交通灯和路灯相互通信，如果有意外发生，可以第一时间感知并响应到。
- 实时监控和智能视频处理功能的系统，适用于多种情况（在紧急情况下的延迟）
- 联网汽车并提供相关的数据服务，及时提醒司机路况危险。
  
这些新兴应用程序会实时的处理大量的数据。他们需要的数据处理系统具有下面的特性：低延迟开销和高系统吞吐量，多租户隔离。

在边缘侧处理数据的重要性 虽然在人的认知里面，云计算是一种很好的解决方案，但是在需要无人参与的情况下能做出快速、自动化决策的场景下，依赖低延迟，它就变得没有那么好用了。例如工业控制系统中，数据分析和控制逻辑可能需要10ms以内的响应时间，上传到云端的话恐怕是不好保证这个延迟的。许多机器学习的工作负载需要在边缘场景下进行(收集传感器的数据)。但是资源和电量的限制仍然是一个挑战。为了满足以上场景的业务需求，我们必须使用新的服务来增强计算的能力，用来处理更加边缘的计算。这也就是边缘计算。

### wasm + serverless + edge？

- Sledge: a Serverless-first, Light-weight Wasm Runtime for the Edge

    <https://www2.seas.gwu.edu/~gparmer/publications/middleware20sledge.pdf>

    现在已经拥有了很多无服务器（serverless）的商业、开源平台，但是这些利用虚拟机和容器的解决方案对于资源有限的边缘系统来说过于重了，调度容器（冷启动）、启动一个虚拟机，往往需要大量的内存占用和很高的调用时间。另外，无服务的工作负载，主要的关注在每个客户端的请求，短期运行的计算并不适合常规的计算系统。

    在本文中，我们设计和实现了一种新颖高效的基于WebAssembly的edge框架---sledge。Sledge的经过一些优化以面对独特属性的工作负载：多租户的，启动快的，突发的客户端请求以及短期的计算。

    在本文章中，我们展示Sledge的设计和实现--一种新颖的、基于WebAssembly的、高效的边缘serverless框架。Sledge主要优化并且支持了一些独特场景的工作负载：高密度的租户，短启动时间，突发的客户端请求和短期计算。Sledge通过优化调度来解决短期计算和有效的任务分配，轻量级的函数隔离模型来实现基于WebAssembly的故障隔离。这些轻量的沙箱目标是在高密度计算：为了高密度的客户端请求，快速吊起和释放函数。和其它真实世界serverless运行时对比，在工作负载多变的条件下，设计一个边缘优先的serverless框架是有效的。与 Nuclio 相比，Sledge 支持4倍的吞吐量，延迟降低了4倍，是其中最快的serverless框架之一。

- Evaluating webassembly enabled serverless approach for edge computing：

    Evaluating webassembly enabled serverless approach for edge computing

    Abstract:

    The edge computing ecosystem has been evolving in the last few years. There have been different architectural patterns proposed to implement edge computing solutions. This paper focuses on serverless edge computing architecture and evaluates webassembly based approach for the same. The current state of serverless edge computing is explained followed by providing high level conceptual overview of webassembly. Webassembly performance is evaluated against native and container based applications using the current toolchain supported for ARM architecture. Benchmarking is done for different categories of applications like compute intensive, memory intensive, file I/O intensive and a simple image classification - machine learning application. This paper describes the experimental setup, discusses the performance results and provides the conclusion.

    Published in: 2020 IEEE Cloud Summit

- WearMask: Fast In-browser Face Mask Detection with Serverless Edge Computing for COVID-19

    <https://arxiv.org/abs/2101.00784>

    COVID-19的流行一直是美国的一个重大医疗挑战。根据美国疾病控制和预防中心（CDC）的资料，COVID-19感染主要是通过人们呼吸、说话、咳嗽或打喷嚏时产生的呼吸道飞沫传播。戴口罩是阻挡80%的呼吸道感染的主要、有效和方便的方法。因此，许多口罩检测和监测系统已经被开发出来，为医院、机场、出版物运输、运动场所和零售场所提供有效的监督。然而，目前的商业口罩检测系统通常与特定的软件或硬件捆绑，阻碍了公众的使用。在本文中，我们提出了一个基于浏览器的无服务器边缘计算的人脸面具检测解决方案，称为基于网络的高效人工智能面具识别（WearMask），它可以部署在任何有互联网连接的普通设备（如手机、平板电脑、电脑）上，使用网络浏览器，而无需安装任何软件。无服务器的边缘计算设计最大限度地减少了额外的硬件成本（例如，特定的设备或云计算服务器）。所提出的方法的贡献在于提供了一个整体的边缘计算框架，它整合了（1）深度学习模型（YOLO），（2）高性能神经网络推理计算框架（NCNN），和（3）基于堆栈的虚拟机（WebAssembly）。对于终端用户来说，我们基于网络的解决方案具有以下优势：（1）无服务器边缘计算设计，设备限制和隐私风险最小；（2）免安装部署；（3）计算要求低；（4）检测速度高。我们的WearMask应用程序已经在这个http URL上推出，供公众访问。

## serverless + gis: 现有进展

- 胡中南：云原生GIS 2.0新技术解读之Serverless + GIS：<http://stock.10jqka.com.cn/20220908/c641712842.shtml>
- SuperMap GIS 11i(2022) 新特性速览：<https://www.supermap.com/zh-cn/a/product/11i-characteristic-2022.html>
- SuperMap GIS 11i(2022)正式发布，揭秘七大特性：<https://baijiahao.baidu.com/s?id=1737120191867774649&wfr=spider&for=pc>
- Geospatial Serverless Computing: Architectures, Tools and Future Directions

    <https://www.researchgate.net/publication/341245906_Geospatial_Serverless_Computing_Architectures_Tools_and_Future_Directions>

    Several real-world applications involve the aggregation of physical features corresponding to different geographic and topographic phenomena. This information plays a crucial role in analyzing and predicting several events. The application areas, which often require a real-time analysis, include traffic flow, forest cover, disease monitoring and so on. Thus, most of the existing systems portray some limitations at various levels of processing and implementation. Some of the most commonly observed factors involve lack of reliability, scalability and exceeding computational costs. In this paper, we address different well-known scalable serverless frameworks i.e., Amazon Web Services (AWS) Lambda, Google Cloud Functions and Microsoft Azure Functions for the management of geospatial big data. We discuss some of the existing approaches that are popularly used in analyzing geospatial big data and indicate their limitations. We report the applicability of our proposed framework in context of Cloud Geographic Information System (GIS) platform. An account of some state-of-the-art technologies and tools relevant to our problem domain are discussed. We also visualize performance of the proposed framework in terms of reliability, scalability, speed and security parameters. Furthermore, we present the map overlay analysis,point-cluster analysis, the generated heatmap and clustering analysis. Some relevant statistical plots are also visualized. In this paper, we consider two application case-studies. The first case study was explored using the Mineral Resources Data System (MRDS) dataset, which refers to worldwide density of mineral resources in a country-wise fashion. The second case study was performed using the Fairfax Forecast Households dataset, which signifies the parcel-level household prediction for 30 consecutive years. The proposed model integrates a serverless framework to reduce timing constraints and it also improves the performance associated to geospatial data processing for high-dimensional hyperspectral data.

## wasm + gis: 现有进展

- GIS Processing on the Web

    <https://www.diva-portal.org/smash/record.jsf?pid=diva2%3A1674422&dswid=6199>

    Today more and more advanced and demanding applications are finding their way to the web. These are applications like video editing, games, and mathematical calculations. Up until a few years ago, JavaScript was the only language present on the web. That was until Mozilla, Google, Microsoft, and Apple decided to develop WebAssembly. WebAssembly is a low-level language, similar to assembly, but running in the browser. WebAssembly was not created to replace JavaScript, but to be used alongside it and complement JavaScript’s weaknesses. WebAssembly is still a relatively new language (2017) and is in continuous development. This work is presented as a guideline, and to give a general direction of how WebAssembly is performing (in 2022) when operating on GIS data.

    今天，越来越多的先进和高要求的应用程序正在找到它们的方式，在网络上。这些应用包括视频编辑、游戏和数学计算等。直到几年前，JavaScript是网络上唯一存在的语言。直到Mozilla、谷歌、微软和苹果决定开发WebAssembly。WebAssembly是一种低级语言，类似于汇编，但在浏览器中运行。创建WebAssembly不是为了取代JavaScript，而是为了与它一起使用，补充JavaScript的弱点。WebAssembly仍然是一种相对较新的语言（2017年），并且正在不断发展。这项工作是作为一个指南提出的，并给出了WebAssembly在GIS数据上运行时的总体表现方向（2022年）。

- The US COVID Atlas: A dynamic cyberinfrastructure surveillance system for interactive exploration of the pandemic

    Distributed spatial infrastructures leveraging cloud computing technologies can tackle issues of disparate data sources and address the need for data-driven knowledge discovery and more sophisticated spatial analysis central to the COVID-19 pandemic. We implement a new, open source spatial middleware component (libgeoda) and system design to scale development quickly to effectively meet the need for surveilling county-level metrics in a rapidly changing pandemic landscape. We incorporate, wrangle, and analyze multiple data streams from volunteered and crowdsourced environments to leverage multiple data perspectives. We integrate explorative spatial data analysis (ESDA) and statistical hotspot standards to detect infectious disease clusters in real time, building on decades of research in GIScience and spatial statistics. We scale the computational infrastructure to provide equitable access to data and insights across the entire USA, demanding a basic but high-quality standard of ESDA techniques. Finally, we engage a research coalition and incorporate principles of user-centered design to ground the direction and design of Atlas application development.

    From an infrastructure perspective, the Atlas is the first web application (to our knowledge) that integrates WebAssembly technology to manage computationally intensive spatial analysis functions (written in C++) directly in the web browser, opening wide new possibilities of browser-based geoprocessing and GIScience.

    从基础设施的角度来看，Atlas是第一个集成了WebAssembly技术的网络应用程序（据我们所知），可以直接在网络浏览器中管理计算密集型的空间分析功能（用C++编写），为基于浏览器的地理处理和GIS科学提供了广泛的新可能性。

- 新一代三维GIS技术体系: 超图

    <https://www.supermap.com/zh-cn/a/product/11i-tec-3-2022.html>

    发布自主研发的全新 WebGL 三维客户端：

  - 完善 Web 端的三维渲染引擎，支持更强的粒子系统、 更多光影特效、更多后处理特效、更具真实感的物理材质
  - 支持游戏引擎导出的标准 PBR 材质，复制游戏引擎 美化后的三维场景
  - 基于 WebAssembly 技术，支持直接加载 .x、.dae 等 更多三维模型格式的数据
  - 提供 Vue2.0/3.0 开发组件，支持低代码开发

- WebAssembly4G: Where we are, and where we're heading

    <https://talks.osgeo.org/foss4g-2022/talk/ASDL7P/>

    > WebAssembly's adoption is gaining traction and still, its potential is not yet fully utilized, especially for the processing and visualization of geo data in and outside of browsers. In this session I will give a technical introduction to WebAssembly. I will show its current state and adaptation in FOSS4G projects and will talk about the ongoing advancements of the technology and possible future scenarios.
    >
    > This will also be a hands-on session, where after showing how to get up and running, I will share my experience, tips and tricks collected while porting the latest versions of GEOS, PROJ, GDAL, SpatiaLite and osgEarth to the web platform.
    >
    > The composition of existing OSGeo/FOSS C/C++ libraries in a portable and sandboxed form also brings many advantages outside of browsers. The talk will close with some demos about how WebAssembly enables us to build for the web, as well as for any other platform.

    WebAssembly的采用越来越多，但它的潜力仍未得到充分的利用，特别是在浏览器内外的地理数据的处理和可视化方面。在这次会议上，我将对WebAssembly做一个技术介绍。我将展示它的现状和在 FOSS4G 项目中的适应性，并将谈论该技术的持续进步和未来可能的情况。这也将是一个实践会议，在展示了如何启动和运行之后，我将分享我在将GEOS、PROJ、GDAL、SpatiaLite和osgEarth的最新版本移植到网络平台时收集的经验、技巧和窍门。现有的OSGeo/FOSS C/C++库以可移植和沙盒的形式组成，在浏览器之外也带来了许多优势。讲座的最后会有一些演示，介绍WebAssembly如何使我们为网络以及其他平台进行构建。

- Write once, run anywhere: safe and reusable analytic modules for WebAssembly, Javascript, or more!

    <https://talks.osgeo.org/foss4g-2022/talk/XV87XB/>

    > The proliferation of client-side analytics and on-going vulnerabilities with shared code libraries have fueled the need for better safety standards for running executables from potentially unknown sources. WebAssembly (WASM), a compilation target that allows lower-level languages like Rust, C, and Go to run in the browser or server-side at near-native speeds. Much like Docker changed the way we run virtualized workflows, WASM runtimes create safe virtual environments where access to the host system is limited.
    > In combination with a new free and open source full-stack geospatial platform, Matico, efforts are underway to enable portability across workflows and applications to more easily use WASM modules. WASM implementations of GDAL are in the works, and powerful open source Rust geospatial libraries are easily packaged for web usage through Wasm-Pack. Additional geo WASM libraries like jsgeoda provide spatial indices, binning, and autocorrelation functions. Shareable code can be a recipe for security vulnerabilities and attack vectors, potentially exposing personal or critical information, particularly if there is the opportunity to run code server-side. WASM implementation alleviates this by requiring access from the Virtual Machine (VM) to be limited and explicit, and for Javascript developers the lightweight AssemblyScript language is relatively familiar.
    > An upcoming Javascript feature called ShadowRealms may enable even simpler and more familiar implementations to safely run Javascript code shared between module authors. These developments lay the groundwork for a hybrid front- and backend geospatial ecosystem of shareable code snippets and analytic functions, much like have emerged in the UI component Javascript ecosystem. The combination of emerging features positions web geospatial analytics and This talk explores the implementation and performance of running geospatial analytic modules through a WebAssembly virtual machine and through the upcoming Javascript ShadowRealm specification.

    客户端分析的激增和共享代码库的持续漏洞，促使人们需要更好的安全标准来运行来自潜在未知来源的可执行文件。WebAssembly（WASM）是一个编译目标，允许Rust、C和Go等低级语言以接近原生的速度在浏览器或服务器端运行。就像Docker改变了我们运行虚拟化工作流程的方式一样，WASM运行时创建了安全的虚拟环境，对主机系统的访问受到限制。

    结合新的免费和开源的全栈地理空间平台Matico，正在努力实现跨工作流程和应用程序的可移植性，以更容易地使用WASM模块。GDAL的WASM实现正在进行中，强大的开源Rust地理空间库可以通过Wasm-Pack轻松打包供网络使用。额外的地理WASM库，如jsgeoda，提供空间指数、分档和自相关功能。可共享的代码可能是安全漏洞和攻击载体的秘诀，有可能暴露个人或关键信息，特别是如果有机会在服务器端运行代码。WASM的实施通过要求来自虚拟机（VM）的访问是有限的和明确的，而对于Javascript开发者来说，轻量级的AssemblyScript语言是相对熟悉的，从而缓解了这种情况。

    一个即将到来的名为ShadowRealms的Javascript功能可能使更简单和更熟悉的实现安全地运行模块作者之间共享的Javascript代码。这些发展为可共享的代码片段和分析功能的前后端地理空间混合生态系统奠定了基础，就像UI组件Javascript生态系统中出现的那样。新兴功能的结合，使网络地理空间分析和本讲座探讨了通过WebAssembly虚拟机和即将推出的Javascript ShadowRealm规范运行地理空间分析模块的实现和性能。

- <https://github.com/stuartlynn/wasm_geo_agg>

    Wasm Geo Agg is a proof of concept to explore performing complex geospatial operations in the browser using Rust and WebAssembly. As an initial test, we are focusing on point in polygon operations. Simply load in a CSV file with points and a GeoJSON file with polygons then click aggregate.

    Currently, if you want to process geospatial data you can either

    1. Spend a day or two installing a bunch of really amazing tools like GDAL, PostGIS, QGIS etc and banging your head a few times as you try to get all their versions compatible with each other ( not to mention trying to not blow up your python installation as you go)
    2. Learn Python or R and use packages like geopandas
    3. Upload your data to services like ArcGis or CARTO to be stored and processed in the cloud somewhere.

    Options 1 or 2 let you process data locally but have a steep learning curve. As someone who has been working in the geospatial world for 4+ years, I still lose half a day each time I need to install a new geospatial stack. While using something like docker makes this a little easier, that too has a bit of a learning curve.

    Option 3 means that you to some extent hand over control of your data to a third party. If the data is sensitive and needs to remain local (as is true for a lot of non-profits or research data), or if you need a service that can be guaranteed to still be around in 5-10 years, these options might not be ideal either. Another consideration is that the cloud servers that process the data on these services are often less powerful than the laptop you are using to read this article, which increasingly seems insane to me.

    So this is an experiment exploring a 4th option. To ask: what if we had a PostGIS that ran entirely in your browser? A system that uses the web to deliver sophisticated software to your computer in the form of javascript and WASM with zero installation overhead, that then processes your data locally using the powerful CPU that happens to live in your machine.

- ArcGIS API for JavaScript and WebAssembly

    <https://developers.arcgis.com/javascript/latest/faq/>

    > Does the ArcGIS API for JavaScript support all Content Security Policy directives?
    >
    > No. Most CSP directives are supported and certified within the ArcGIS for JavaScript API. The API's 3D functionality, in addition to the projection engine, makes use of WebAssembly (wasm). Wasm requires unsafe-eval in the script-src directive. Adding this in CSP goes against the protection that it is supposed to provide. There is a WebAssembly GitHub proposal that discusses this in more detail. Until this is addressed, applications that make use of these two parts of the API will not be able to take advantage of using CSP.

    看起来这里也用了 wasm，不过这个是不是不开源？

- QGIS-Developer QGIS and WebAssembly - OSGeo mailing list

  - <https://lists.osgeo.org/pipermail/qgis-developer/2022-March/064589.html>
  - <https://wonder-sk.github.io/wasm/qgis.html>

    跑在浏览器里面的 QGIS

## 边缘计算 + GIS？

边缘计算GIS技术指的是将边缘计算的各种特征，用于支撑GIS应用的各要素，包括GIS内容的发布和分发，GIS服务的代理和加速，以及在线分析和计算，以一种更加灵活的方式，高效率、低成本地使用地理信息资源。

边缘计算GIS技术是云GIS技术的重要的补充，具体包括以下技术：

- 边缘前置代理：在GIS云中心和客户端之间，对GIS服务进行代理加速，提供更好的服务访问体验。
- 边缘服务聚合：将不同来源，不同内容的GIS服务聚合为一个服务，实现多源、异构地理信息与服务的整合。
- 边缘内容分发：云GIS中心自动将瓦片数据分发到边缘GIS节点，实现了边缘GIS内容的自动更新。
- 边缘分析计算：在边缘端按需进行GIS分析和计算，有效提升GIS服务性能。

- 为什么我们需要边缘计算GIS技术？ <https://baijiahao.baidu.com/s?id=1718990389366964311&wfr=spider&for=pc>
- 边缘计算GIS技术篇——边缘GIS再升级，满足云-边-端架构GIS应用多重需求： <https://magazine.supermap.com/view-1000-15938.aspx>

参考论文: WASM/eBPF + Serverless

- SPRIGHT: Extracting the Server from Serverless Computing! High performance eBPF-based Event-driven, Shared-memory Processing

    <https://dl.acm.org/doi/10.1145/3544216.3544259>

    Serverless computing promises an efficient, low-cost compute capability in cloud environments. However, existing solutions, epitomized by open-source platforms such as Knative, include heavyweight components that undermine this goal of serverless computing. Additionally, such serverless platforms lack dataplane optimizations to achieve efficient, high-performance function chains that facilitate the popular microservices development paradigm. Their use of unnecessarily complex and duplicate capabilities for building function chains severely degrades performance. 'Cold-start' latency is another deterrent.

    We describe SPRIGHT, a lightweight, high-performance, responsive serverless framework. SPRIGHT exploits shared memory processing and dramatically improves the scalability of the dataplane by avoiding unnecessary protocol processing and serialization-deserialization overheads. SPRIGHT extensively leverages event-driven processing with the extended Berkeley Packet Filter (eBPF). We creatively use eBPF's socket message mechanism to support shared memory processing, with overheads being strictly load-proportional. Compared to constantly-running, polling-based DPDK, SPRIGHT achieves the same dataplane performance with 10× less CPU usage under realistic workloads. Additionally, eBPF benefits SPRIGHT, by replacing heavyweight serverless components, allowing us to keep functions 'warm' with negligible penalty.

    Our preliminary experimental results show that SPRIGHT achieves an order of magnitude improvement in throughput and latency compared to Knative, while substantially reducing CPU usage, and obviates the need for 'cold-start'.

    SPRIGHT利用共享内存处理，并且戏剧性的通过避免没必要的协议处理和序列化/反序列化开销，提升了数据面的扩展性。SPRIGHT广泛地使用eBPF进行事件驱动的处理。作者创造性的使用eBPF的socket消息机制来支持共享内存处理，其开销严格的与负载成比例。在真实的负载下，与不间断的运行、基于轮询的DPDK相比，SPRIGHT能够在使用10倍少的CPU使用量的情况下，实现相同的数据面性能。除此之外，eBPF通过代替重量级的无服务组件让SPRIGHT变好，让作者能够在开销可以忽略的情况下，保持函数“暖”（warm）。作者的初步实验结果表明，与Knative相比，SPRIGHT在吞吐和时延上有一个数量级的提升，同时实质上减少了CPU的用量，并且避免了“冷启动”的需求。

    SIGCOMM '22: Proceedings of the ACM SIGCOMM 2022 Conference

- Sledge: A serverless-first, light-weight wasm runtime for the edge
    
    <https://dl.acm.org/doi/abs/10.1145/3423211.3425680>

- Faasm: Lightweight Isolation for Efficient Stateful Serverless Computing

    Serverless computing is an excellent fit for big data processing because it can scale quickly and cheaply to thousands of parallel functions. Existing serverless platforms isolate functions in ephemeral, stateless containers, preventing them from directly sharing memory. This forces users to duplicate and serialise data repeatedly, adding unnecessary performance and resource costs. We believe that a new lightweight isolation approach is needed, which supports sharing memory directly between functions and reduces resource overheads.

    We introduce Faaslets, a new isolation abstraction for high-performance serverless computing. Faaslets isolate the memory of executed functions using \emph{software-fault isolation} (SFI), as provided by WebAssembly, while allowing memory regions to be shared between functions in the same address space. Faaslets can thus avoid expensive data movement when functions are co-located on the same machine. Our runtime for Faaslets, Faasm, isolates other resources, e.g. CPU and network, using standard Linux cgroups, and provides a low-level POSIX host interface for networking, file system access and dynamic loading. To reduce initialisation times, Faasm restores Faaslets from already-initialised snapshots. We compare Faasm to a standard container-based platform and show that, when training a machine learning model, it achieves a 2× speed-up with 10× less memory; for serving machine learning inference, Faasm doubles the throughput and reduces tail latency by 90%.

    https://arxiv.org/abs/2002.09344

    Shillaker S, Pietzuch P. Faasm: Lightweight isolation for efficient stateful serverless computing[C]//2020 {USENIX} Annual Technical Conference ({USENIX}{ATC} 20). 2020: 419-433.

## 毕设?

- 希望往 wasm + eBPF + edge computing + serverless + gis 的方向走?
- 尝试有一些相关的 gis 的 demo 应用, 证明这个思路的可行性?
- 在浏览器里面运行的大型 GIS 应用程序和分析程序, 同时还可以通过云端加速? (云边协同?)
- 比如同样一个 function, 又可以跑在浏览器里面, 又可以跑在边缘计算的节点, 又可以在云上以 serverless 的方式扩容, 同时性能还不错? 可以用任意语言编写, 也不需要管理对应的调度复杂度, 还可以并行?
- 什么样的 GIS 应用场景比较好呢? 我目前没想到....总之就是做一个 showcase, 证明这个思路的可行性, 以及有一些应用场景的潜力?
  - 要有现成的开源代码, 最好是 C/C++ 写的, Java 或者 Go 可能也勉强可以, 这样我不用自己写太具体的 GIS 算法, 只要搭框架和写业务就好(这样工作量不至于过大); 而且我和华南理工那边都希望开源出去;
  - 最好是计算密集型, 但还是有一定程度上的相互通信的科学计算任务, 比较方便展示 serverless 并行效果?(图形学的事可能不如用 GPU 跑)
  - 或者原先是桌面的 C/C++ 算法代码, 现在编译成 wasm 就可以丢进浏览器跑, 同时还可以上云扩容?以及在浏览器里面跑, 还可以糊一个前端,看起来好玩一点?
  - 有一些边缘计算场景?
- 具体的工作的话我也可以去修改一下这个底层的 wasm serverless 运行时平台, 然后把这个 GIS 的工作负载应用给跑上去.
- 校外导师?

(不知道, 瞎说的)
