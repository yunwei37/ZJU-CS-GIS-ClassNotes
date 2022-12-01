# uboot

## compile

on ubuntu 20.04:

```bash
sudo apt install qemu-system-riscv64
sudo apt-get install gcc-riscv64-linux-gnu
sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev libncurses-dev device-tree-compiler
sudo apt install gdb-multiarch

git clone https://github.com/u-boot/u-boot
cd u-boot
CROSS_COMPILE=riscv64-linux-gnu- make qemu-riscv64_defconfig
CROSS_COMPILE=riscv64-linux-gnu- make
qemu-system-riscv64 -nographic -machine virt -bios u-boot.bin
```

## debug

.gdbinit
```
set confirm off
set auto-load safe-path /
target remote 127.0.0.1:1234
```

```bash
echo "add-auto-load-safe-path /" > /home/yunwei/.gdbinit
qemu-system-riscv64 -nographic -machine virt -bios u-boot.bin -S -s
```

```bash
gdb-multiarch u-boot
```

## boot process

see u-boot.lds:

```
 .text : {
  arch/riscv/cpu/start.o (.text)
 }
```

arch/riscv/cpu/start.S:39

```
0x0000000000001010 in ?? ()
(gdb) si
_start () at arch/riscv/cpu/start.S:43
warning: Source file is more recent than executable.
43		csrr	a0, CSR_MHARTID
```

```
call_board_init_f () at arch/riscv/cpu/start.S:93
93		li	t0, -16
```

```
(gdb) si
call_board_init_f_0 () at arch/riscv/cpu/start.S:102
102		mv	a0, sp
(gdb) si
103		jal	board_init_f_alloc_reserve
(gdb) si
board_init_f_alloc_reserve (top=2149580800) at common/init/board_init.c:87
87		return top;
```

```
call_harts_early_init () at arch/riscv/cpu/start.S:122
122		jal	harts_early_init
(gdb) si
harts_early_init () at arch/riscv/cpu/cpu.c:164
164	}
(gdb) si
call_harts_early_init () at arch/riscv/cpu/start.S:129
129		la	t0, hart_lottery
```

```
board_init_f_init_reserve (base=2149563744) at common/init/board_init.c:141
141		gd_ptr = (struct global_data *)base;
(gdb) si
```

```
146		arch_setup_gd(gd_ptr);
(gdb) s
arch_setup_gd (gd_ptr=gd_ptr@entry=0x801fbd60) at common/init/board_init.c:20
20		gd = gd_ptr;
```

```
153		amoswap.w.rl zero, zero, 0(t0)
(gdb) s
wait_for_gd_init () at arch/riscv/cpu/start.S:156
156		la	t0, available_harts_lock

```

```
icache_enable () at arch/riscv/lib/cache.c:50
50	}
(gdb) s
wait_for_gd_init () at arch/riscv/cpu/start.S:186
186		jal	dcache_enable
(gdb) s

```

```
(gdb) s
board_init_f (boot_flags=0) at common/board_f.c:958
958		gd->flags = boot_flags;

```

```
(gdb) s
initcall_run_list (init_sequence=0x80079fa8 <init_sequence_f>) at include/initcall.h:26
26		for (init_fnc_ptr = init_sequence; *init_fnc_ptr; ++init_fnc_ptr) {

```

```
(gdb) s
board_init_f (boot_flags=<optimized out>) at common/board_f.c:961
961		if (initcall_run_list(init_sequence_f))
(gdb) ss
Undefined command: "ss".  Try "help".

```

```
(gdb) s
fdtdec_setup () at lib/fdtdec.c:1641
1641			gd->fdt_blob = fdt_find_separate();
(gdb) s
1650			gd->fdt_blob = board_fdt_blob_setup(&ret);
```

```
initf_malloc () at common/dlmalloc.c:2466
2466		gd->malloc_limit = CONFIG_VAL(SYS_MALLOC_F_LEN);
(gdb) s
2467		gd->malloc_ptr = 0;
```

```
(gdb) s
log_init () at include/log.h:679
679		return 0;
```

```
(gdb) s
0x0000000080011538 in setup_spl_handoff () at common/board_f.c:785
785		ret = dm_init_and_scan(true);
(gdb) s

```

```
(gdb) s
dm_init (of_live=false) at drivers/core/root.c:173
173		if (gd->dm_root) {

```

```
device_bind_by_name (parent=parent@entry=0x0, pre_reloc_only=pre_reloc_only@entry=false, info=info@entry=0x8007ad08 <root_info>, devp=0x801fbe08) at drivers/core/device.c:264
264		if (!drv)
(gdb) n
266		if (pre_reloc_only && !(drv->flags & DM_FLAG_PRE_RELOC))
(gdb) n
223		return node;
(gdb) n
device_bind_common (parent=parent@entry=0x0, drv=0x800852f0 <_u_boot_list_2_driver_2_root_driver>, name=0x80071f50 "root_driver", plat=0x0, driver_data=driver_data@entry=0, 
    node=node@entry=..., devp=0x801fbe08, of_plat_size=0) at drivers/core/device.c:53
53		if (devp)

```

