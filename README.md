# 一个ZJU本科生的计算机/地理信息科学知识库

<div align="center">
<img style="object-position: center;height: 30vmin;border-radius: 50%;" src="https://avatars.githubusercontent.com/u/34985212?v=4">
</div>

## 路漫漫其修远兮...

> 这里是一些地理信息科学/计算机科学与技术的笔记/作业（也包含自学的公开课部分，存放一些杂项）的整理，例如各种本科课程的作业、笔记、项目链接，对课程的总结和经验分享，遇到过很棒的技术博客等等...也许可以供您参考；不过我自己属于凭兴趣上课也不是特别在意绩点，所以有些作业可能是水过去的，并不能保证质量一致（仅供参考）
> 
> 建造这个仓库的初衷其实只是为了我自己存储一些资料，以便于在有需要的时候能快速回忆起自己到底学过了哪些东西；
> `也许您也曾碰到过这样的情况：好像曾经上过某些课程或者阅读过很久价值的文章，但反过来又忘记了具体内容...`
>

*不包含教师授课的PPT、非本人回忆的历年卷、以及一些不适合公开的作业内容等等（但可能会给出其他公开链接）*

*请勿抄袭*

（以后有时间会慢慢把之前的其他的笔记和资料整理上来）

- 如果对您有帮助的话也可以帮忙点个 star 
- 但实际上我个人认为借鉴作业并不是一种糟糕的学习方式，至少也比什么都不做来的好...
- 个人主要技术栈是后端 C/C++/rust 方向，前端稍微有一点了解；

-----------------------

## 目录

<!-- TOC -->

- [路漫漫其修远兮...](#路漫漫其修远兮)
- [目录](#目录)
- [文件夹组织结构：](#文件夹组织结构)
- [作业以及项目链接](#作业以及项目链接)
  - [Demo](#demo)
  - [Project](#project)
- [公开课/活动](#公开课活动)
- [博客/论文/其他一些杂项](#博客论文其他一些杂项)

<!-- /TOC -->

## 文件夹组织结构：

本仓库的目录结构大致以课程分类，可能部分不完全相同（也许可以试着使用一下 github 的搜索功能？）：

- 编译原理
- 计算机网络（包含地理信息系统与网络技术）
- 计算机系统概论
- 程序设计语言
  - 程序设计专题（H）
  - 面向对象程序设计
  - java/c小程（上过课但是好像没有什么东西留下来）
- 数据结构与算法（包含数据结构基础、高级数据结构与算法分析）
  - leetcode题解
  - pta/pat题解
  - 自己的部分数据结构实现
- 数据库
- 计算机图形学
- 人工智能
- 计算机体系结构（包含计算机组成）
- 操作系统
- 其他专业课程
- 杂项（工具，笔记）
    
## 作业以及项目链接

这部分是一些课程小项目或者大作业的链接，还有一些自己学习过程中写的 demo，有一部分在本 repo 中，一部分在其他 repo：

### Demo

数据结构：

- [基于倒排索引的文本搜索引擎](数据结构与算法/search_engine)
- [地理空间索引：四叉树/希尔伯特曲线/Z曲线](地理空间数据库/Geometry)
- [rust 实现的可持久化 AVL 树](https://github.com/yunwei37/immutable-map-rs)

深度学习：

- [剪枝搜索实现黑白棋AI](人工智能/AI_Reversi)
- [基于卷积神经网络的垃圾分类](人工智能/garbage-classification)
- [自适应中值滤波算法去除椒盐噪声](人工智能/image-restoration)

网络：

- [基于Socket接口实现自定义协议聊天室](计算机网络/socketChat)
- [一个轻量级的WEB服务器](计算机网络/webServer)

图形学：

- [三维太阳系](计算机图形学/SolarSystem)
- [简单的软件光追渲染器](https://github.com/yunwei37/rayTracing)

其他：

- [一个小型解释器](https://github.com/yunwei37/tryC)

### Project

GIS:

- GIS程序设计：湖北疫情数据专题显示系统 [https://github.com/yunwei37/COVID-19-ArcEngine](https://github.com/yunwei37/COVID-19-ArcEngine)
- 地理空间数据库：新冠肺炎疫情数据可视化交互分析网站平台 [https://github.com/yunwei37/COVID-19-NLP-vis](https://github.com/yunwei37/COVID-19-NLP-vis)
  
C++：

- 面向对象程序设计：基于QT开发的UNO局域网联机卡牌游戏 [https://github.com/yunwei37/UNO-game-oop](https://github.com/yunwei37/UNO-game-oop)
- 课程综合实践Ⅱ：C++ 工程实践：OpenGL 实现的类似MC的一个简单沙盒游戏 [https://github.com/yunwei37/mc](https://github.com/yunwei37/mc)
- [一个使用 C++20 协程和 io_uring 编写的服务器](https://github.com/yunwei37/co-uring-WebServer)

计算机系统：

- 计算机组成：Qt实现的图形化界面MIPS汇编指令的汇编器/反汇编器/模拟器 [https://github.com/yunwei37/MIPS-sc-zju](https://github.com/yunwei37/MIPS-sc-zju)
- 计算机体系结构：多周期CPU设计 [计算机体系结构\多周期CPU设计](计算机体系结构/多周期CPU设计)
- 计算机体系结构: 流水线CPU设计 [计算机体系结构\流水线CPU设计](计算机体系结构/流水线CPU设计)
- 操作系统：一个 rust 编写的简单试验内核（原lab是用c写的，我改成rust了）[https://github.com/yunwei37/Linux-0.11-rs](https://github.com/yunwei37/Linux-0.11-rs)

其他：

- 一个简单的区块链实践：[用 rust 从零开始构建区块链](https://github.com/yunwei37/blockchain-rust)

## 公开课/活动

操作系统：

- [2018 年的旧版 mit 6.828 labs：1-6](https://github.com/yunwei37/6.828-2018-labs):

  某个非常著名的操作系统课程，年轻人的第一次操作系统实践

- [OS summer of code 2020](https://github.com/yunwei37/os-summer-of-code-daily)

  rcore 开源社区举办的某个活动

## 博客/论文/其他一些杂项

- 传送门：[我的博客](https://www.yunwei123.tech/backlogs/)

