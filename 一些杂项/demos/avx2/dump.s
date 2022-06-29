
./avx:     file format elf64-x86-64


Disassembly of section .init:

0000000000001000 <_init>:
    1000:	f3 0f 1e fa          	endbr64 
    1004:	48 83 ec 08          	sub    $0x8,%rsp
    1008:	48 8b 05 d9 3f 00 00 	mov    0x3fd9(%rip),%rax        # 4fe8 <__gmon_start__>
    100f:	48 85 c0             	test   %rax,%rax
    1012:	74 02                	je     1016 <_init+0x16>
    1014:	ff d0                	callq  *%rax
    1016:	48 83 c4 08          	add    $0x8,%rsp
    101a:	c3                   	retq   

Disassembly of section .plt:

0000000000001020 <.plt>:
    1020:	ff 35 72 3f 00 00    	pushq  0x3f72(%rip)        # 4f98 <_GLOBAL_OFFSET_TABLE_+0x8>
    1026:	f2 ff 25 73 3f 00 00 	bnd jmpq *0x3f73(%rip)        # 4fa0 <_GLOBAL_OFFSET_TABLE_+0x10>
    102d:	0f 1f 00             	nopl   (%rax)
    1030:	f3 0f 1e fa          	endbr64 
    1034:	68 00 00 00 00       	pushq  $0x0
    1039:	f2 e9 e1 ff ff ff    	bnd jmpq 1020 <.plt>
    103f:	90                   	nop
    1040:	f3 0f 1e fa          	endbr64 
    1044:	68 01 00 00 00       	pushq  $0x1
    1049:	f2 e9 d1 ff ff ff    	bnd jmpq 1020 <.plt>
    104f:	90                   	nop
    1050:	f3 0f 1e fa          	endbr64 
    1054:	68 02 00 00 00       	pushq  $0x2
    1059:	f2 e9 c1 ff ff ff    	bnd jmpq 1020 <.plt>
    105f:	90                   	nop
    1060:	f3 0f 1e fa          	endbr64 
    1064:	68 03 00 00 00       	pushq  $0x3
    1069:	f2 e9 b1 ff ff ff    	bnd jmpq 1020 <.plt>
    106f:	90                   	nop
    1070:	f3 0f 1e fa          	endbr64 
    1074:	68 04 00 00 00       	pushq  $0x4
    1079:	f2 e9 a1 ff ff ff    	bnd jmpq 1020 <.plt>
    107f:	90                   	nop
    1080:	f3 0f 1e fa          	endbr64 
    1084:	68 05 00 00 00       	pushq  $0x5
    1089:	f2 e9 91 ff ff ff    	bnd jmpq 1020 <.plt>
    108f:	90                   	nop

Disassembly of section .plt.got:

0000000000001090 <__cxa_finalize@plt>:
    1090:	f3 0f 1e fa          	endbr64 
    1094:	f2 ff 25 5d 3f 00 00 	bnd jmpq *0x3f5d(%rip)        # 4ff8 <__cxa_finalize@GLIBC_2.2.5>
    109b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

Disassembly of section .plt.sec:

00000000000010a0 <putchar@plt>:
    10a0:	f3 0f 1e fa          	endbr64 
    10a4:	f2 ff 25 fd 3e 00 00 	bnd jmpq *0x3efd(%rip)        # 4fa8 <putchar@GLIBC_2.2.5>
    10ab:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

00000000000010b0 <puts@plt>:
    10b0:	f3 0f 1e fa          	endbr64 
    10b4:	f2 ff 25 f5 3e 00 00 	bnd jmpq *0x3ef5(%rip)        # 4fb0 <puts@GLIBC_2.2.5>
    10bb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

00000000000010c0 <clock_gettime@plt>:
    10c0:	f3 0f 1e fa          	endbr64 
    10c4:	f2 ff 25 ed 3e 00 00 	bnd jmpq *0x3eed(%rip)        # 4fb8 <clock_gettime@GLIBC_2.17>
    10cb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

00000000000010d0 <__stack_chk_fail@plt>:
    10d0:	f3 0f 1e fa          	endbr64 
    10d4:	f2 ff 25 e5 3e 00 00 	bnd jmpq *0x3ee5(%rip)        # 4fc0 <__stack_chk_fail@GLIBC_2.4>
    10db:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

00000000000010e0 <memcmp@plt>:
    10e0:	f3 0f 1e fa          	endbr64 
    10e4:	f2 ff 25 dd 3e 00 00 	bnd jmpq *0x3edd(%rip)        # 4fc8 <memcmp@GLIBC_2.2.5>
    10eb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

00000000000010f0 <__printf_chk@plt>:
    10f0:	f3 0f 1e fa          	endbr64 
    10f4:	f2 ff 25 d5 3e 00 00 	bnd jmpq *0x3ed5(%rip)        # 4fd0 <__printf_chk@GLIBC_2.3.4>
    10fb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

Disassembly of section .text:

