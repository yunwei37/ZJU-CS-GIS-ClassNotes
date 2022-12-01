
## SIMD 加速：AVX2 指令集实现大小端转换

> 在应用 thrift 进行 RPC 通信的时候，由于 Thrift 采用了大端序，而 x86_64 等常见的处理器架构均为小端序，因此对于 list 这一类的数据类型需要一个循环来实现小端到大端的转换。而这个过程如果能够利用 SIMD 指令的话，可以极大的提高性能。这篇文章是在探索实现 Thrift 编译后端 Auto-vectorization Pass 的时候进行的一个尝试和学习，使用 avx2 指令集实现了一个简单的大小端转换的功能，并且对比了在不同条件下的加速性能。

## 原理

### 大小端转换

计算机数据存储有两种字节优先顺序：高位字节优先（称为大端模式）和低位字节优先（称为小端模式）。

- `大端模式`，是指数据的高字节保存在内存的低地址中，而数据的低字节保存在内存的高地址中，这样的存储模式有点儿类似于把数据当作字符串顺序处理：地址由小向大增加，而数据从高位往低位放；这和我们的阅读习惯一致。
- `小端模式`，是指数据的高字节保存在内存的高地址中，而数据的低字节保存在内存的低地址中，这种存储模式将地址的高低和数据位权有效地结合起来，高地址部分权值高，低地址部分权值低。

例如，对于内存中存放的数0x12345678来说

- 如果是采用大端模式存放的，则其真实的数是：0x12345678
- 如果是采用小端模式存放的，则其真实的数是：0x78563412

可以使用如下 API 进行转换：

```c
#include <arpa/inet.h>
 
uint32_t htonl(uint32_t hostlong);
uint16_t htons(uint16_t hostshort);
uint32_t ntohl(uint32_t netlong);
uint16_t ntohs(uint16_t netshort);
```

也可以直接使用移位进行实现

```c
inline uint32_t Swap32(uint32_t x)
{
	return (
		((x & 0x000000FF) << 24) |
		((x & 0x0000FF00) << 8) |
		((x & 0x00FF0000) >> 8) |
		((x & 0xFF000000) >> 24));
}
```

### bswap

大部分编译器同时提供了 `bswap` 指令，来帮助实现这一转换过程，例如在 gcc 中，我们可以使用 `__builtin_bswap{16,32,64}`：

```c
inline uint32_t Swap32(uint32_t x)
{
	return __builtin_bswap32(x);
}
```

这是一个编译器的内置函数。在 x86_64 机器上，它会被编译为这样的指令序列：

```s
Swap32(unsigned int):
  mov eax, edi
  bswap eax
  ret
```

在 arm 机器上，它会被编译为这样的指令序列：

```s
Swap32(unsigned int):
  rev w0, w0
  ret
```

通常来说，我们自己使用的移位函数实现的大小端转换，在编译器优化 O2 时也会被自动识别替换为 bswap 指令。

### avx2 指令集

使用 SIMD 对于这样可以高度并行化的计算应该是一个更快的选择。bswap指令可以反转 2, 4, 或 8 字节的字节顺序，但 x86 中的 SIMD 扩展允许仅使用一条指令对多条数据通道进行并行操作。就像原子地反转寄存器中的所有四个字节一样，它提供了一个完整的算术指令集，允许使用一条指令同时并行处理多个数据实例。这些被操作的数据块往往被称为 vectors。一般来说可用的有如下几种 SIMD 指令集：

- MMX (1996)
- SSE (1999)
- SSE2 (2001)
- SSE3 (2004)
- SSSE3 (2006)
- SSE4 a/1/2 (2006)
- AVX (2008)
- AVX2 (2013)
- AVX512 (2015)

目前较为常用的是 avx/avx2 指令集，早先的某些指令集主要是为了兼容性而保留的。具体的指令信息，可以参考 [Intel 指令集查询](https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html)。

我们这里主要使用的是 `_mm256_shuffle_epi8` 指令，在 C 中它被定义在了 `#include <immintrin.h>` 头文件中。它实现了一个 vector 中字节的重排序，例如将一个 128 位的字节序列完全反转：

```c
const __m256i ShuffleRev = _mm256_set_epi8(
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15, // first 128-bit lane
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15  // second 128-bit lane
);
// Load 32 elements at once into one 32-byte register
__m256i x = _mm256_loadu_si256(
	reinterpret_cast<__m256i*>(&Array8[i])
);
// Reverse each the bytes in each 128-bit lane
x = _mm256_shuffle_epi8(x,ShuffleRev);
```

