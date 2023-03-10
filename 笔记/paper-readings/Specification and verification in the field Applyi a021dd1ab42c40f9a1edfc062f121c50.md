# 论文阅读：领域中的规范和验证：将形式化方法应用于 Linux 内核中的 BPF 即时编译器

> 本文来自 eunomia-bpf 社区，我们正在探索 eBPF 和 WebAssembly 相互结合的工具链和运行时: <https://github.com/eunomia-bpf/wasm-bpf> 社区关注于简化 eBPF 程序的编写、分发和动态加载流程，以及探索 eBPF 和 Wasm 相结合的工具链、运行时和运用场景等技术。

OSDI 论文：[https://www.usenix.org/system/files/osdi20-nelson.pdf](https://www.usenix.org/system/files/osdi20-nelson.pdf)

yutube [https://www.youtube.com/watch?v=2V3ts5-W_9g](https://www.youtube.com/watch?v=2V3ts5-W_9g)

## 摘要：

本文描述了我们在 Linux 内核的关键组件之一，即 Berkeley Packet Filter（BPF）虚拟机的即时编译器（“JITs”）上应用形式化方法的经验。我们使用 Jitterbug 验证这些 JITs，Jitterbug 是第一个能够提供精确 JIT 正确性规范并能够排除现实世界中错误的框架，以及一种可扩展到实际实现的自动化证明策略。使用 Jitterbug，我们已经设计、实现和验证了一个新的 BPF JIT，用于 32 位 RISC-V，发现并修复了其他五个 JIT 中的 16 个先前未知的 bug，并开发了新的 JIT 优化；所有这些更改都已经被上游到 Linux 内核。结果表明，在仔细设计规范和证明策略的情况下，可以在一个大型未经验证的系统中构建一个验证组件。

据我们所知，Jitterbug是第一款提供了规范的工具，可以排除实际JIT实现中的错误，并提供了一种证明策略，可以将自动化验证扩展到一类编译器。通过规范和证明策略的精心设计，它展示了在正在积极开发的大型未经验证的系统（即Linux内核）中构建已验证组件（即BPF JIT）的可行性。本文描述了我们的设计决策以及背后的原理（§8）。

## 贡献:

为了应对这些挑战，Jitterbug做出了以下贡献:
• 关于JIT正确性的精确逐步规范(§4)。该规范将BPF和目标架构都建模为抽象机器，并将JIT正确性表述为运行带有源BPF指令和JIT生成的目标指令的机器的行为等效性。该规范假定JIT一次只能翻译一个源指令。这个假设与实际的BPF JIT实现相匹配，避免了需要推理整个程序翻译的需要。
• 一种可扩展到实际BPF JIT的自动证明策略(§5)。Jitterbug在Serval [68]的基础上，使用符号计算 [10,89] 产生一个满足性查询，该查询编码了JIT实现、源BPF代码和JIT生成的目标机器代码的语义，然后使用SMT求解器 [21]进行查询。由于Serval是为静态已知代码的系统推理而设计的，因此无法用于验证由JIT的符号计算生成的符号指令(例如具有符号字段、在符号地址处)。Jitterbug通过一种符号计算策略来解决这个挑战，该策略可以推理这种符号代码。
• 一种基于C的领域特定语言(DSL)编写JIT的方法(§6)。Jitterbug DSL是一个基于C的浅嵌入式Rosette [88,89]的结构化子集，它扩展了Racket [29]来进行符号推理。也就是说，Jitterbug DSL将C的一个子集实现为一个Rosette库。我们使用DSL编写新的JIT，这简化了验证并支持JIT优化的合成 [59,82]。Jitterbug通过一个(未经验证的)提取机制自动翻译DSL中编写的JIT到C。我们通过手动将其C代码翻译为Rosette来验证现有的JIT。
•使用Jitterbug构建了一个面向RV32的BPF JIT，发现并修复了五个现有的BPF JIT中的bug，进行了代码审查，开发了优化，并为一个堆栈机器[65]移植了一个JIT，所有这些都具有较低的验证开销(§7)。其中一个bug已经导致了RISC-V指令集手册的澄清。我们报告了改进Jitterbug和将JIT代码上游到Linux内核的迭代过程。

## 相关工作

设计验证系统以进行部署。部署能力是正式验证系统的理想目标，但它需要航行额外的设计权衡。作为第一个经过验证的通用微内核，seL4 [46] 开创了许多设计和部署过程的方面。例如，它引入了 Haskell 原型作为形式化方法和内核开发人员之间的桥梁，将验证工件与 C 实现分离 [45]。它已被部署为超级监视器，以更新未经验证的遗留软件，以驱动安全关键系统 [37, 47]。另一个例子是 CompCert，第一个经过验证的 C 编译器。它已集成到安全关键系统的控制软件开发过程中 [41, 53]，替换了配置为禁用优化的未经验证编译器，以应对风险问题。
加密库是验证的有吸引力的目标，因为它们在安全方面起着重要作用。例如，Mozilla 和 Google 分别使用 EverCrypt/HACL∗ [75, 99] 和 Fiat-Crypto [27] 的验证代码。亚马逊的 s2n TLS 实现 [16] 通过手动和自动证明的组合进行验证。
Jitterbug 是将形式化方法应用于 Linux 内核中的 BPF JIT 的案例研究。它分享了这些设计挑战，并通过精确的规范和可扩展到实际 JIT 实现的证明策略来解决这些挑战。

## Discussion and limitations

Jitterbug的JIT正确性（定义1），特别是使用跟踪的方式，受到CompCert [54]规范的启发。Jitterbug的规范有以下不同之处。首先，内核执行对源程序有更严格的要求（例如确定性，终止性和未定义行为的缺失），使我们能够证明更强的属性。其次，Jitterbug使用目标体系结构的细粒度模型来精确推理低级状态（例如程序计数器和堆栈指针），而CompCert使用更抽象的汇编语言语义[64: §5]，并依赖于单独的汇编器和链接器。第三，这种JIT的每个指令编译过程使我们能够开发逐步规范，方便自动验证。 Jitterbug相信假设的正确性（§4.2）。因此，它无法捕捉JIT上下文中的错误（例如可偏移构造）或目标程序的布局。我们手动检查Linux内核中现有的BPF JIT正确性错误（§3.2），并确定在82个错误中，规范可以捕获除偏移表构造之外的所有错误。这显示了规范的有效性。Jitterbug的规范允许“空”JIT实现，它在所有源程序上都失败；我们使用现有的测试套件（例如BPF selftests）来评估JIT的功能完整性。它专注于JIT，无法排除BPF检查器，代码映像的内存管理或内核使用JIT中的错误。它不模拟指令高速缓存或内存权限，依赖于内核正确刷新缓存并设置权限。它不提供任何针对微架构时序通道[32,48]的保证。

## 复现：jitterbug

[https://github.com/uw-unsat/jitterbug](https://github.com/uw-unsat/jitterbug)

1. install requires:

```
sudo apt install racket
git clone --recursive https://github.com/uw-unsat/jitterbug
cd serval-bpf
raco pkg install --auto ./serval
sudo apt install z3
```

1. cannot find…

```jsx
serval/serval/lib/solver.rkt:6:2: cannot open module file
module path: rosette/solver/smt/yices
path: /home/yunwei/.local/share/racket/8.6/pkgs/rosette/rosette/solver/smt/yices.rkt
system error: no such file or directory; rkt_err=3
location...:
serval/serval/lib/solver.rkt:6:2
context...:
/home/yunwei/.local/share/racket/8.6/pkgs/rosette/rosette/base/form/module.rkt:16:0
[repeats 1 more time]
/usr/share/racket/pkgs/compiler-lib/compiler/commands/test.rkt:395:27
/usr/share/racket/pkgs/compiler-lib/compiler/commands/test.rkt:397:0: call-with-summary
.../private/map.rkt:40:19: loop
/usr/share/racket/pkgs/compiler-lib/compiler/commands/test.rkt:1128:1: test
body of "/usr/share/racket/pkgs/compiler-lib/compiler/commands/test.rkt"
/usr/share/racket/collects/raco/raco.rkt:41:0
body of "/usr/share/racket/collects/raco/raco.rkt"
body of "/usr/share/racket/collects/raco/main.rkt"
```

remove all related to yices in jitterbug/serval/serval/lib/solver.rkt

1. system error

```jsx
[ RUN      ] "VERIFY (BPF_JMP32 BPF_JNE BPF_X)"
--------------------
arm32-alu64-k tests > VERIFY (BPF_ALU64 BPF_OR BPF_K)
ERROR

error writing to stream port
  system error: Broken pipe; errno=3
```

see 

[https://github.com/emina/rosette/issues/88](https://github.com/emina/rosette/issues/88)

```jsx
ls /home/yunwei/.local/share/racket/8.6/pkgs/rosette/bin/
yunwei@yunwei-virtual-machine:~/jitterbug$ which z3
/usr/bin/z3
yunwei@yunwei-virtual-machine:~/jitterbug$ ln -s /usr/bin/z3 /home/yunwei/.local/share/racket/8.6/pkgs/rosette/bin/z3
```

用 z3 可能太慢，需要使用 boolector，同样需要放到对应的位置

注意不能 apt install，有版本要求

参考 [https://docs.racket-lang.org/rosette-guide/sec_solvers-and-solutions.html](https://docs.racket-lang.org/rosette-guide/sec_solvers-and-solutions.html)

需要从头构建 boolector

You may also wish to install the [Boolector](https://boolector.github.io/)
SMT求解器。我们使用配置为使用CaDiCal SAT求解器的Boolector v3.2.1进行了测试。验证和合成将首先尝试使用它，然后再退回到Z3，这可能需要更长的时间（例如，合成可能慢了10倍以上）。

注意 Boolector 一般使用数十秒才能完成一条指令的验证，z3 可能要十分钟一条…

yunwei@yunwei-virtual-machine:~/jitterbug$ ln -s /usr/local/bin/boolector /home/yunwei/.local/share/racket/8.6/pkgs/rosette/bin/boolector

然后就可以运行啦

```jsx
$ raco test racket/test/rv64/verify-alu32-x.rkt
raco test: (submod "racket/test/rv64/verify-alu32-x.rkt" test)
ENABLE_STACK_ADDR_SYMOPT=#f
ENABLE_JIT_SPLIT_REGS=#f
Using solver #<boolector>
riscv64-alu32-x tests
[ RUN      ] "VERIFY (BPF_ALU BPF_MOV BPF_X)"
[       OK ] "VERIFY (BPF_ALU BPF_MOV BPF_X)" (24578 ms)
[ RUN      ] "VERIFY (BPF_ALU BPF_ADD BPF_X)"
[       OK ] "VERIFY (BPF_ALU BPF_ADD BPF_X)" (32643 ms)
[ RUN      ] "VERIFY (BPF_ALU BPF_SUB BPF_X)"
[       OK ] "VERIFY (BPF_ALU BPF_SUB BPF_X)" (72785 ms)
[ RUN      ] "VERIFY (BPF_ALU BPF_AND BPF_X)"
[       OK ] "VERIFY (BPF_ALU BPF_AND BPF_X)" (32935 ms)
[ RUN      ] "VERIFY (BPF_ALU BPF_OR BPF_X)"
[       OK ] "VERIFY (BPF_ALU BPF_OR BPF_X)" (29574 ms)
[ RUN      ] "VERIFY (BPF_ALU BPF_XOR BPF_X)"
```

## **Finding bugs via verification**

As an example, let's inject a bug fixed in commit [1e692f09e091].

Specifically, remove the zero extension for `BPF_ALU|BPF_ADD|BPF_X`

in `racket/rv64/bpf_jit_comp64.rkt`:

```jsx
[((BPF_ALU BPF_ADD BPF_X)
(BPF_ALU64 BPF_ADD BPF_X))
(emit (if is64 (rv_add rd rd rs) (rv_addw rd rd rs)) ctx)
(when (&& (! is64) (! (->prog->aux->verifier_zext ctx)))
(emit_zext_32 rd ctx))]
```

Now we have a buggy JIT implementation:

```jsx
[((BPF_ALU BPF_ADD BPF_X)
(BPF_ALU64 BPF_ADD BPF_X))
(emit (if is64 (rv_add rd rd rs) (rv_addw rd rd rs)) ctx)]
```

Run the verification:

```jsx
raco test racket/test/rv64/verify-alu32-x.rkt
```

Verification will fail with a counterexample:

```
[ RUN      ] "VERIFY (BPF_ALU BPF_ADD BPF_X)"
<unknown>: <unknown>: bpf-jit-specification: Final registers must match
--------------------
riscv64-alu32-x tests > VERIFY (BPF_ALU BPF_ADD BPF_X)
FAILURE
name:       check-unsat?
location:   [...]/bpf-common.rkt:218:4
params:
  '((model
   [x?$0 #f]
   [r0$0 (bv #x0000000080000000 64)]
   [r1$0 (bv #x0000000000000000 64)]
   [insn$0 (bv #x00800000 32)]
   [offsets$0 (fv (bitvector 32)~>(bitvector 32))]
   [target-pc-base$0 (bv #x0000000000000000 64)]
   [off$0 (bv #x8000 16)]))
--------------------
```

工具生成的反例给出了会触发错误的BPF寄存器值：它选择`r0`为`0x0000000080000000`，`r1`为`0x0000000000000000`。这证明了该错误，因为RISC-V指令对32位加法的结果进行符号扩展，而BPF指令执行零扩展。

## **Verification**

验证工作的原理是证明BPF指令与JIT为该指令生成的RISC-V指令之间的等价性。

以一个具体的例子来说明，考虑验证`BPF_ALU|BPF_ADD|BPF_X`指令。验证从构建一个*符号*的BPF指令开始，其中目标寄存器和源寄存器字段可以采用任何合法值：

`BPF_ALU32_REG(BPF_ADD, {{rd}}, {{rs}})`

接下来，验证器在BPF指令上符号地运行JIT，产生了一组可能的符号RISC-V指令序列：

`addw {{rv_reg(rd)}} {{rv_reg(rd)}} {{rv_reg(rs)}} slli {{rv_reg(rd)}} {{rv_reg(rd)}} 32 srli {{rv_reg(rd)}} {{rv_reg(rd)}} 32`

这里，`rv_reg`表示与特定BPF寄存器相关联的RISC-V寄存器。

接下来，该工具证明了每个生成的RISC-V指令序列对于所有可能的寄存器rd和rs的选择以及所有RISC-V通用寄存器的所有初始值，具有与原始BPF指令等效的行为。为此，它利用了由[Serval](https://unsat.cs.washington.edu/projects/serval/)验证框架提供的自动验证器，具体如下。

验证器从符号BPF状态和符号RISC-V状态开始，分别称为`bpf-state`和`riscv-state`，假定两个初始状态匹配，例如，对于所有`reg`，`riscv-state[rv_reg(reg)] == bpf-state[reg]`。接下来，它在`bpf-state`上运行Serval BPF验证器，在`riscv-state`上运行每个生成的RISC-V指令序列上的RISC-V验证器。然后，它证明最终的BPF和RISC-V状态仍然匹配。

对于更复杂的指令，例如跳转和分支，需要额外的注意。有关详细信息，请参见`lib/bpf-common.rkt:verify-jit-refinement`中的JIT正确性定义。这种复杂性来自于必须证明生成的指令保持BPF程序计数器和RISC-V程序计数器之间的对应关系。

## Synthesis for the RV32 JIT

为了帮助开发和优化RV32 JIT，我们使用Rosette的程序合成功能为BPF指令的一个子集综合合成每个指令的编译器。

综合过程以Serval的BPF和RISC-V解释器、BPF JIT正确性规范和程序草图作为输入，描述了要搜索的代码结构。综合然后在搜索空间中耗尽地搜索越来越大的候选序列，直到找到满足JIT正确性规范的序列。

您可以通过运行以下命令来尝试这个功能：

`raco test racket/test/rv32/synthesize-alu64-x.rkt`

它将产生类似于以下的输出：

`riscv32-alu64-x synthesis
Running test "SYNTHESIZE (BPF_ALU64 BPF_SUB BPF_X)"
Using solver #<boolector>
Synthesizing for op '(BPF_ALU64 BPF_SUB BPF_X) with size 0
Synthesizing for op '(BPF_ALU64 BPF_SUB BPF_X) with size 1
Synthesizing for op '(BPF_ALU64 BPF_SUB BPF_X) with size 2
Synthesizing for op '(BPF_ALU64 BPF_SUB BPF_X) with size 3
Synthesizing for op '(BPF_ALU64 BPF_SUB BPF_X) with size 4

Solution found for '(BPF_ALU64 BPF_SUB BPF_X):
void emit_op(u8 rd, u8 rs, s32 imm, struct rv_jit_context *ctx) {
    emit(rv_sub(RV_REG_T1, hi(rd), hi(rs)), ctx);
    emit(rv_sltu(RV_REG_T0, lo(rd), lo(rs)), ctx);
    emit(rv_sub(hi(rd), RV_REG_T1, RV_REG_T0), ctx);
    emit(rv_sub(lo(rd), lo(rd), lo(rs)), ctx);
}

cpu time: 3513 real time: 141078 gc time: 324`

在这个例子中，综合算法能够找到一系列由四条RV32指令组成的序列，这些指令能够正确地模拟一个“BPF_ALU64 BPF_SUB BPF_X”指令的行为。这个解决方案被打印成一个C函数“emit_op”。你可以在“arch/riscv/net/bpf_jit_comp32.c”文件中的“emit_rv32_alu_r64”函数的“BPF_SUB”情况中看到它是如何被整合到最终的JIT中的。请注意，JIT中的指令可能与你的机器上求解器找到的解决方案不同。

你可以通过查看其他的“racket/test/rv32/synthesize-*.rkt”文件，并取消注释这些文件中其他指令的情况，来尝试合成其他指令。

并非所有最终JIT中的指令序列都是通过综合算法找到的。许多综合查询要么非常耗时，要么没有产生任何结果：特别是那些需要非常长的指令序列（例如64位移位），或者使用非线性算术（乘法、除法等）的指令。对于这些指令，我们手动编写实现，并使用本指南中描述的其他技术来验证其正确性。.

## Generating the RV32 JIT

RV32 JIT分为两个部分：Racket实现在`racket/rv32/bpf_jit_comp32.rkt`中包含了为给定BPF指令生成RV32指令序列所需的代码，而`racket/rv32/bpf_jit_comp32.c.tmpl`是一个模板，包含了需要让JIT接口在C中编译并与内核的其余部分进行交互所需的粘合C代码。该模板包含了需要从相应的Racket源代码提取到C的空缺部分。

可以通过以下方式生成`arch/riscv/net/bpf_jit_comp32.c`和头文件`arch/riscv/net/bpf_jit.h`：

`make gen`

可以将这些文件复制到Linux内核源码树中进行构建和测试。

## 注意事项 / 限制

`racket/test/`目录下的测试用例显示了目前已验证的JIT指令。对于这些指令，它证明了对于所有可能的初始寄存器值、所有跳转偏移量、所有立即值等，JIT的正确性都是正确的。

验证一次只能证明单个BPF指令的JIT的正确性。目前尚未指定或验证JIT的几个属性：

- 对于riscv32而言，支持验证过程和收尾过程的有限支持。
- 对于呼叫/退出指令，支持有限:
    - `BPF_CALL`，`BPF_TAIL_CALL`和`BPF_EXIT` 在riscv32和riscv64上支持；
    - `BPF_CALL`和`BPF_EXIT`在arm32和arm64上支持。

验证做出了以下假设：

- `ctx->offset`映射已正确构建。
- BPF程序已通过内核的BPF验证器：例如，它假设没有除零或超出范围的位移。
- BPF指令的数量小于16M，生成的RISC-V镜像小于128MB。这些边界可以增加，但会增加整体跳转的验证时间。
- 在验证的Racket JIT和C代码之间的翻译是可信的。任何翻译不匹配可能意味着C版本中存在的错误在经过验证的版本中不存在。