0000000000001100 <main>:
    1100:	f3 0f 1e fa          	endbr64 
    1104:	4c 8d 54 24 08       	lea    0x8(%rsp),%r10
    1109:	48 83 e4 e0          	and    $0xffffffffffffffe0,%rsp
    110d:	41 ff 72 f8          	pushq  -0x8(%r10)
    1111:	55                   	push   %rbp
    1112:	48 89 e5             	mov    %rsp,%rbp
    1115:	41 57                	push   %r15
    1117:	41 56                	push   %r14
    1119:	41 55                	push   %r13
    111b:	41 54                	push   %r12
    111d:	41 52                	push   %r10
    111f:	53                   	push   %rbx
    1120:	48 83 ec 40          	sub    $0x40,%rsp
    1124:	c5 fd 6f 15 94 1f 00 	vmovdqa 0x1f94(%rip),%ymm2        # 30c0 <_IO_stdin_used+0xc0>
    112b:	00 
    112c:	64 48 8b 04 25 28 00 	mov    %fs:0x28,%rax
    1133:	00 00 
    1135:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    1139:	31 c0                	xor    %eax,%eax
    113b:	c7 45 b0 10 27 00 00 	movl   $0x2710,-0x50(%rbp)
    1142:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    1148:	49 89 e7             	mov    %rsp,%r15
    114b:	4c 39 fc             	cmp    %r15,%rsp
    114e:	74 15                	je     1165 <main+0x65>
    1150:	48 81 ec 00 10 00 00 	sub    $0x1000,%rsp
    1157:	48 83 8c 24 f8 0f 00 	orq    $0x0,0xff8(%rsp)
    115e:	00 00 
    1160:	4c 39 fc             	cmp    %r15,%rsp
    1163:	75 eb                	jne    1150 <main+0x50>
    1165:	48 81 ec 20 03 00 00 	sub    $0x320,%rsp
    116c:	48 83 8c 24 18 03 00 	orq    $0x0,0x318(%rsp)
    1173:	00 00 
    1175:	48 89 e1             	mov    %rsp,%rcx
    1178:	48 39 cc             	cmp    %rcx,%rsp
    117b:	74 15                	je     1192 <main+0x92>
    117d:	48 81 ec 00 10 00 00 	sub    $0x1000,%rsp
    1184:	48 83 8c 24 f8 0f 00 	orq    $0x0,0xff8(%rsp)
    118b:	00 00 
    118d:	48 39 cc             	cmp    %rcx,%rsp
    1190:	75 eb                	jne    117d <main+0x7d>
    1192:	48 81 ec 20 03 00 00 	sub    $0x320,%rsp
    1199:	48 83 8c 24 18 03 00 	orq    $0x0,0x318(%rsp)
    11a0:	00 00 
    11a2:	48 89 e7             	mov    %rsp,%rdi
    11a5:	48 39 fc             	cmp    %rdi,%rsp
    11a8:	74 15                	je     11bf <main+0xbf>
    11aa:	48 81 ec 00 10 00 00 	sub    $0x1000,%rsp
    11b1:	48 83 8c 24 f8 0f 00 	orq    $0x0,0xff8(%rsp)
    11b8:	00 00 
    11ba:	48 39 fc             	cmp    %rdi,%rsp
    11bd:	75 eb                	jne    11aa <main+0xaa>
    11bf:	48 81 ec 20 03 00 00 	sub    $0x320,%rsp
    11c6:	48 83 8c 24 18 03 00 	orq    $0x0,0x318(%rsp)
    11cd:	00 00 
    11cf:	31 c0                	xor    %eax,%eax
    11d1:	48 89 e6             	mov    %rsp,%rsi
    11d4:	0f 1f 40 00          	nopl   0x0(%rax)
    11d8:	88 04 01             	mov    %al,(%rcx,%rax,1)
    11db:	88 04 06             	mov    %al,(%rsi,%rax,1)
    11de:	88 04 07             	mov    %al,(%rdi,%rax,1)
    11e1:	48 83 c0 01          	add    $0x1,%rax
    11e5:	48 3d 20 03 00 00    	cmp    $0x320,%rax
    11eb:	75 eb                	jne    11d8 <main+0xd8>
    11ed:	49 89 f5             	mov    %rsi,%r13
    11f0:	48 8d 9e 20 03 00 00 	lea    0x320(%rsi),%rbx
    11f7:	48 89 f0             	mov    %rsi,%rax
    11fa:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    1200:	c5 fa 6f 18          	vmovdqu (%rax),%xmm3
    1204:	c4 e3 65 38 40 10 01 	vinserti128 $0x1,0x10(%rax),%ymm3,%ymm0
    120b:	48 83 c0 20          	add    $0x20,%rax
    120f:	c4 e2 7d 00 c2       	vpshufb %ymm2,%ymm0,%ymm0
    1214:	c5 fa 7f 40 e0       	vmovdqu %xmm0,-0x20(%rax)
    1219:	c4 e3 7d 39 40 f0 01 	vextracti128 $0x1,%ymm0,-0x10(%rax)
    1220:	48 39 c3             	cmp    %rax,%rbx
    1223:	75 db                	jne    1200 <main+0x100>
    1225:	49 89 fe             	mov    %rdi,%r14
    1228:	4c 8d a7 20 03 00 00 	lea    0x320(%rdi),%r12
    122f:	48 89 f8             	mov    %rdi,%rax
    1232:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    1238:	48 8b 10             	mov    (%rax),%rdx
    123b:	48 83 c0 08          	add    $0x8,%rax
    123f:	48 0f ca             	bswap  %rdx
    1242:	48 89 50 f8          	mov    %rdx,-0x8(%rax)
    1246:	49 39 c4             	cmp    %rax,%r12
    1249:	75 ed                	jne    1238 <main+0x138>
    124b:	ba 20 03 00 00       	mov    $0x320,%edx
    1250:	48 89 4d b8          	mov    %rcx,-0x48(%rbp)
    1254:	c5 f8 77             	vzeroupper 
    1257:	e8 84 fe ff ff       	callq  10e0 <memcmp@plt>
    125c:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
    1260:	85 c0                	test   %eax,%eax
    1262:	0f 85 60 03 00 00    	jne    15c8 <main+0x4c8>
    1268:	4c 89 fc             	mov    %r15,%rsp
    126b:	c5 fd 6f 0d 6d 1e 00 	vmovdqa 0x1e6d(%rip),%ymm1        # 30e0 <_IO_stdin_used+0xe0>
    1272:	00 
    1273:	4c 39 fc             	cmp    %r15,%rsp
    1276:	74 15                	je     128d <main+0x18d>
    1278:	48 81 ec 00 10 00 00 	sub    $0x1000,%rsp
    127f:	48 83 8c 24 f8 0f 00 	orq    $0x0,0xff8(%rsp)
    1286:	00 00 
    1288:	4c 39 fc             	cmp    %r15,%rsp
    128b:	75 eb                	jne    1278 <main+0x178>
    128d:	48 81 ec 20 03 00 00 	sub    $0x320,%rsp
    1294:	48 83 8c 24 18 03 00 	orq    $0x0,0x318(%rsp)
    129b:	00 00 
    129d:	49 89 e5             	mov    %rsp,%r13
    12a0:	4c 39 ec             	cmp    %r13,%rsp
    12a3:	74 15                	je     12ba <main+0x1ba>
    12a5:	48 81 ec 00 10 00 00 	sub    $0x1000,%rsp
    12ac:	48 83 8c 24 f8 0f 00 	orq    $0x0,0xff8(%rsp)
    12b3:	00 00 
    12b5:	4c 39 ec             	cmp    %r13,%rsp
    12b8:	75 eb                	jne    12a5 <main+0x1a5>
    12ba:	48 81 ec 20 03 00 00 	sub    $0x320,%rsp
    12c1:	48 83 8c 24 18 03 00 	orq    $0x0,0x318(%rsp)
    12c8:	00 00 
    12ca:	49 89 e6             	mov    %rsp,%r14
    12cd:	4c 39 f4             	cmp    %r14,%rsp
    12d0:	74 15                	je     12e7 <main+0x1e7>
    12d2:	48 81 ec 00 10 00 00 	sub    $0x1000,%rsp
    12d9:	48 83 8c 24 f8 0f 00 	orq    $0x0,0xff8(%rsp)
    12e0:	00 00 
    12e2:	4c 39 f4             	cmp    %r14,%rsp
    12e5:	75 eb                	jne    12d2 <main+0x1d2>
    12e7:	48 81 ec 20 03 00 00 	sub    $0x320,%rsp
    12ee:	48 83 8c 24 18 03 00 	orq    $0x0,0x318(%rsp)
    12f5:	00 00 
    12f7:	31 c0                	xor    %eax,%eax
    12f9:	48 89 e3             	mov    %rsp,%rbx
    12fc:	0f 1f 40 00          	nopl   0x0(%rax)
    1300:	41 88 44 05 00       	mov    %al,0x0(%r13,%rax,1)
    1305:	88 04 03             	mov    %al,(%rbx,%rax,1)
    1308:	41 88 04 06          	mov    %al,(%r14,%rax,1)
    130c:	48 83 c0 01          	add    $0x1,%rax
    1310:	48 3d 20 03 00 00    	cmp    $0x320,%rax
    1316:	75 e8                	jne    1300 <main+0x200>
    1318:	c5 fa 6f 23          	vmovdqu (%rbx),%xmm4
    131c:	c4 e3 5d 38 43 10 01 	vinserti128 $0x1,0x10(%rbx),%ymm4,%ymm0
    1323:	4d 89 f4             	mov    %r14,%r12
    1326:	49 8d b6 90 01 00 00 	lea    0x190(%r14),%rsi
    132d:	c5 fa 6f 6b 20       	vmovdqu 0x20(%rbx),%xmm5
    1332:	c5 fa 6f 73 40       	vmovdqu 0x40(%rbx),%xmm6
    1337:	c4 e2 7d 00 c1       	vpshufb %ymm1,%ymm0,%ymm0
    133c:	c5 fa 6f 7b 60       	vmovdqu 0x60(%rbx),%xmm7
    1341:	c5 fa 6f a3 80 00 00 	vmovdqu 0x80(%rbx),%xmm4
    1348:	00 
    1349:	c5 fa 7f 03          	vmovdqu %xmm0,(%rbx)
    134d:	c4 e3 7d 39 43 10 01 	vextracti128 $0x1,%ymm0,0x10(%rbx)
    1354:	c4 e3 55 38 43 30 01 	vinserti128 $0x1,0x30(%rbx),%ymm5,%ymm0
    135b:	c5 fa 6f ab a0 00 00 	vmovdqu 0xa0(%rbx),%xmm5
    1362:	00 
    1363:	c4 e2 7d 00 c1       	vpshufb %ymm1,%ymm0,%ymm0
    1368:	c5 fa 7f 43 20       	vmovdqu %xmm0,0x20(%rbx)
    136d:	c4 e3 7d 39 43 30 01 	vextracti128 $0x1,%ymm0,0x30(%rbx)
    1374:	c4 e3 4d 38 43 50 01 	vinserti128 $0x1,0x50(%rbx),%ymm6,%ymm0
    137b:	c5 fa 6f b3 c0 00 00 	vmovdqu 0xc0(%rbx),%xmm6
    1382:	00 
    1383:	c4 e2 7d 00 c1       	vpshufb %ymm1,%ymm0,%ymm0
    1388:	c5 fa 7f 43 40       	vmovdqu %xmm0,0x40(%rbx)
    138d:	c4 e3 7d 39 43 50 01 	vextracti128 $0x1,%ymm0,0x50(%rbx)
    1394:	c4 e3 45 38 43 70 01 	vinserti128 $0x1,0x70(%rbx),%ymm7,%ymm0
    139b:	c5 fa 6f bb e0 00 00 	vmovdqu 0xe0(%rbx),%xmm7
    13a2:	00 
    13a3:	c4 e2 7d 00 c1       	vpshufb %ymm1,%ymm0,%ymm0
    13a8:	c5 fa 7f 43 60       	vmovdqu %xmm0,0x60(%rbx)
    13ad:	c4 e3 7d 39 43 70 01 	vextracti128 $0x1,%ymm0,0x70(%rbx)
    13b4:	c4 e3 5d 38 83 90 00 	vinserti128 $0x1,0x90(%rbx),%ymm4,%ymm0
    13bb:	00 00 01 
    13be:	c4 e2 7d 00 c1       	vpshufb %ymm1,%ymm0,%ymm0
    13c3:	c5 fa 7f 83 80 00 00 	vmovdqu %xmm0,0x80(%rbx)
    13ca:	00 
    13cb:	c4 e3 7d 39 83 90 00 	vextracti128 $0x1,%ymm0,0x90(%rbx)
    13d2:	00 00 01 
    13d5:	c4 e3 55 38 83 b0 00 	vinserti128 $0x1,0xb0(%rbx),%ymm5,%ymm0
    13dc:	00 00 01 
    13df:	c4 e2 7d 00 c1       	vpshufb %ymm1,%ymm0,%ymm0
    13e4:	c5 fa 7f 83 a0 00 00 	vmovdqu %xmm0,0xa0(%rbx)
    13eb:	00 
    13ec:	c4 e3 7d 39 83 b0 00 	vextracti128 $0x1,%ymm0,0xb0(%rbx)
    13f3:	00 00 01 
    13f6:	c4 e3 4d 38 83 d0 00 	vinserti128 $0x1,0xd0(%rbx),%ymm6,%ymm0
    13fd:	00 00 01 
    1400:	c4 e2 7d 00 c1       	vpshufb %ymm1,%ymm0,%ymm0
    1405:	c5 fa 7f 83 c0 00 00 	vmovdqu %xmm0,0xc0(%rbx)
    140c:	00 
    140d:	c4 e3 7d 39 83 d0 00 	vextracti128 $0x1,%ymm0,0xd0(%rbx)
    1414:	00 00 01 
    1417:	c4 e3 45 38 83 f0 00 	vinserti128 $0x1,0xf0(%rbx),%ymm7,%ymm0
    141e:	00 00 01 
    1421:	c4 e2 7d 00 c1       	vpshufb %ymm1,%ymm0,%ymm0
    1426:	c5 fa 7f 83 e0 00 00 	vmovdqu %xmm0,0xe0(%rbx)
    142d:	00 
    142e:	c4 e3 7d 39 83 f0 00 	vextracti128 $0x1,%ymm0,0xf0(%rbx)
    1435:	00 00 01 
    1438:	c5 fa 6f a3 00 01 00 	vmovdqu 0x100(%rbx),%xmm4
    143f:	00 
    1440:	8b 83 80 01 00 00    	mov    0x180(%rbx),%eax
    1446:	c5 fa 6f ab 20 01 00 	vmovdqu 0x120(%rbx),%xmm5
    144d:	00 
    144e:	c5 fa 6f b3 40 01 00 	vmovdqu 0x140(%rbx),%xmm6
    1455:	00 
    1456:	c4 e3 5d 38 83 10 01 	vinserti128 $0x1,0x110(%rbx),%ymm4,%ymm0
    145d:	00 00 01 
    1460:	0f c8                	bswap  %eax
    1462:	89 83 80 01 00 00    	mov    %eax,0x180(%rbx)
    1468:	8b 83 84 01 00 00    	mov    0x184(%rbx),%eax
    146e:	c5 fa 6f bb 60 01 00 	vmovdqu 0x160(%rbx),%xmm7
    1475:	00 
    1476:	c4 e2 7d 00 c1       	vpshufb %ymm1,%ymm0,%ymm0
    147b:	c5 fa 7f 83 00 01 00 	vmovdqu %xmm0,0x100(%rbx)
    1482:	00 
    1483:	0f c8                	bswap  %eax
    1485:	c4 e3 7d 39 83 10 01 	vextracti128 $0x1,%ymm0,0x110(%rbx)
    148c:	00 00 01 
    148f:	c4 e3 55 38 83 30 01 	vinserti128 $0x1,0x130(%rbx),%ymm5,%ymm0
    1496:	00 00 01 
    1499:	89 83 84 01 00 00    	mov    %eax,0x184(%rbx)
    149f:	8b 83 88 01 00 00    	mov    0x188(%rbx),%eax
    14a5:	c4 e2 7d 00 c1       	vpshufb %ymm1,%ymm0,%ymm0
    14aa:	c5 fa 7f 83 20 01 00 	vmovdqu %xmm0,0x120(%rbx)
    14b1:	00 
    14b2:	0f c8                	bswap  %eax
    14b4:	c4 e3 7d 39 83 30 01 	vextracti128 $0x1,%ymm0,0x130(%rbx)
    14bb:	00 00 01 
    14be:	c4 e3 4d 38 83 50 01 	vinserti128 $0x1,0x150(%rbx),%ymm6,%ymm0
    14c5:	00 00 01 
    14c8:	89 83 88 01 00 00    	mov    %eax,0x188(%rbx)
    14ce:	8b 83 8c 01 00 00    	mov    0x18c(%rbx),%eax
    14d4:	c4 e2 7d 00 c1       	vpshufb %ymm1,%ymm0,%ymm0
    14d9:	c5 fa 7f 83 40 01 00 	vmovdqu %xmm0,0x140(%rbx)
    14e0:	00 
    14e1:	0f c8                	bswap  %eax
    14e3:	c4 e3 7d 39 83 50 01 	vextracti128 $0x1,%ymm0,0x150(%rbx)
    14ea:	00 00 01 
    14ed:	c4 e3 45 38 83 70 01 	vinserti128 $0x1,0x170(%rbx),%ymm7,%ymm0
    14f4:	00 00 01 
    14f7:	89 83 8c 01 00 00    	mov    %eax,0x18c(%rbx)
    14fd:	4c 89 f0             	mov    %r14,%rax
    1500:	c4 e2 7d 00 c1       	vpshufb %ymm1,%ymm0,%ymm0
    1505:	c5 fa 7f 83 60 01 00 	vmovdqu %xmm0,0x160(%rbx)
    150c:	00 
    150d:	c4 e3 7d 39 83 70 01 	vextracti128 $0x1,%ymm0,0x170(%rbx)
    1514:	00 00 01 
    1517:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    151e:	00 00 
    1520:	8b 10                	mov    (%rax),%edx
    1522:	48 83 c0 04          	add    $0x4,%rax
    1526:	0f ca                	bswap  %edx
    1528:	89 50 fc             	mov    %edx,-0x4(%rax)
    152b:	48 39 f0             	cmp    %rsi,%rax
    152e:	75 f0                	jne    1520 <main+0x420>
    1530:	ba 20 03 00 00       	mov    $0x320,%edx
    1535:	48 89 de             	mov    %rbx,%rsi
    1538:	4c 89 f7             	mov    %r14,%rdi
    153b:	c5 f8 77             	vzeroupper 
    153e:	e8 9d fb ff ff       	callq  10e0 <memcmp@plt>
    1543:	85 c0                	test   %eax,%eax
    1545:	0f 85 75 01 00 00    	jne    16c0 <main+0x5c0>
    154b:	4c 89 fc             	mov    %r15,%rsp
    154e:	4c 39 fc             	cmp    %r15,%rsp
    1551:	74 15                	je     1568 <main+0x468>
    1553:	48 81 ec 00 10 00 00 	sub    $0x1000,%rsp
    155a:	48 83 8c 24 f8 0f 00 	orq    $0x0,0xff8(%rsp)
    1561:	00 00 
    1563:	4c 39 fc             	cmp    %r15,%rsp
    1566:	75 eb                	jne    1553 <main+0x453>
    1568:	48 81 ec 20 03 00 00 	sub    $0x320,%rsp
    156f:	48 83 8c 24 18 03 00 	orq    $0x0,0x318(%rsp)
    1576:	00 00 
    1578:	49 89 e5             	mov    %rsp,%r13
    157b:	4c 39 ec             	cmp    %r13,%rsp
    157e:	74 15                	je     1595 <main+0x495>
    1580:	48 81 ec 00 10 00 00 	sub    $0x1000,%rsp
    1587:	48 83 8c 24 f8 0f 00 	orq    $0x0,0xff8(%rsp)
    158e:	00 00 
    1590:	4c 39 ec             	cmp    %r13,%rsp
    1593:	75 eb                	jne    1580 <main+0x480>
    1595:	48 81 ec 20 03 00 00 	sub    $0x320,%rsp
    159c:	48 83 8c 24 18 03 00 	orq    $0x0,0x318(%rsp)
    15a3:	00 00 
    15a5:	49 89 e6             	mov    %rsp,%r14
    15a8:	4c 39 f4             	cmp    %r14,%rsp
    15ab:	0f 84 c7 01 00 00    	je     1778 <main+0x678>
    15b1:	48 81 ec 00 10 00 00 	sub    $0x1000,%rsp
    15b8:	48 83 8c 24 f8 0f 00 	orq    $0x0,0xff8(%rsp)
    15bf:	00 00 
    15c1:	eb e5                	jmp    15a8 <main+0x4a8>
    15c3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    15c8:	48 8d 3d 39 1a 00 00 	lea    0x1a39(%rip),%rdi        # 3008 <_IO_stdin_used+0x8>
    15cf:	48 89 4d b8          	mov    %rcx,-0x48(%rbp)
    15d3:	e8 d8 fa ff ff       	callq  10b0 <puts@plt>
    15d8:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
    15dc:	48 8d 81 20 03 00 00 	lea    0x320(%rcx),%rax
    15e3:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
    15e7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    15ee:	00 00 
    15f0:	0f be 11             	movsbl (%rcx),%edx
    15f3:	48 8d 35 0a 1a 00 00 	lea    0x1a0a(%rip),%rsi        # 3004 <_IO_stdin_used+0x4>
    15fa:	31 c0                	xor    %eax,%eax
    15fc:	48 89 4d b8          	mov    %rcx,-0x48(%rbp)
    1600:	bf 01 00 00 00       	mov    $0x1,%edi
    1605:	e8 e6 fa ff ff       	callq  10f0 <__printf_chk@plt>
    160a:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
    160e:	48 83 c1 01          	add    $0x1,%rcx
    1612:	48 39 4d b0          	cmp    %rcx,-0x50(%rbp)
    1616:	75 d8                	jne    15f0 <main+0x4f0>
    1618:	bf 0a 00 00 00       	mov    $0xa,%edi
    161d:	e8 7e fa ff ff       	callq  10a0 <putchar@plt>
    1622:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    1628:	41 0f be 16          	movsbl (%r14),%edx
    162c:	bf 01 00 00 00       	mov    $0x1,%edi
    1631:	31 c0                	xor    %eax,%eax
    1633:	49 83 c6 01          	add    $0x1,%r14
    1637:	48 8d 35 c6 19 00 00 	lea    0x19c6(%rip),%rsi        # 3004 <_IO_stdin_used+0x4>
    163e:	e8 ad fa ff ff       	callq  10f0 <__printf_chk@plt>
    1643:	4d 39 e6             	cmp    %r12,%r14
    1646:	75 e0                	jne    1628 <main+0x528>
    1648:	bf 0a 00 00 00       	mov    $0xa,%edi
    164d:	4c 8d 25 b0 19 00 00 	lea    0x19b0(%rip),%r12        # 3004 <_IO_stdin_used+0x4>
    1654:	e8 47 fa ff ff       	callq  10a0 <putchar@plt>
    1659:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    1660:	41 0f be 55 00       	movsbl 0x0(%r13),%edx
    1665:	4c 89 e6             	mov    %r12,%rsi
    1668:	bf 01 00 00 00       	mov    $0x1,%edi
    166d:	31 c0                	xor    %eax,%eax
    166f:	49 83 c5 01          	add    $0x1,%r13
    1673:	e8 78 fa ff ff       	callq  10f0 <__printf_chk@plt>
    1678:	4c 39 eb             	cmp    %r13,%rbx
    167b:	75 e3                	jne    1660 <main+0x560>
    167d:	bf 0a 00 00 00       	mov    $0xa,%edi
    1682:	e8 19 fa ff ff       	callq  10a0 <putchar@plt>
    1687:	41 bb 01 00 00 00    	mov    $0x1,%r11d
    168d:	4c 89 fc             	mov    %r15,%rsp
    1690:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
    1694:	64 48 2b 04 25 28 00 	sub    %fs:0x28,%rax
    169b:	00 00 
    169d:	0f 85 0d 04 00 00    	jne    1ab0 <main+0x9b0>
    16a3:	48 8d 65 d0          	lea    -0x30(%rbp),%rsp
    16a7:	44 89 d8             	mov    %r11d,%eax
    16aa:	5b                   	pop    %rbx
    16ab:	41 5a                	pop    %r10
    16ad:	41 5c                	pop    %r12
    16af:	41 5d                	pop    %r13
    16b1:	41 5e                	pop    %r14
    16b3:	41 5f                	pop    %r15
    16b5:	5d                   	pop    %rbp
    16b6:	49 8d 62 f8          	lea    -0x8(%r10),%rsp
    16ba:	c3                   	retq   
    16bb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    16c0:	48 8d 3d 41 19 00 00 	lea    0x1941(%rip),%rdi        # 3008 <_IO_stdin_used+0x8>
    16c7:	e8 e4 f9 ff ff       	callq  10b0 <puts@plt>
    16cc:	49 8d 85 20 03 00 00 	lea    0x320(%r13),%rax
    16d3:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    16d7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    16de:	00 00 
    16e0:	41 0f be 55 00       	movsbl 0x0(%r13),%edx
    16e5:	bf 01 00 00 00       	mov    $0x1,%edi
    16ea:	31 c0                	xor    %eax,%eax
    16ec:	49 83 c5 01          	add    $0x1,%r13
    16f0:	48 8d 35 0d 19 00 00 	lea    0x190d(%rip),%rsi        # 3004 <_IO_stdin_used+0x4>
    16f7:	e8 f4 f9 ff ff       	callq  10f0 <__printf_chk@plt>
    16fc:	4c 39 6d b8          	cmp    %r13,-0x48(%rbp)
    1700:	75 de                	jne    16e0 <main+0x5e0>
    1702:	bf 0a 00 00 00       	mov    $0xa,%edi
    1707:	49 81 c6 20 03 00 00 	add    $0x320,%r14
    170e:	4c 8d 2d ef 18 00 00 	lea    0x18ef(%rip),%r13        # 3004 <_IO_stdin_used+0x4>
    1715:	e8 86 f9 ff ff       	callq  10a0 <putchar@plt>
    171a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    1720:	41 0f be 14 24       	movsbl (%r12),%edx
    1725:	4c 89 ee             	mov    %r13,%rsi
    1728:	bf 01 00 00 00       	mov    $0x1,%edi
    172d:	31 c0                	xor    %eax,%eax
    172f:	49 83 c4 01          	add    $0x1,%r12
    1733:	e8 b8 f9 ff ff       	callq  10f0 <__printf_chk@plt>
    1738:	4d 39 e6             	cmp    %r12,%r14
    173b:	75 e3                	jne    1720 <main+0x620>
    173d:	bf 0a 00 00 00       	mov    $0xa,%edi
    1742:	4c 8d ab 20 03 00 00 	lea    0x320(%rbx),%r13
    1749:	4c 8d 25 b4 18 00 00 	lea    0x18b4(%rip),%r12        # 3004 <_IO_stdin_used+0x4>
    1750:	e8 4b f9 ff ff       	callq  10a0 <putchar@plt>
    1755:	0f 1f 00             	nopl   (%rax)
    1758:	0f be 13             	movsbl (%rbx),%edx
    175b:	4c 89 e6             	mov    %r12,%rsi
    175e:	bf 01 00 00 00       	mov    $0x1,%edi
    1763:	31 c0                	xor    %eax,%eax
    1765:	48 83 c3 01          	add    $0x1,%rbx
    1769:	e8 82 f9 ff ff       	callq  10f0 <__printf_chk@plt>
    176e:	49 39 dd             	cmp    %rbx,%r13
    1771:	75 e5                	jne    1758 <main+0x658>
    1773:	e9 05 ff ff ff       	jmpq   167d <main+0x57d>
    1778:	48 81 ec 20 03 00 00 	sub    $0x320,%rsp
    177f:	48 83 8c 24 18 03 00 	orq    $0x0,0x318(%rsp)
    1786:	00 00 
    1788:	31 c0                	xor    %eax,%eax
    178a:	48 89 e3             	mov    %rsp,%rbx
    178d:	0f 1f 00             	nopl   (%rax)
    1790:	41 88 44 05 00       	mov    %al,0x0(%r13,%rax,1)
    1795:	88 04 03             	mov    %al,(%rbx,%rax,1)
    1798:	41 88 04 06          	mov    %al,(%r14,%rax,1)
    179c:	48 83 c0 01          	add    $0x1,%rax
    17a0:	48 3d 20 03 00 00    	cmp    $0x320,%rax
    17a6:	75 e8                	jne    1790 <main+0x690>
    17a8:	c5 fa 6f 23          	vmovdqu (%rbx),%xmm4
    17ac:	c5 fa 6f 6b 20       	vmovdqu 0x20(%rbx),%xmm5
    17b1:	4d 89 f4             	mov    %r14,%r12
    17b4:	4c 89 f0             	mov    %r14,%rax
    17b7:	c4 e3 5d 38 43 10 01 	vinserti128 $0x1,0x10(%rbx),%ymm4,%ymm0
    17be:	c5 fa 6f 73 40       	vmovdqu 0x40(%rbx),%xmm6
    17c3:	66 c1 83 c0 00 00 00 	rolw   $0x8,0xc0(%rbx)
    17ca:	08 
    17cb:	49 8d 96 c8 00 00 00 	lea    0xc8(%r14),%rdx
    17d2:	c5 fa 6f 7b 60       	vmovdqu 0x60(%rbx),%xmm7
    17d7:	c5 fa 6f a3 80 00 00 	vmovdqu 0x80(%rbx),%xmm4
    17de:	00 
    17df:	c4 e2 7d 00 05 18 19 	vpshufb 0x1918(%rip),%ymm0,%ymm0        # 3100 <_IO_stdin_used+0x100>
    17e6:	00 00 
    17e8:	c5 fa 7f 03          	vmovdqu %xmm0,(%rbx)
    17ec:	c4 e3 7d 39 43 10 01 	vextracti128 $0x1,%ymm0,0x10(%rbx)
    17f3:	c4 e3 55 38 43 30 01 	vinserti128 $0x1,0x30(%rbx),%ymm5,%ymm0
    17fa:	c5 fa 6f ab a0 00 00 	vmovdqu 0xa0(%rbx),%xmm5
    1801:	00 
    1802:	c4 e2 7d 00 05 f5 18 	vpshufb 0x18f5(%rip),%ymm0,%ymm0        # 3100 <_IO_stdin_used+0x100>
    1809:	00 00 
    180b:	c5 fa 7f 43 20       	vmovdqu %xmm0,0x20(%rbx)
    1810:	c4 e3 7d 39 43 30 01 	vextracti128 $0x1,%ymm0,0x30(%rbx)
    1817:	c4 e3 4d 38 43 50 01 	vinserti128 $0x1,0x50(%rbx),%ymm6,%ymm0
    181e:	c4 e2 7d 00 05 d9 18 	vpshufb 0x18d9(%rip),%ymm0,%ymm0        # 3100 <_IO_stdin_used+0x100>
    1825:	00 00 
    1827:	c5 fa 7f 43 40       	vmovdqu %xmm0,0x40(%rbx)
    182c:	c4 e3 7d 39 43 50 01 	vextracti128 $0x1,%ymm0,0x50(%rbx)
    1833:	c4 e3 45 38 43 70 01 	vinserti128 $0x1,0x70(%rbx),%ymm7,%ymm0
    183a:	c4 e2 7d 00 05 bd 18 	vpshufb 0x18bd(%rip),%ymm0,%ymm0        # 3100 <_IO_stdin_used+0x100>
    1841:	00 00 
    1843:	c5 fa 7f 43 60       	vmovdqu %xmm0,0x60(%rbx)
    1848:	c4 e3 7d 39 43 70 01 	vextracti128 $0x1,%ymm0,0x70(%rbx)
    184f:	c4 e3 5d 38 83 90 00 	vinserti128 $0x1,0x90(%rbx),%ymm4,%ymm0
    1856:	00 00 01 
    1859:	c4 e2 7d 00 05 9e 18 	vpshufb 0x189e(%rip),%ymm0,%ymm0        # 3100 <_IO_stdin_used+0x100>
    1860:	00 00 
    1862:	c5 fa 7f 83 80 00 00 	vmovdqu %xmm0,0x80(%rbx)
    1869:	00 
    186a:	c4 e3 7d 39 83 90 00 	vextracti128 $0x1,%ymm0,0x90(%rbx)
    1871:	00 00 01 
    1874:	c4 e3 55 38 83 b0 00 	vinserti128 $0x1,0xb0(%rbx),%ymm5,%ymm0
    187b:	00 00 01 
    187e:	c4 e2 7d 00 05 79 18 	vpshufb 0x1879(%rip),%ymm0,%ymm0        # 3100 <_IO_stdin_used+0x100>
    1885:	00 00 
    1887:	c5 fa 7f 83 a0 00 00 	vmovdqu %xmm0,0xa0(%rbx)
    188e:	00 
    188f:	c4 e3 7d 39 83 b0 00 	vextracti128 $0x1,%ymm0,0xb0(%rbx)
    1896:	00 00 01 
    1899:	66 c1 83 c2 00 00 00 	rolw   $0x8,0xc2(%rbx)
    18a0:	08 
    18a1:	66 c1 83 c4 00 00 00 	rolw   $0x8,0xc4(%rbx)
    18a8:	08 
    18a9:	66 c1 83 c6 00 00 00 	rolw   $0x8,0xc6(%rbx)
    18b0:	08 
    18b1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    18b8:	66 c1 00 08          	rolw   $0x8,(%rax)
    18bc:	48 83 c0 02          	add    $0x2,%rax
    18c0:	48 39 d0             	cmp    %rdx,%rax
    18c3:	75 f3                	jne    18b8 <main+0x7b8>
    18c5:	ba 20 03 00 00       	mov    $0x320,%edx
    18ca:	48 89 de             	mov    %rbx,%rsi
    18cd:	4c 89 f7             	mov    %r14,%rdi
    18d0:	c5 f8 77             	vzeroupper 
    18d3:	e8 08 f8 ff ff       	callq  10e0 <memcmp@plt>
    18d8:	c5 fd 6f 15 e0 17 00 	vmovdqa 0x17e0(%rip),%ymm2        # 30c0 <_IO_stdin_used+0xc0>
    18df:	00 
    18e0:	85 c0                	test   %eax,%eax
    18e2:	0f 85 10 01 00 00    	jne    19f8 <main+0x8f8>
    18e8:	83 6d b0 01          	subl   $0x1,-0x50(%rbp)
    18ec:	4c 89 fc             	mov    %r15,%rsp
    18ef:	0f 85 53 f8 ff ff    	jne    1148 <main+0x48>
    18f5:	48 8d 3d 14 17 00 00 	lea    0x1714(%rip),%rdi        # 3010 <_IO_stdin_used+0x10>
    18fc:	89 45 b8             	mov    %eax,-0x48(%rbp)
    18ff:	c5 f8 77             	vzeroupper 
    1902:	e8 a9 f7 ff ff       	callq  10b0 <puts@plt>
    1907:	44 8b 5d b8          	mov    -0x48(%rbp),%r11d
    190b:	45 31 ed             	xor    %r13d,%r13d
    190e:	48 8d 1d 2b 37 00 00 	lea    0x372b(%rip),%rbx        # 5040 <buffer>
    1915:	0f 1f 00             	nopl   (%rax)
    1918:	44 89 e9             	mov    %r13d,%ecx
    191b:	41 bc 04 00 00 00    	mov    $0x4,%r12d
    1921:	48 89 df             	mov    %rbx,%rdi
    1924:	44 89 5d a4          	mov    %r11d,-0x5c(%rbp)
    1928:	41 d3 e4             	shl    %cl,%r12d
    192b:	48 8d 15 7e 02 00 00 	lea    0x27e(%rip),%rdx        # 1bb0 <reverse64_avx2>
    1932:	41 83 c5 01          	add    $0x1,%r13d
    1936:	4d 63 e4             	movslq %r12d,%r12
    1939:	4c 89 e6             	mov    %r12,%rsi
    193c:	e8 4f 07 00 00       	callq  2090 <bench>
    1941:	48 8d 15 e8 02 00 00 	lea    0x2e8(%rip),%rdx        # 1c30 <reverse64_basic>
    1948:	4c 89 e6             	mov    %r12,%rsi
    194b:	48 89 df             	mov    %rbx,%rdi
    194e:	49 89 c7             	mov    %rax,%r15
    1951:	e8 3a 07 00 00       	callq  2090 <bench>
    1956:	48 8d 15 03 03 00 00 	lea    0x303(%rip),%rdx        # 1c60 <reverse32_avx2>
    195d:	4c 89 e6             	mov    %r12,%rsi
    1960:	48 89 df             	mov    %rbx,%rdi
    1963:	49 89 c6             	mov    %rax,%r14
    1966:	e8 25 07 00 00       	callq  2090 <bench>
    196b:	48 8d 15 6e 03 00 00 	lea    0x36e(%rip),%rdx        # 1ce0 <reverse32_basic>
    1972:	4c 89 e6             	mov    %r12,%rsi
    1975:	48 89 df             	mov    %rbx,%rdi
    1978:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    197c:	e8 0f 07 00 00       	callq  2090 <bench>
    1981:	48 8d 15 88 03 00 00 	lea    0x388(%rip),%rdx        # 1d10 <reverse16_avx2>
    1988:	4c 89 e6             	mov    %r12,%rsi
    198b:	48 89 df             	mov    %rbx,%rdi
    198e:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
    1992:	e8 f9 06 00 00       	callq  2090 <bench>
    1997:	48 8d 15 e2 03 00 00 	lea    0x3e2(%rip),%rdx        # 1d80 <reverse16_basic>
    199e:	4c 89 e6             	mov    %r12,%rsi
    19a1:	48 89 df             	mov    %rbx,%rdi
    19a4:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    19a8:	e8 e3 06 00 00       	callq  2090 <bench>
    19ad:	4c 8b 55 b8          	mov    -0x48(%rbp),%r10
    19b1:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
    19b5:	4d 89 f0             	mov    %r14,%r8
    19b8:	48 83 ec 08          	sub    $0x8,%rsp
    19bc:	4c 8b 4d a8          	mov    -0x58(%rbp),%r9
    19c0:	4c 89 e2             	mov    %r12,%rdx
    19c3:	bf 01 00 00 00       	mov    $0x1,%edi
    19c8:	50                   	push   %rax
    19c9:	48 8d 35 a0 16 00 00 	lea    0x16a0(%rip),%rsi        # 3070 <_IO_stdin_used+0x70>
    19d0:	31 c0                	xor    %eax,%eax
    19d2:	41 52                	push   %r10
    19d4:	51                   	push   %rcx
    19d5:	4c 89 f9             	mov    %r15,%rcx
    19d8:	e8 13 f7 ff ff       	callq  10f0 <__printf_chk@plt>
    19dd:	48 83 c4 20          	add    $0x20,%rsp
    19e1:	41 83 fd 0d          	cmp    $0xd,%r13d
    19e5:	44 8b 5d a4          	mov    -0x5c(%rbp),%r11d
    19e9:	0f 85 29 ff ff ff    	jne    1918 <main+0x818>
    19ef:	e9 9c fc ff ff       	jmpq   1690 <main+0x590>
    19f4:	0f 1f 40 00          	nopl   0x0(%rax)
    19f8:	48 8d 3d 09 16 00 00 	lea    0x1609(%rip),%rdi        # 3008 <_IO_stdin_used+0x8>
    19ff:	c5 f8 77             	vzeroupper 
    1a02:	e8 a9 f6 ff ff       	callq  10b0 <puts@plt>
    1a07:	49 8d 85 20 03 00 00 	lea    0x320(%r13),%rax
    1a0e:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    1a12:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    1a18:	41 0f be 55 00       	movsbl 0x0(%r13),%edx
    1a1d:	bf 01 00 00 00       	mov    $0x1,%edi
    1a22:	31 c0                	xor    %eax,%eax
    1a24:	49 83 c5 01          	add    $0x1,%r13
    1a28:	48 8d 35 d5 15 00 00 	lea    0x15d5(%rip),%rsi        # 3004 <_IO_stdin_used+0x4>
    1a2f:	e8 bc f6 ff ff       	callq  10f0 <__printf_chk@plt>
    1a34:	4c 39 6d b8          	cmp    %r13,-0x48(%rbp)
    1a38:	75 de                	jne    1a18 <main+0x918>
    1a3a:	bf 0a 00 00 00       	mov    $0xa,%edi
    1a3f:	49 81 c6 20 03 00 00 	add    $0x320,%r14
    1a46:	4c 8d 2d b7 15 00 00 	lea    0x15b7(%rip),%r13        # 3004 <_IO_stdin_used+0x4>
    1a4d:	e8 4e f6 ff ff       	callq  10a0 <putchar@plt>
    1a52:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    1a58:	41 0f be 14 24       	movsbl (%r12),%edx
    1a5d:	4c 89 ee             	mov    %r13,%rsi
    1a60:	bf 01 00 00 00       	mov    $0x1,%edi
    1a65:	31 c0                	xor    %eax,%eax
    1a67:	49 83 c4 01          	add    $0x1,%r12
    1a6b:	e8 80 f6 ff ff       	callq  10f0 <__printf_chk@plt>
    1a70:	4d 39 e6             	cmp    %r12,%r14
    1a73:	75 e3                	jne    1a58 <main+0x958>
    1a75:	bf 0a 00 00 00       	mov    $0xa,%edi
    1a7a:	4c 8d ab 20 03 00 00 	lea    0x320(%rbx),%r13
    1a81:	4c 8d 25 7c 15 00 00 	lea    0x157c(%rip),%r12        # 3004 <_IO_stdin_used+0x4>
    1a88:	e8 13 f6 ff ff       	callq  10a0 <putchar@plt>
    1a8d:	0f 1f 00             	nopl   (%rax)
    1a90:	0f be 13             	movsbl (%rbx),%edx
    1a93:	4c 89 e6             	mov    %r12,%rsi
    1a96:	bf 01 00 00 00       	mov    $0x1,%edi
    1a9b:	31 c0                	xor    %eax,%eax
    1a9d:	48 83 c3 01          	add    $0x1,%rbx
    1aa1:	e8 4a f6 ff ff       	callq  10f0 <__printf_chk@plt>
    1aa6:	49 39 dd             	cmp    %rbx,%r13
    1aa9:	75 e5                	jne    1a90 <main+0x990>
    1aab:	e9 cd fb ff ff       	jmpq   167d <main+0x57d>
    1ab0:	e8 1b f6 ff ff       	callq  10d0 <__stack_chk_fail@plt>
    1ab5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
    1abc:	00 00 00 
    1abf:	90                   	nop

