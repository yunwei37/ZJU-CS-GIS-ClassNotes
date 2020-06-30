# lab1笔记 && 中文代码注释

## init

1. setup

    实验内容采用git分发：
    
    ```
    git clone https://pdos.csail.mit.edu/6.828/2018/jos.git lab
    ```

    测试的话可以使用：
    
    ```
    make grade

    ```

## Part 1: PC Bootstrap

- 需要了解x86汇编以及内联汇编的写法，参看：

    [http://www.delorie.com/djgpp/doc/brennan/brennan_att_inline_djgpp.html](http://www.delorie.com/djgpp/doc/brennan/brennan_att_inline_djgpp.html)
    [https://pdos.csail.mit.edu/6.828/2018/readings/pcasm-book.pdf](https://pdos.csail.mit.edu/6.828/2018/readings/pcasm-book.pdf)

- 运行 qemu

    ```
    cd lab
    make 
    make qemu

    ```

- PC的物理地址空间：

    ```
    +------------------+  <- 0xFFFFFFFF (4GB)
    |      32-bit      |
    |  memory mapped   |
    |     devices      |
    |                  |
    /\/\/\/\/\/\/\/\/\/\

    /\/\/\/\/\/\/\/\/\/\
    |                  |
    |      Unused      |
    |                  |
    +------------------+  <- depends on amount of RAM
    |                  |
    |                  |
    | Extended Memory  |
    |                  |
    |                  |
    +------------------+  <- 0x00100000 (1MB)
    |     BIOS ROM     |
    +------------------+  <- 0x000F0000 (960KB)
    |  16-bit devices, |
    |  expansion ROMs  |
    +------------------+  <- 0x000C0000 (768KB)
    |   VGA Display    |
    +------------------+  <- 0x000A0000 (640KB)
    |                  |
    |    Low Memory    |
    |                  |
    +------------------+  <- 0x00000000

    ```

- 使用 gdb 调试qemu：

打开新的窗口：

    cd lab
    make qemu-gdb

在另外一个终端：

    make
    make gdb

开始使用gdb调试，首先进入实模式；

- IBM PC从物理地址0x000ffff0开始执行，该地址位于为ROM BIOS保留的64KB区域的最顶部。
- PC从CS = 0xf000和IP = 0xfff0开始执行。
- 要执行的第一条指令是jmp指令，它跳转到分段地址 CS = 0xf000和IP = 0xe05b。

物理地址 = 16 *网段 + 偏移量

然后，BIOS所做的第一件事就是jmp倒退到BIOS中的较早位置；


## Part 2: The Boot Loader 引导加载程序

PC的软盘和硬盘分为512个字节的区域，称为扇区。

当BIOS找到可引导的软盘或硬盘时，它将512字节的引导扇区加载到物理地址0x7c00至0x7dff的内存中，然后使用jmp指令将CS：IP设置为0000：7c00，将控制权传递给引导程序装载机。

### 引导加载程序必须执行的两个主要功能：

- 将处理器从实模式切换到 32位保护模式；
- 通过x86的特殊I / O指令直接访问IDE磁盘设备寄存器，从硬盘读取内核；

### 引导加载程序的源代码：

boot/boot.S

```asm
#include <inc/mmu.h>

# 启动CPU：切换到32位保护模式，跳至C代码；
# BIOS将该代码从硬盘的第一个扇区加载到
# 物理地址为0x7c00的内存，并开始以实模式执行
# %cs=0 %ip=7c00.

.set PROT_MODE_CSEG, 0x8         # 内核代码段选择器
.set PROT_MODE_DSEG, 0x10        # 内核数据段选择器
.set CR0_PE_ON,      0x1         # 保护模式启用标志

.globl start
start:
  .code16                     # 汇编为16位模式
  cli                         # 禁用中断
  cld                         # 字符串操作增量，将标志寄存器Flag的方向标志位DF清零。
                              # 在字串操作中使变址寄存器SI或DI的地址指针自动增加，字串处理由前往后。

  # 设置重要的数据段寄存器（DS，ES，SS）
  xorw    %ax,%ax             # 第零段
  movw    %ax,%ds             # ->数据段
  movw    %ax,%es             # ->额外段
  movw    %ax,%ss             # ->堆栈段

  # 启用A20：
  #   为了与最早的PC向后兼容，物理
  #   地址线20绑在低电平，因此地址高于
  #   1MB会被默认返回从零开始。  这边代码撤消了此操作。
seta20.1:
  inb     $0x64,%al               # 等待其不忙状态
  testb   $0x2,%al
  jnz     seta20.1

  movb    $0xd1,%al               # 0xd1 -> 端口 0x64
  outb    %al,$0x64

seta20.2:
  inb     $0x64,%al               # 等待其不忙状态
  testb   $0x2,%al
  jnz     seta20.2

  movb    $0xdf,%al               # 0xdf -> 端口 0x60
  outb    %al,$0x60

  # 使用引导GDT从实模式切换到保护模式
  # 并使用段转换以保证虚拟地址和它们的物理地址相同
  # 因此
  # 有效内存映射在切换期间不会更改。
  lgdt    gdtdesc
  movl    %cr0, %eax
  orl     $CR0_PE_ON, %eax
  movl    %eax, %cr0
  
  # 跳转到下一条指令，但还是在32位代码段中。
  # 将处理器切换为32位指令模式。
  ljmp    $PROT_MODE_CSEG, $protcseg

  .code32                     # 32位模式汇编
protcseg:
  # 设置保护模式数据段寄存器
  movw    $PROT_MODE_DSEG, %ax    # 我们的数据段选择器
  movw    %ax, %ds                # -> DS: 数据段
  movw    %ax, %es                # -> ES:额外段
  movw    %ax, %fs                # -> FS
  movw    %ax, %gs                # -> GS
  movw    %ax, %ss                # -> SS: 堆栈段
  
  # 设置堆栈指针并调用C代码，bootmain
  movl    $start, %esp
  call bootmain

  # 如果bootmain返回（不应该这样），则循环
spin:
  jmp spin

# Bootstrap GDT
.p2align 2                                # 强制4字节对齐 
gdt:
  SEG_NULL				# 空段
  SEG(STA_X|STA_R, 0x0, 0xffffffff)	# 代码段
  SEG(STA_W, 0x0, 0xffffffff)	        # 数据部分

gdtdesc:
  .word   0x17                            # sizeof(gdt) - 1
  .long   gdt                             # address gdt

```

boot/main.c

```c

#include <inc/x86.h>
#include <inc/elf.h>

/**********************************************************************
 * 这是一个简单的启动装载程序，唯一的工作就是启动
 * 来自第一个IDE硬盘的ELF内核映像。
 *
 * 磁盘布局
 *  * 此程序（boot.S和main.c）是引导加载程序。这应该
 *    被存储在磁盘的第一个扇区中。
 *
 *  * 第二个扇区开始保存内核映像。
 *
 *  * 内核映像必须为ELF格式。
 *
 * 启动步骤
 *  * 当CPU启动时，它将BIOS加载到内存中并执行
 *
 *  *  BIOS初始化设备，中断例程集以及
 *    读取引导设备的第一个扇区（例如，硬盘驱动器）
 *    进入内存并跳转到它。
 *
 *  * 假设此引导加载程序存储在硬盘的第一个扇区中
 *    此代码接管...
 *
 *  * 控制从boot.S开始-设置保护模式，
 *    和一个堆栈，然后运行C代码，然后调用bootmain（）
 *
 *  * 该文件中的bootmain（）会接管，读取内核并跳转到该内核。
 **********************************************************************/

#define SECTSIZE	512
#define ELFHDR		((struct Elf *) 0x10000) // /暂存空间

void readsect(void*, uint32_t);
void readseg(uint32_t, uint32_t, uint32_t);

void
bootmain(void)
{
	struct Proghdr *ph, *eph;

	// 从磁盘读取第一页
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);

	// 这是有效的ELF吗？
	if (ELFHDR->e_magic != ELF_MAGIC)
		goto bad;

	// 加载每个程序段（忽略ph标志）
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
		// p_pa是该段的加载地址（同样
		// 是物理地址）
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);

	// 从ELF标头中调用入口点
	// 注意：不返回！
	((void (*)(void)) (ELFHDR->e_entry))();

bad:
	outw(0x8A00, 0x8A00);
	outw(0x8A00, 0x8E00);
	while (1)
		/* do nothing */;
}

// 从内核将“偏移”处的“计数”字节读取到物理地址“ pa”中。
// 复制数量可能超过要求
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
	uint32_t end_pa;

	end_pa = pa + count;

	// 向下舍入到扇区边界
	pa &= ~(SECTSIZE - 1);

	// 从字节转换为扇区，内核从扇区1开始
	offset = (offset / SECTSIZE) + 1;

	// 如果速度太慢，我们可以一次读取很多扇区。
	// 我们向内存中写入的内容超出了要求，但这没关系 --
	// 我们以递增顺序加载.
	while (pa < end_pa) {
		// 由于尚未启用分页，因此我们正在使用
		// 一个特定的段映射 (参阅 boot.S), 我们可以
		// 直接使用物理地址.  一旦JOS启用MMU
		// ，就不会这样了
		readsect((uint8_t*) pa, offset);
		pa += SECTSIZE;
		offset++;
	}
}

void
waitdisk(void)
{
	// 等待磁盘重新运行
	while ((inb(0x1F7) & 0xC0) != 0x40)
		/* do nothing */;
}

void
readsect(void *dst, uint32_t offset)
{
	// 等待磁盘准备好
	waitdisk();

	outb(0x1F2, 1);		// count = 1
	outb(0x1F3, offset);
	outb(0x1F4, offset >> 8);
	outb(0x1F5, offset >> 16);
	outb(0x1F6, (offset >> 24) | 0xE0);
	outb(0x1F7, 0x20);	// cmd 0x20 - 读取扇区

	// 等待磁盘准备好
	waitdisk();

	// 读取一个扇区
	insl(0x1F0, dst, SECTSIZE/4);
}


```

### 加载内核

- ELF二进制文件：

    可以将ELF可执行文件视为具有加载信息的标头，然后是几个程序段，每个程序段都是要在指定地址加载到内存中的连续代码或数据块。ELF二进制文件以固定长度的ELF标头开头，其后是可变长度的程序标头， 列出了要加载的每个程序段。

执行`objdump -h obj/kern/kernel`，查看内核可执行文件中所有部分的名称，大小和链接地址的完整列表：

- .text：程序的可执行指令。
- .rodata：只读数据，例如C编译器生成的ASCII字符串常量。
- .data：数据部分保存程序的初始化数据，例如用int x = 5等初始化程序声明的全局变量；

- VMA 链接地址，该节期望从中执行的内存地址。
- LMA 加载地址，

```
obj/kern/kernel:     file format elf32-i386

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         00001acd  f0100000  00100000  00001000  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .rodata       000006bc  f0101ae0  00101ae0  00002ae0  2**5
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .stab         00004291  f010219c  0010219c  0000319c  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .stabstr      0000197f  f010642d  0010642d  0000742d  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .data         00009300  f0108000  00108000  00009000  2**12
                  CONTENTS, ALLOC, LOAD, DATA
  5 .got          00000008  f0111300  00111300  00012300  2**2
                  CONTENTS, ALLOC, LOAD, DATA
  6 .got.plt      0000000c  f0111308  00111308  00012308  2**2
                  CONTENTS, ALLOC, LOAD, DATA
  7 .data.rel.local 00001000  f0112000  00112000  00013000  2**12
                  CONTENTS, ALLOC, LOAD, DATA
  8 .data.rel.ro.local 00000044  f0113000  00113000  00014000  2**2
                  CONTENTS, ALLOC, LOAD, DATA
  9 .bss          00000648  f0113060  00113060  00014060  2**5
                  CONTENTS, ALLOC, LOAD, DATA
 10 .comment      00000024  00000000  00000000  000146a8  2**0
                  CONTENTS, READONLY

```

查看引导加载程序的.text部分：

objdump -h obj/boot/boot.out

```
obj/boot/boot.out:     file format elf32-i386

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         0000019c  00007c00  00007c00  00000074  2**2
                  CONTENTS, ALLOC, LOAD, CODE
  1 .eh_frame     0000009c  00007d9c  00007d9c  00000210  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .stab         00000870  00000000  00000000  000002ac  2**2
                  CONTENTS, READONLY, DEBUGGING
  3 .stabstr      00000940  00000000  00000000  00000b1c  2**0
                  CONTENTS, READONLY, DEBUGGING
  4 .comment      00000024  00000000  00000000  0000145c  2**0
                  CONTENTS, READONLY

```

引导加载程序使用ELF 程序标头来决定如何加载这些部分，程序标头指定要加载到内存中的ELF对象的哪些部分以及每个目标地址应占据的位置。

检查程序头：` objdump -x obj/kern/kernel`

ELF对象需要加载到内存中的区域是标记为“ LOAD”的区域。

```
Program Header:
    LOAD off    0x00001000 vaddr 0xf0100000 paddr 0x00100000 align 2**12
         filesz 0x00007dac memsz 0x00007dac flags r-x
    LOAD off    0x00009000 vaddr 0xf0108000 paddr 0x00108000 align 2**12
         filesz 0x0000b6a8 memsz 0x0000b6a8 flags rw-
   STACK off    0x00000000 vaddr 0x00000000 paddr 0x00000000 align 2**4
         filesz 0x00000000 memsz 0x00000000 flags rwx

```

查看内核程序的入口点`objdump -f obj/kern/kernel`：

```
obj/kern/kernel:     file format elf32-i386
architecture: i386, flags 0x00000112:
EXEC_P, HAS_SYMS, D_PAGED
start address 0x0010000c

```

- 在开始时，gdb会提示：The target architecture is assumed to be i8086
- 切换到保护模式之后(ljmpl  $0x8,$0xfd18f指令后)，提示: The target architecture is assumed to be i386

##