它接受一个ShuffleRev，定义具体每个字节应该被放到哪个位置。注意每128位为一个通道，重排范围只能在128位内，不能将前128位的内容重排至后128位。可以参照下图，可能会比较直观：

![pshufb](img\pshufb_3.png)

> 来源：https://www.officedaytime.com/simd512e/simdimg/si.php?f=pshufb

在 gcc -O3 中，Auto-vectorization Pass 可以帮助我们自动识别可以被向量化的循环，并且使用 avx 指令集进行并行化优化。

## avx2 code

这是一个对于 64 位整数的大小端转换 load-swap-store 循环，使用 avx2 指令集进行加速的简单示例：

```c
void reverse64_avx2(void *Array, size_t Count)
{
	uint64_t *Array64 = (uint64_t *)(Array);
	size_t i = 0;
	const __m256i ShuffleRev = _mm256_set_epi8(
		8, 9, 10, 11, 12, 13, 14, 15, 0, 1, 2, 3, 4, 5, 6, 7,
		8, 9, 10, 11, 12, 13, 14, 15, 0, 1, 2, 3, 4, 5, 6, 7);

	for (; i < (Count & ~0b11); i += 4)
	{
		// Load 4 elements
		__m256i bytes = _mm256_loadu_si256(
			(__m256i *)(&Array64[i]));

		// Reverse the byte order of our 64-byte vectors
		bytes = _mm256_shuffle_epi8(bytes, ShuffleRev);

		// Place them back into the array
		_mm256_storeu_si256(
			(__m256i *)(&Array64[i]),
			bytes);
	}

	// Naive swaps for leftover elements
	for (; i < Count; ++i)
	{
		Array64[i] = Swap64(Array64[i]);
	}
}
```

avx2 指令集的向量是 256 位长度，相当于 4 个 64bit 的整数。由于输入的数组并不一定被 4 整除，因此结尾的部分使用一般转换法逐个进行大小端转换。

## benchmark

测试环境：

- Linux ubuntu 5.13.0-51-generic #58~20.04.1-Ubuntu SMP Tue Jun 14 11:29:12 UTC 2022 x86_64
- Intel Core i7-10750H

编译指令：

```bash
gcc main.c  -mavx2 -fno-tree-vectorize -O3 -o avx 
```

basic 对照函数（这里 Swap64 会被 gcc 自动编译为 bswap 指令）：

```c
void reverse64_basic(void *Array, size_t Count)
{
	uint64_t *Array64 = (uint64_t *)(Array);
	size_t i = 0;

	// Naive swaps
	for (; i < Count; ++i)
	{
		Array64[i] = Swap64(Array64[i]);
	}
}
```

我们分别对 64/32/16 位的整数进行大小端转换，并测试 bswap 和 avx2 的加速比：

| array size | avx2 64bit | basic 64bit | avx2 32bit | basic 32bit | avx2 16bit | basic 16bit |
|------------|------------|-------------|-------------|-------------|-------------|-------------|
|          4 |        2ns |        3ns |        3ns |        3ns |        4ns |        2ns |
|          8 |        3ns |        4ns |        2ns |        4ns |       15ns |        9ns |
|         16 |        5ns |        9ns |        3ns |        9ns |        3ns |       10ns |
|         32 |        9ns |       37ns |        5ns |       18ns |        4ns |       19ns |
|         64 |       19ns |       34ns |        9ns |       34ns |        6ns |       59ns |
|        128 |       35ns |      181ns |       15ns |       76ns |        9ns |       82ns |
|        256 |       52ns |      120ns |       26ns |      477ns |       11ns |      712ns |
|        512 |       86ns |      248ns |       44ns |      192ns |       29ns |      254ns |
|       1024 |      179ns |      510ns |       96ns |      422ns |       47ns |      486ns |
|       2048 |      383ns |      996ns |      179ns |      812ns |       96ns |      981ns |
|       4096 |      726ns |     2190ns |      457ns |     2675ns |      384ns |     1878ns |
|       8192 |     1544ns |     4170ns |      748ns |     3434ns |      401ns |     4511ns |
|      16384 |     3570ns |     8977ns |     1704ns |     6771ns |      793ns |     7941ns |