0000000000001ac0 <_start>:
    1ac0:	f3 0f 1e fa          	endbr64 
    1ac4:	31 ed                	xor    %ebp,%ebp
    1ac6:	49 89 d1             	mov    %rdx,%r9
    1ac9:	5e                   	pop    %rsi
    1aca:	48 89 e2             	mov    %rsp,%rdx
    1acd:	48 83 e4 f0          	and    $0xfffffffffffffff0,%rsp
    1ad1:	50                   	push   %rax
    1ad2:	54                   	push   %rsp
    1ad3:	4c 8d 05 f6 06 00 00 	lea    0x6f6(%rip),%r8        # 21d0 <__libc_csu_fini>
    1ada:	48 8d 0d 7f 06 00 00 	lea    0x67f(%rip),%rcx        # 2160 <__libc_csu_init>
    1ae1:	48 8d 3d 18 f6 ff ff 	lea    -0x9e8(%rip),%rdi        # 1100 <main>
    1ae8:	ff 15 f2 34 00 00    	callq  *0x34f2(%rip)        # 4fe0 <__libc_start_main@GLIBC_2.2.5>
    1aee:	f4                   	hlt    
    1aef:	90                   	nop

0000000000001af0 <deregister_tm_clones>:
    1af0:	48 8d 3d 19 35 00 00 	lea    0x3519(%rip),%rdi        # 5010 <__TMC_END__>
    1af7:	48 8d 05 12 35 00 00 	lea    0x3512(%rip),%rax        # 5010 <__TMC_END__>
    1afe:	48 39 f8             	cmp    %rdi,%rax
    1b01:	74 15                	je     1b18 <deregister_tm_clones+0x28>
    1b03:	48 8b 05 ce 34 00 00 	mov    0x34ce(%rip),%rax        # 4fd8 <_ITM_deregisterTMCloneTable>
    1b0a:	48 85 c0             	test   %rax,%rax
    1b0d:	74 09                	je     1b18 <deregister_tm_clones+0x28>
    1b0f:	ff e0                	jmpq   *%rax
    1b11:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    1b18:	c3                   	retq   
    1b19:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001b20 <register_tm_clones>:
    1b20:	48 8d 3d e9 34 00 00 	lea    0x34e9(%rip),%rdi        # 5010 <__TMC_END__>
    1b27:	48 8d 35 e2 34 00 00 	lea    0x34e2(%rip),%rsi        # 5010 <__TMC_END__>
    1b2e:	48 29 fe             	sub    %rdi,%rsi
    1b31:	48 89 f0             	mov    %rsi,%rax
    1b34:	48 c1 ee 3f          	shr    $0x3f,%rsi
    1b38:	48 c1 f8 03          	sar    $0x3,%rax
    1b3c:	48 01 c6             	add    %rax,%rsi
    1b3f:	48 d1 fe             	sar    %rsi
    1b42:	74 14                	je     1b58 <register_tm_clones+0x38>
    1b44:	48 8b 05 a5 34 00 00 	mov    0x34a5(%rip),%rax        # 4ff0 <_ITM_registerTMCloneTable>
    1b4b:	48 85 c0             	test   %rax,%rax
    1b4e:	74 08                	je     1b58 <register_tm_clones+0x38>
    1b50:	ff e0                	jmpq   *%rax
    1b52:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    1b58:	c3                   	retq   
    1b59:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001b60 <__do_global_dtors_aux>:
    1b60:	f3 0f 1e fa          	endbr64 
    1b64:	80 3d b5 34 00 00 00 	cmpb   $0x0,0x34b5(%rip)        # 5020 <completed.0>
    1b6b:	75 2b                	jne    1b98 <__do_global_dtors_aux+0x38>
    1b6d:	55                   	push   %rbp
    1b6e:	48 83 3d 82 34 00 00 	cmpq   $0x0,0x3482(%rip)        # 4ff8 <__cxa_finalize@GLIBC_2.2.5>
    1b75:	00 
    1b76:	48 89 e5             	mov    %rsp,%rbp
    1b79:	74 0c                	je     1b87 <__do_global_dtors_aux+0x27>
    1b7b:	48 8b 3d 86 34 00 00 	mov    0x3486(%rip),%rdi        # 5008 <__dso_handle>
    1b82:	e8 09 f5 ff ff       	callq  1090 <__cxa_finalize@plt>
    1b87:	e8 64 ff ff ff       	callq  1af0 <deregister_tm_clones>
    1b8c:	c6 05 8d 34 00 00 01 	movb   $0x1,0x348d(%rip)        # 5020 <completed.0>
    1b93:	5d                   	pop    %rbp
    1b94:	c3                   	retq   
    1b95:	0f 1f 00             	nopl   (%rax)
    1b98:	c3                   	retq   
    1b99:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001ba0 <frame_dummy>:
    1ba0:	f3 0f 1e fa          	endbr64 
    1ba4:	e9 77 ff ff ff       	jmpq   1b20 <register_tm_clones>
    1ba9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

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
    1c2b:	00 00 00 00 
    1c2f:	90                   	nop

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
    1c5b:	00 00 00 00 
    1c5f:	90                   	nop