```
190		return 0;
(gdb) n
lists_bind_fdt (parent=parent@entry=0x801fc0f8, node=node@entry=..., devp=devp@entry=0x0, drv=drv@entry=0x0, pre_reloc_only=pre_reloc_only@entry=true)
    at drivers/core/lists.c:249
249			if (ret == -ENODEV) {
```

```
(gdb) n
event_notify_null (type=EVT_DM_POST_INIT) at common/event.c:132
132		return event_notify(type, NULL, 0);
```

```

Breakpoint 1, device_bind_common (parent=parent@entry=0x801fc030, drv=drv@entry=0x80085040 <_u_boot_list_2_driver_2_ns16550_serial>, name=name@entry=0x1168 "uart@10000000", 
    plat=plat@entry=0x0, driver_data=0, node=..., devp=devp@entry=0x801fbc88, of_plat_size=0) at drivers/core/device.c:53
53		if (devp)

```

b

```
serial_init () at drivers/serial/serial-uclass.c
```

```
(gdb) s
console_init_f () at common/console.c:926
926		gd->have_console = 1;
(gdb) s
932		return 0;
```

```
48			ret = (*init_fnc_ptr)();
(gdb) s
display_options () at lib/display_options.c:47
47		display_options_get_banner(true, buf, sizeof(buf));
```

HERE: U-Boot 2022.07-rc2-00065-gc387e62614-dirty (May 13 2022 - 21:48:00 -0700)


## add message

```
int display_options(void)
{
	char buf[DISPLAY_OPTIONS_BANNER_LENGTH];

	display_options_get_banner(true, buf, sizeof(buf));
	printf("%s", buf);

	printf("Icenowy is the cutest!\n");

	return 0;
}
```

```
CROSS_COMPILE=riscv64-linux-gnu- make
```

## format and produce patch

```
yunwei@ubuntu:~/coding/u-boot$ git format-patch -1
0001-display_options-Add-Icenowy-Cutest-message.patch

yunwei@ubuntu:~/coding/u-boot$ ./scripts/checkpatch.pl 0001-display_options-Add-Icenowy-Cutest-message.patch 
total: 0 errors, 0 warnings, 0 checks, 7 lines checked
```

patch

```
From ff69e54d0942cbf376b2065605f2dac3dd36a713 Mon Sep 17 00:00:00 2001
From: yunwei37 <1067852565@qq.com>
Date: Fri, 13 May 2022 22:29:05 -0700
Subject: [PATCH] display_options: Add Icenowy Cutest message

At present there is not message about Icenowy.
Everyone using U-Boot should know this: Icenowy is the cutest!
It should be displayed with the version string.

Signed-off-by: yunwei37 <1067852565@qq.com>
---
 lib/display_options.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/display_options.c b/lib/display_options.c
index 360b01bcf5..54aafa0d55 100644
--- a/lib/display_options.c
+++ b/lib/display_options.c
@@ -46,6 +46,7 @@ int display_options(void)
 
 	display_options_get_banner(true, buf, sizeof(buf));
 	printf("%s", buf);
+	printf("Icenowy is the cutest!\n");
 
 	return 0;
 }
-- 
2.25.1
```

result:

```
yunwei@ubuntu:~/coding/u-boot$ qemu-system-riscv64 -nographic -machine virt -bios u-boot.bin


U-Boot 2022.07-rc2-00066-gff5700ffb5 (May 13 2022 - 22:23:31 -0700)

Icenowy is the cutest!
CPU:   rv64imafdcsu
Model: riscv-virtio,qemu
DRAM:  128 MiB
Core:  21 devices, 11 uclasses, devicetree: board
Flash: 32 MiB
Loading Environment from nowhere... OK
In:    uart@10000000
Out:   uart@10000000
Err:   uart@10000000
Net:   No ethernet found.
Hit any key to stop autoboot:  0 

Device 0: unknown device
scanning bus for devices...

Device 0: unknown device
No ethernet found.
No ethernet found.
```

## reference

- https://github.com/u-boot/u-boot/blob/master/doc/board/emulation/qemu-riscv.rst
- https://github.com/carlosedp/riscv-bringup/blob/master/Qemu/Readme.md#installing-and-running-the-qemu-vm
- https://github.com/u-boot/u-boot/blob/3e5f4b337d89e95af9d3700a4b055b552bf22ac4/doc/develop/checkpatch.rst