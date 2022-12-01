# lua condig

类似于 xmake 和 <https://github.com/iovisor/bcc/tree/master/examples/lua> 的设计，我们打算使用 lua 来帮助进行用户态一些可选信息的配置，例如：

- 将多个 eBPF 程序打包成一个 package；
- 修改内核态上报的信息；
- 控制 eBPF 程序的运行；

例如：

```lua
target("ebpf_program1") -- basic
    add_files("src/opensnoop.bpf.c")

target("ebpf_program1")
    set_kind("uprobe")
    attach_to("handler_entry_uprobe", "lua_pcall") -- attach to lua_pcall in uprobe
    on_event(function (event)
        sort(event)
        os.print("uprobe event: ", event)
        stop("ebpf_program1")
    end)
    add_files("src/uprobe.bpf.c")

entry(function (arg)   -- replace the default entry with
    if arg == "uprobe" then
        run("ebpf_program1")
        sleep(1000)
        run("ebpf_program2")
    else
        run("ebpf_program1")
    end
end)
```

在 lua 用户态配置中编写的信息应尽可能简单。

> 这部分还未完成，目前正在加紧赶工