0000000000001c60 <reverse32_avx2>:
    1c60:	f3 0f 1e fa          	endbr64 
    1c64:	48 89 f2             	mov    %rsi,%rdx
    1c67:	48 83 e2 f8          	and    $0xfffffffffffffff8,%rdx
    1c6b:	74 46                	je     1cb3 <reverse32_avx2+0x53>
    1c6d:	c5 fd 6f 0d 6b 14 00 	vmovdqa 0x146b(%rip),%ymm1        # 30e0 <_IO_stdin_used+0xe0>
    1c74:	00 
    1c75:	48 8d 4a ff          	lea    -0x1(%rdx),%rcx
    1c79:	48 89 f8             	mov    %rdi,%rax
    1c7c:	48 8d 14 97          	lea    (%rdi,%rdx,4),%rdx
    1c80:	c5 fa 6f 10          	vmovdqu (%rax),%xmm2
    1c84:	c4 e3 6d 38 40 10 01 	vinserti128 $0x1,0x10(%rax),%ymm2,%ymm0
    1c8b:	48 83 c0 20          	add    $0x20,%rax
    1c8f:	c4 e2 7d 00 c1       	vpshufb %ymm1,%ymm0,%ymm0
    1c94:	c5 fa 7f 40 e0       	vmovdqu %xmm0,-0x20(%rax)
    1c99:	c4 e3 7d 39 40 f0 01 	vextracti128 $0x1,%ymm0,-0x10(%rax)
    1ca0:	48 39 d0             	cmp    %rdx,%rax
    1ca3:	75 db                	jne    1c80 <reverse32_avx2+0x20>
    1ca5:	48 83 e1 f8          	and    $0xfffffffffffffff8,%rcx
    1ca9:	48 89 ca             	mov    %rcx,%rdx
    1cac:	48 83 c2 08          	add    $0x8,%rdx
    1cb0:	c5 f8 77             	vzeroupper 
    1cb3:	48 39 d6             	cmp    %rdx,%rsi
    1cb6:	76 18                	jbe    1cd0 <reverse32_avx2+0x70>
    1cb8:	48 8d 04 97          	lea    (%rdi,%rdx,4),%rax
    1cbc:	48 8d 0c b7          	lea    (%rdi,%rsi,4),%rcx
    1cc0:	8b 10                	mov    (%rax),%edx
    1cc2:	48 83 c0 04          	add    $0x4,%rax
    1cc6:	0f ca                	bswap  %edx
    1cc8:	89 50 fc             	mov    %edx,-0x4(%rax)
    1ccb:	48 39 c1             	cmp    %rax,%rcx
    1cce:	75 f0                	jne    1cc0 <reverse32_avx2+0x60>
    1cd0:	c3                   	retq   
    1cd1:	66 66 2e 0f 1f 84 00 	data16 nopw %cs:0x0(%rax,%rax,1)
    1cd8:	00 00 00 00 
    1cdc:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000001ce0 <reverse32_basic>:
    1ce0:	f3 0f 1e fa          	endbr64 
    1ce4:	48 85 f6             	test   %rsi,%rsi
    1ce7:	74 17                	je     1d00 <reverse32_basic+0x20>
    1ce9:	48 8d 14 b7          	lea    (%rdi,%rsi,4),%rdx
    1ced:	0f 1f 00             	nopl   (%rax)
    1cf0:	8b 07                	mov    (%rdi),%eax
    1cf2:	48 83 c7 04          	add    $0x4,%rdi
    1cf6:	0f c8                	bswap  %eax
    1cf8:	89 47 fc             	mov    %eax,-0x4(%rdi)
    1cfb:	48 39 d7             	cmp    %rdx,%rdi
    1cfe:	75 f0                	jne    1cf0 <reverse32_basic+0x10>
    1d00:	c3                   	retq   
    1d01:	66 66 2e 0f 1f 84 00 	data16 nopw %cs:0x0(%rax,%rax,1)
    1d08:	00 00 00 00 
    1d0c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000001d10 <reverse16_avx2>:
    1d10:	f3 0f 1e fa          	endbr64 
    1d14:	48 89 f2             	mov    %rsi,%rdx
    1d17:	48 83 e2 f0          	and    $0xfffffffffffffff0,%rdx
    1d1b:	74 46                	je     1d63 <reverse16_avx2+0x53>
    1d1d:	c5 fd 6f 0d db 13 00 	vmovdqa 0x13db(%rip),%ymm1        # 3100 <_IO_stdin_used+0x100>
    1d24:	00 
    1d25:	48 8d 4a ff          	lea    -0x1(%rdx),%rcx
    1d29:	48 89 f8             	mov    %rdi,%rax
    1d2c:	48 8d 14 57          	lea    (%rdi,%rdx,2),%rdx
    1d30:	c5 fa 6f 10          	vmovdqu (%rax),%xmm2
    1d34:	c4 e3 6d 38 40 10 01 	vinserti128 $0x1,0x10(%rax),%ymm2,%ymm0
    1d3b:	48 83 c0 20          	add    $0x20,%rax
    1d3f:	c4 e2 7d 00 c1       	vpshufb %ymm1,%ymm0,%ymm0
    1d44:	c5 fa 7f 40 e0       	vmovdqu %xmm0,-0x20(%rax)
    1d49:	c4 e3 7d 39 40 f0 01 	vextracti128 $0x1,%ymm0,-0x10(%rax)
    1d50:	48 39 d0             	cmp    %rdx,%rax
    1d53:	75 db                	jne    1d30 <reverse16_avx2+0x20>
    1d55:	48 83 e1 f0          	and    $0xfffffffffffffff0,%rcx
    1d59:	48 89 ca             	mov    %rcx,%rdx
    1d5c:	48 83 c2 10          	add    $0x10,%rdx
    1d60:	c5 f8 77             	vzeroupper 
    1d63:	48 39 d6             	cmp    %rdx,%rsi
    1d66:	76 15                	jbe    1d7d <reverse16_avx2+0x6d>
    1d68:	48 8d 04 57          	lea    (%rdi,%rdx,2),%rax
    1d6c:	48 8d 14 77          	lea    (%rdi,%rsi,2),%rdx
    1d70:	66 c1 00 08          	rolw   $0x8,(%rax)
    1d74:	48 83 c0 02          	add    $0x2,%rax
    1d78:	48 39 c2             	cmp    %rax,%rdx
    1d7b:	75 f3                	jne    1d70 <reverse16_avx2+0x60>
    1d7d:	c3                   	retq   
    1d7e:	66 90                	xchg   %ax,%ax