可以注意到，对于宽度更小的整数的数组，并行度更高，avx2 加速比更加明显。在 64 位时，加速比约为 2.5，在 16 位时，加速比已经达到了 10 倍。

## 生成的汇编：

> objdump -d ./avx > dump.s

我们可以再检查一下生成的汇编指令：

- 使用 bswap 的大小端转换

    ```s
    0000000000001c30 <reverse64_basic>:
        1c30:	f3 0f 1e fa          	endbr64 
        1c34:	48 85 f6             	test   %rsi,%rsi
        1c37:	74 1a                	je     1c53 <reverse64_basic+0x23>
        1c39:	48 8d 14 f7          	lea    (%rdi,%rsi,8),%rdx
        1c3d:	0f 1f 00             	nopl   (%rax)
        1c40:	48 8b 07             	mov    (%rdi),%rax
        1c43:	48 83 c7 08          	add    $0x8,%rdi
        1c47:	48 0f c8             	bswap  %rax
        1c4a:	48 89 47 f8          	mov    %rax,-0x8(%rdi)
        1c4e:	48 39 d7             	cmp    %rdx,%rdi
        1c51:	75 ed                	jne    1c40 <reverse64_basic+0x10>
        1c53:	c3                   	retq   
        1c54:	66 66 2e 0f 1f 84 00 	data16 nopw %cs:0x0(%rax,%rax,1)
    ```

- avx2：vpshufb

    ```s
    0000000000001bb0 <reverse64_avx2>:
    1bb0:	f3 0f 1e fa          	endbr64 
    1bb4:	48 89 f2             	mov    %rsi,%rdx
    1bb7:	48 83 e2 fc          	and    $0xfffffffffffffffc,%rdx
    1bbb:	74 46                	je     1c03 <reverse64_avx2+0x53>
    1bbd:	c5 fd 6f 0d fb 14 00 	vmovdqa 0x14fb(%rip),%ymm1        # 30c0 <_IO_stdin_used+0xc0>
    1bc4:	00 
    1bc5:	48 8d 4a ff          	lea    -0x1(%rdx),%rcx
    1bc9:	48 89 f8             	mov    %rdi,%rax
    1bcc:	48 8d 14 d7          	lea    (%rdi,%rdx,8),%rdx
    1bd0:	c5 fa 6f 10          	vmovdqu (%rax),%xmm2
    1bd4:	c4 e3 6d 38 40 10 01 	vinserti128 $0x1,0x10(%rax),%ymm2,%ymm0
    1bdb:	48 83 c0 20          	add    $0x20,%rax
    1bdf:	c4 e2 7d 00 c1       	vpshufb %ymm1,%ymm0,%ymm0
    1be4:	c5 fa 7f 40 e0       	vmovdqu %xmm0,-0x20(%rax)
    1be9:	c4 e3 7d 39 40 f0 01 	vextracti128 $0x1,%ymm0,-0x10(%rax)
    1bf0:	48 39 d0             	cmp    %rdx,%rax
    1bf3:	75 db                	jne    1bd0 <reverse64_avx2+0x20>
    1bf5:	48 83 e1 fc          	and    $0xfffffffffffffffc,%rcx
    1bf9:	48 89 ca             	mov    %rcx,%rdx
    1bfc:	48 83 c2 04          	add    $0x4,%rdx
    1c00:	c5 f8 77             	vzeroupper 
    1c03:	48 39 d6             	cmp    %rdx,%rsi
    1c06:	76 1b                	jbe    1c23 <reverse64_avx2+0x73>
    1c08:	48 8d 04 d7          	lea    (%rdi,%rdx,8),%rax
    1c0c:	48 8d 0c f7          	lea    (%rdi,%rsi,8),%rcx
    1c10:	48 8b 10             	mov    (%rax),%rdx
    1c13:	48 83 c0 08          	add    $0x8,%rax
    1c17:	48 0f ca             	bswap  %rdx
    1c1a:	48 89 50 f8          	mov    %rdx,-0x8(%rax)
    1c1e:	48 39 c1             	cmp    %rax,%rcx
    1c21:	75 ed                	jne    1c10 <reverse64_avx2+0x60>
    1c23:	c3                   	retq   
    1c24:	66 66 2e 0f 1f 84 00 	data16 nopw %cs:0x0(%rax,%rax,1)
    ```

## 完整源代码，包含性能测试：

- [main.c](main.c)

## 参考资料

- https://github.com/Wunkolo/qreverse
- https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html