0000000000001d80 <reverse16_basic>:
    1d80:	f3 0f 1e fa          	endbr64 
    1d84:	48 85 f6             	test   %rsi,%rsi
    1d87:	74 14                	je     1d9d <reverse16_basic+0x1d>
    1d89:	48 8d 04 77          	lea    (%rdi,%rsi,2),%rax
    1d8d:	0f 1f 00             	nopl   (%rax)
    1d90:	66 c1 07 08          	rolw   $0x8,(%rdi)
    1d94:	48 83 c7 02          	add    $0x2,%rdi
    1d98:	48 39 c7             	cmp    %rax,%rdi
    1d9b:	75 f3                	jne    1d90 <reverse16_basic+0x10>
    1d9d:	c3                   	retq   
    1d9e:	66 90                	xchg   %ax,%ax

0000000000001da0 <print_array>:
    1da0:	f3 0f 1e fa          	endbr64 
    1da4:	48 85 f6             	test   %rsi,%rsi
    1da7:	74 47                	je     1df0 <print_array+0x50>
    1da9:	41 54                	push   %r12
    1dab:	4c 8d 25 52 12 00 00 	lea    0x1252(%rip),%r12        # 3004 <_IO_stdin_used+0x4>
    1db2:	55                   	push   %rbp
    1db3:	48 8d 2c 37          	lea    (%rdi,%rsi,1),%rbp
    1db7:	53                   	push   %rbx
    1db8:	48 89 fb             	mov    %rdi,%rbx
    1dbb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    1dc0:	0f be 13             	movsbl (%rbx),%edx
    1dc3:	4c 89 e6             	mov    %r12,%rsi
    1dc6:	bf 01 00 00 00       	mov    $0x1,%edi
    1dcb:	31 c0                	xor    %eax,%eax
    1dcd:	48 83 c3 01          	add    $0x1,%rbx
    1dd1:	e8 1a f3 ff ff       	callq  10f0 <__printf_chk@plt>
    1dd6:	48 39 dd             	cmp    %rbx,%rbp
    1dd9:	75 e5                	jne    1dc0 <print_array+0x20>
    1ddb:	5b                   	pop    %rbx
    1ddc:	bf 0a 00 00 00       	mov    $0xa,%edi
    1de1:	5d                   	pop    %rbp
    1de2:	41 5c                	pop    %r12
    1de4:	e9 b7 f2 ff ff       	jmpq   10a0 <putchar@plt>
    1de9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    1df0:	bf 0a 00 00 00       	mov    $0xa,%edi
    1df5:	e9 a6 f2 ff ff       	jmpq   10a0 <putchar@plt>
    1dfa:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

0000000000001e00 <test_reverse>:
    1e00:	f3 0f 1e fa          	endbr64 
    1e04:	55                   	push   %rbp
    1e05:	49 89 f0             	mov    %rsi,%r8
    1e08:	49 89 d1             	mov    %rdx,%r9
    1e0b:	48 89 e5             	mov    %rsp,%rbp
    1e0e:	41 57                	push   %r15
    1e10:	41 56                	push   %r14
    1e12:	49 89 fe             	mov    %rdi,%r14
    1e15:	41 55                	push   %r13
    1e17:	4c 8d 2c fd 00 00 00 	lea    0x0(,%rdi,8),%r13
    1e1e:	00 
    1e1f:	41 54                	push   %r12
    1e21:	53                   	push   %rbx
    1e22:	48 83 ec 28          	sub    $0x28,%rsp
    1e26:	64 48 8b 04 25 28 00 	mov    %fs:0x28,%rax
    1e2d:	00 00 
    1e2f:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    1e33:	31 c0                	xor    %eax,%eax
    1e35:	49 8d 45 0f          	lea    0xf(%r13),%rax
    1e39:	48 89 e1             	mov    %rsp,%rcx
    1e3c:	48 89 c6             	mov    %rax,%rsi
    1e3f:	48 89 c2             	mov    %rax,%rdx
    1e42:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
    1e49:	48 83 e2 f0          	and    $0xfffffffffffffff0,%rdx
    1e4d:	48 29 f1             	sub    %rsi,%rcx
    1e50:	48 39 cc             	cmp    %rcx,%rsp
    1e53:	74 15                	je     1e6a <test_reverse+0x6a>
    1e55:	48 81 ec 00 10 00 00 	sub    $0x1000,%rsp
    1e5c:	48 83 8c 24 f8 0f 00 	orq    $0x0,0xff8(%rsp)
    1e63:	00 00 
    1e65:	48 39 cc             	cmp    %rcx,%rsp
    1e68:	75 eb                	jne    1e55 <test_reverse+0x55>
    1e6a:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
    1e70:	48 29 d4             	sub    %rdx,%rsp
    1e73:	48 85 d2             	test   %rdx,%rdx
    1e76:	0f 85 04 01 00 00    	jne    1f80 <test_reverse+0x180>
    1e7c:	48 89 c6             	mov    %rax,%rsi
    1e7f:	48 89 e1             	mov    %rsp,%rcx
    1e82:	48 89 c2             	mov    %rax,%rdx
    1e85:	48 89 e3             	mov    %rsp,%rbx
    1e88:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
    1e8f:	48 83 e2 f0          	and    $0xfffffffffffffff0,%rdx
    1e93:	48 29 f1             	sub    %rsi,%rcx
    1e96:	48 39 cc             	cmp    %rcx,%rsp
    1e99:	74 15                	je     1eb0 <test_reverse+0xb0>
    1e9b:	48 81 ec 00 10 00 00 	sub    $0x1000,%rsp
    1ea2:	48 83 8c 24 f8 0f 00 	orq    $0x0,0xff8(%rsp)
    1ea9:	00 00 
    1eab:	48 39 cc             	cmp    %rcx,%rsp
    1eae:	75 eb                	jne    1e9b <test_reverse+0x9b>
    1eb0:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
    1eb6:	48 29 d4             	sub    %rdx,%rsp
    1eb9:	48 85 d2             	test   %rdx,%rdx
    1ebc:	0f 85 c9 00 00 00    	jne    1f8b <test_reverse+0x18b>
    1ec2:	48 89 c2             	mov    %rax,%rdx
    1ec5:	48 89 e1             	mov    %rsp,%rcx
    1ec8:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
    1ece:	49 89 e4             	mov    %rsp,%r12
    1ed1:	48 29 c1             	sub    %rax,%rcx
    1ed4:	48 83 e2 f0          	and    $0xfffffffffffffff0,%rdx
    1ed8:	48 39 cc             	cmp    %rcx,%rsp
    1edb:	74 15                	je     1ef2 <test_reverse+0xf2>
    1edd:	48 81 ec 00 10 00 00 	sub    $0x1000,%rsp
    1ee4:	48 83 8c 24 f8 0f 00 	orq    $0x0,0xff8(%rsp)
    1eeb:	00 00 
    1eed:	48 39 cc             	cmp    %rcx,%rsp
    1ef0:	75 eb                	jne    1edd <test_reverse+0xdd>
    1ef2:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
    1ef8:	48 29 d4             	sub    %rdx,%rsp
    1efb:	48 85 d2             	test   %rdx,%rdx
    1efe:	74 06                	je     1f06 <test_reverse+0x106>
    1f00:	48 83 4c 14 f8 00    	orq    $0x0,-0x8(%rsp,%rdx,1)
    1f06:	49 89 e7             	mov    %rsp,%r15
    1f09:	4d 85 ed             	test   %r13,%r13
    1f0c:	0f 84 4e 01 00 00    	je     2060 <test_reverse+0x260>
    1f12:	31 c0                	xor    %eax,%eax
    1f14:	0f 1f 40 00          	nopl   0x0(%rax)
    1f18:	88 04 03             	mov    %al,(%rbx,%rax,1)
    1f1b:	41 88 04 07          	mov    %al,(%r15,%rax,1)
    1f1f:	41 88 04 04          	mov    %al,(%r12,%rax,1)
    1f23:	48 83 c0 01          	add    $0x1,%rax
    1f27:	49 39 c5             	cmp    %rax,%r13
    1f2a:	75 ec                	jne    1f18 <test_reverse+0x118>
    1f2c:	4c 89 4d b8          	mov    %r9,-0x48(%rbp)
    1f30:	4c 89 f6             	mov    %r14,%rsi
    1f33:	4c 89 ff             	mov    %r15,%rdi
    1f36:	41 ff d0             	callq  *%r8
    1f39:	4c 89 f6             	mov    %r14,%rsi
    1f3c:	4c 89 e7             	mov    %r12,%rdi
    1f3f:	4c 8b 4d b8          	mov    -0x48(%rbp),%r9
    1f43:	41 ff d1             	callq  *%r9
    1f46:	4c 89 ea             	mov    %r13,%rdx
    1f49:	4c 89 fe             	mov    %r15,%rsi
    1f4c:	4c 89 e7             	mov    %r12,%rdi
    1f4f:	e8 8c f1 ff ff       	callq  10e0 <memcmp@plt>
    1f54:	85 c0                	test   %eax,%eax
    1f56:	75 48                	jne    1fa0 <test_reverse+0x1a0>
    1f58:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
    1f5c:	64 48 2b 0c 25 28 00 	sub    %fs:0x28,%rcx
    1f63:	00 00 
    1f65:	0f 85 16 01 00 00    	jne    2081 <test_reverse+0x281>
    1f6b:	48 8d 65 d8          	lea    -0x28(%rbp),%rsp
    1f6f:	5b                   	pop    %rbx
    1f70:	41 5c                	pop    %r12
    1f72:	41 5d                	pop    %r13
    1f74:	41 5e                	pop    %r14
    1f76:	41 5f                	pop    %r15
    1f78:	5d                   	pop    %rbp
    1f79:	c3                   	retq   
    1f7a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    1f80:	48 83 4c 14 f8 00    	orq    $0x0,-0x8(%rsp,%rdx,1)
    1f86:	e9 f1 fe ff ff       	jmpq   1e7c <test_reverse+0x7c>
    1f8b:	48 83 4c 14 f8 00    	orq    $0x0,-0x8(%rsp,%rdx,1)
    1f91:	e9 2c ff ff ff       	jmpq   1ec2 <test_reverse+0xc2>
    1f96:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
    1f9d:	00 00 00 
    1fa0:	48 8d 3d 61 10 00 00 	lea    0x1061(%rip),%rdi        # 3008 <_IO_stdin_used+0x8>
    1fa7:	4c 8d 35 56 10 00 00 	lea    0x1056(%rip),%r14        # 3004 <_IO_stdin_used+0x4>
    1fae:	e8 fd f0 ff ff       	callq  10b0 <puts@plt>
    1fb3:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
    1fb7:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    1fbb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    1fc0:	0f be 13             	movsbl (%rbx),%edx
    1fc3:	4c 89 f6             	mov    %r14,%rsi
    1fc6:	bf 01 00 00 00       	mov    $0x1,%edi
    1fcb:	31 c0                	xor    %eax,%eax
    1fcd:	48 83 c3 01          	add    $0x1,%rbx
    1fd1:	e8 1a f1 ff ff       	callq  10f0 <__printf_chk@plt>
    1fd6:	48 3b 5d b8          	cmp    -0x48(%rbp),%rbx
    1fda:	75 e4                	jne    1fc0 <test_reverse+0x1c0>
    1fdc:	bf 0a 00 00 00       	mov    $0xa,%edi
    1fe1:	4f 8d 34 2c          	lea    (%r12,%r13,1),%r14
    1fe5:	48 8d 1d 18 10 00 00 	lea    0x1018(%rip),%rbx        # 3004 <_IO_stdin_used+0x4>
    1fec:	e8 af f0 ff ff       	callq  10a0 <putchar@plt>
    1ff1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    1ff8:	41 0f be 14 24       	movsbl (%r12),%edx
    1ffd:	48 89 de             	mov    %rbx,%rsi
    2000:	bf 01 00 00 00       	mov    $0x1,%edi
    2005:	31 c0                	xor    %eax,%eax
    2007:	49 83 c4 01          	add    $0x1,%r12
    200b:	e8 e0 f0 ff ff       	callq  10f0 <__printf_chk@plt>
    2010:	4d 39 e6             	cmp    %r12,%r14
    2013:	75 e3                	jne    1ff8 <test_reverse+0x1f8>
    2015:	bf 0a 00 00 00       	mov    $0xa,%edi
    201a:	4d 01 fd             	add    %r15,%r13
    201d:	4c 8d 25 e0 0f 00 00 	lea    0xfe0(%rip),%r12        # 3004 <_IO_stdin_used+0x4>
    2024:	e8 77 f0 ff ff       	callq  10a0 <putchar@plt>
    2029:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    2030:	41 0f be 17          	movsbl (%r15),%edx
    2034:	4c 89 e6             	mov    %r12,%rsi
    2037:	bf 01 00 00 00       	mov    $0x1,%edi
    203c:	31 c0                	xor    %eax,%eax
    203e:	49 83 c7 01          	add    $0x1,%r15
    2042:	e8 a9 f0 ff ff       	callq  10f0 <__printf_chk@plt>
    2047:	4d 39 fd             	cmp    %r15,%r13
    204a:	75 e4                	jne    2030 <test_reverse+0x230>
    204c:	bf 0a 00 00 00       	mov    $0xa,%edi
    2051:	e8 4a f0 ff ff       	callq  10a0 <putchar@plt>
    2056:	b8 01 00 00 00       	mov    $0x1,%eax
    205b:	e9 f8 fe ff ff       	jmpq   1f58 <test_reverse+0x158>
    2060:	4c 89 4d b8          	mov    %r9,-0x48(%rbp)
    2064:	4c 89 f6             	mov    %r14,%rsi
    2067:	48 89 e7             	mov    %rsp,%rdi
    206a:	41 ff d0             	callq  *%r8
    206d:	4c 8b 4d b8          	mov    -0x48(%rbp),%r9
    2071:	4c 89 f6             	mov    %r14,%rsi
    2074:	4c 89 e7             	mov    %r12,%rdi
    2077:	41 ff d1             	callq  *%r9
    207a:	31 c0                	xor    %eax,%eax
    207c:	e9 d7 fe ff ff       	jmpq   1f58 <test_reverse+0x158>
    2081:	e8 4a f0 ff ff       	callq  10d0 <__stack_chk_fail@plt>
    2086:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
    208d:	00 00 00 

0000000000002090 <bench>:
    2090:	f3 0f 1e fa          	endbr64 
    2094:	41 55                	push   %r13
    2096:	49 89 fd             	mov    %rdi,%r13
    2099:	31 ff                	xor    %edi,%edi
    209b:	41 54                	push   %r12
    209d:	49 89 f4             	mov    %rsi,%r12
    20a0:	55                   	push   %rbp
    20a1:	48 89 d5             	mov    %rdx,%rbp
    20a4:	53                   	push   %rbx
    20a5:	bb 10 27 00 00       	mov    $0x2710,%ebx
    20aa:	48 83 ec 38          	sub    $0x38,%rsp
    20ae:	64 48 8b 04 25 28 00 	mov    %fs:0x28,%rax
    20b5:	00 00 
    20b7:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    20bc:	31 c0                	xor    %eax,%eax
    20be:	48 89 e6             	mov    %rsp,%rsi
    20c1:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
    20c8:	00 
    20c9:	48 c7 44 24 08 00 00 	movq   $0x0,0x8(%rsp)
    20d0:	00 00 
    20d2:	48 c7 44 24 10 00 00 	movq   $0x0,0x10(%rsp)
    20d9:	00 00 
    20db:	48 c7 44 24 18 00 00 	movq   $0x0,0x18(%rsp)
    20e2:	00 00 
    20e4:	e8 d7 ef ff ff       	callq  10c0 <clock_gettime@plt>
    20e9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    20f0:	4c 89 e6             	mov    %r12,%rsi
    20f3:	4c 89 ef             	mov    %r13,%rdi
    20f6:	ff d5                	callq  *%rbp
    20f8:	48 83 eb 01          	sub    $0x1,%rbx
    20fc:	75 f2                	jne    20f0 <bench+0x60>
    20fe:	48 8d 74 24 10       	lea    0x10(%rsp),%rsi
    2103:	31 ff                	xor    %edi,%edi
    2105:	e8 b6 ef ff ff       	callq  10c0 <clock_gettime@plt>
    210a:	48 8b 4c 24 18       	mov    0x18(%rsp),%rcx
    210f:	48 2b 4c 24 08       	sub    0x8(%rsp),%rcx
    2114:	48 ba 4b 59 86 38 d6 	movabs $0x346dc5d63886594b,%rdx
    211b:	c5 6d 34 
    211e:	48 89 c8             	mov    %rcx,%rax
    2121:	48 c1 f9 3f          	sar    $0x3f,%rcx
    2125:	48 f7 ea             	imul   %rdx
    2128:	48 c1 fa 0b          	sar    $0xb,%rdx
    212c:	48 89 d0             	mov    %rdx,%rax
    212f:	48 29 c8             	sub    %rcx,%rax
    2132:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
    2137:	64 48 2b 0c 25 28 00 	sub    %fs:0x28,%rcx
    213e:	00 00 
    2140:	75 0b                	jne    214d <bench+0xbd>
    2142:	48 83 c4 38          	add    $0x38,%rsp
    2146:	5b                   	pop    %rbx
    2147:	5d                   	pop    %rbp
    2148:	41 5c                	pop    %r12
    214a:	41 5d                	pop    %r13
    214c:	c3                   	retq   
    214d:	e8 7e ef ff ff       	callq  10d0 <__stack_chk_fail@plt>
    2152:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
    2159:	00 00 00 
    215c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000002160 <__libc_csu_init>:
    2160:	f3 0f 1e fa          	endbr64 
    2164:	41 57                	push   %r15
    2166:	4c 8d 3d 23 2c 00 00 	lea    0x2c23(%rip),%r15        # 4d90 <__frame_dummy_init_array_entry>
    216d:	41 56                	push   %r14
    216f:	49 89 d6             	mov    %rdx,%r14
    2172:	41 55                	push   %r13
    2174:	49 89 f5             	mov    %rsi,%r13
    2177:	41 54                	push   %r12
    2179:	41 89 fc             	mov    %edi,%r12d
    217c:	55                   	push   %rbp
    217d:	48 8d 2d 14 2c 00 00 	lea    0x2c14(%rip),%rbp        # 4d98 <__do_global_dtors_aux_fini_array_entry>
    2184:	53                   	push   %rbx
    2185:	4c 29 fd             	sub    %r15,%rbp
    2188:	48 83 ec 08          	sub    $0x8,%rsp
    218c:	e8 6f ee ff ff       	callq  1000 <_init>
    2191:	48 c1 fd 03          	sar    $0x3,%rbp
    2195:	74 1f                	je     21b6 <__libc_csu_init+0x56>
    2197:	31 db                	xor    %ebx,%ebx
    2199:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    21a0:	4c 89 f2             	mov    %r14,%rdx
    21a3:	4c 89 ee             	mov    %r13,%rsi
    21a6:	44 89 e7             	mov    %r12d,%edi
    21a9:	41 ff 14 df          	callq  *(%r15,%rbx,8)
    21ad:	48 83 c3 01          	add    $0x1,%rbx
    21b1:	48 39 dd             	cmp    %rbx,%rbp
    21b4:	75 ea                	jne    21a0 <__libc_csu_init+0x40>
    21b6:	48 83 c4 08          	add    $0x8,%rsp
    21ba:	5b                   	pop    %rbx
    21bb:	5d                   	pop    %rbp
    21bc:	41 5c                	pop    %r12
    21be:	41 5d                	pop    %r13
    21c0:	41 5e                	pop    %r14
    21c2:	41 5f                	pop    %r15
    21c4:	c3                   	retq   
    21c5:	66 66 2e 0f 1f 84 00 	data16 nopw %cs:0x0(%rax,%rax,1)
    21cc:	00 00 00 00 

00000000000021d0 <__libc_csu_fini>:
    21d0:	f3 0f 1e fa          	endbr64 
    21d4:	c3                   	retq   

Disassembly of section .fini:

00000000000021d8 <_fini>:
    21d8:	f3 0f 1e fa          	endbr64 
    21dc:	48 83 ec 08          	sub    $0x8,%rsp
    21e0:	48 83 c4 08          	add    $0x8,%rsp
    21e4:	c3                   	retq   
