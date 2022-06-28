## run apisix profile

https://apisix.apache.org/zh/docs/apisix/getting-started/

### env:

Linux iZ2zeef27fei4hdksh1c3aZ 4.18.0-348.7.1.el8_5.x86_64 #1 SMP Wed Dec 22 13:25:12 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux

centos 8.5，阿里云 ECS 

### install docker and docker-compose

see:  https://docs.docker.com/engine/install/centos/
and   https://serverspace.io/support/help/how-to-install-docker-on-centos-8/

### start

```
#将 Apache APISIX 的 Docker 镜像下载到本地
git clone https://github.com/apache/apisix-docker.git
# 将当前的目录切换到 apisix-docker/example 路径下
cd apisix-docker/example
# 运行 docker-compose 命令，安装 Apache APISIX
docker-compose -p docker-apisix up -d
```

run:

```
[root@iZ2zeef27fei4hdksh1c3aZ example]# curl "http://127.0.0.1:9080/apisix/admin/services/" -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1'
{"action":"get","count":0,"node":{"key":"\/apisix\/services","dir":true,"nodes":[]}}
[root@iZ2zeef27fei4hdksh1c3aZ example]#
```

```
[root@iZ2zeef27fei4hdksh1c3aZ example]# curl "http://127.0.0.1:9080/apisix/admin/routes/1" -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '
> {
>   "methods": ["GET"],
>   "host": "example.com",
>   "uri": "/anything/*",
>   "upstream": {
>     "type": "roundrobin",
>     "nodes": {
>       "httpbin.org:80": 1
>     }
>   }
> }'
{"node":{"value":{"priority":0,"status":1,"upstream":{"hash_on":"vars","nodes":{"httpbin.org:80":1},"type":"roundrobin","pass_host":"pass","scheme":"http"},"uri":"\/anything\/*","methods":["GET"],"create_time":1652201348,"update_time":1652201348,"id":"1","host":"example.com"},"key":"\/apisix\/routes\/1"},"action":"set"}
```

## status

```
[root@iZ2zeef27fei4hdksh1c3aZ ~]# docker ps
CONTAINER ID   IMAGE                                   COMMAND                  CREATED          STATUS          PORTS                                                                                                                                                 NAMES
f4275ed89e56   apache/apisix:2.13.1-alpine             "sh -c '/usr/bin/api…"   10 minutes ago   Up 10 minutes   0.0.0.0:9080->9080/tcp, :::9080->9080/tcp, 0.0.0.0:9091-9092->9091-9092/tcp, :::9091-9092->9091-9092/tcp, 0.0.0.0:9443->9443/tcp, :::9443->9443/tcp   docker-apisix_apisix_1
0f15ab62b93d   apache/apisix-dashboard:2.10.1-alpine   "/usr/local/apisix-d…"   10 minutes ago   Up 10 minutes   0.0.0.0:9000->9000/tcp, :::9000->9000/tcp                                                                                                             docker-apisix_apisix-dashboard_1
266dcad03d85   bitnami/etcd:3.4.15                     "/opt/bitnami/script…"   10 minutes ago   Up 10 minutes   0.0.0.0:2379->2379/tcp, :::2379->2379/tcp, 2380/tcp                                                                                                   docker-apisix_etcd_1
8ea9a3d55ce0   grafana/grafana:7.3.7                   "/run.sh"                10 minutes ago   Up 10 minutes   0.0.0.0:3000->3000/tcp, :::3000->3000/tcp                                                                                                             docker-apisix_grafana_1
47e104bc6fe4   prom/prometheus:v2.25.0                 "/bin/prometheus --c…"   10 minutes ago   Up 10 minutes   0.0.0.0:9090->9090/tcp, :::9090->9090/tcp                                                                                                             docker-apisix_prometheus_1
716f445f4787   nginx:1.19.0-alpine                     "/docker-entrypoint.…"   10 minutes ago   Up 10 minutes   0.0.0.0:9082->80/tcp, :::9082->80/tcp                                                                                                                 docker-apisix_web2_1
ab134080a4ab   nginx:1.19.0-alpine                     "/docker-entrypoint.…"   10 minutes ago   Up 10 minutes   0.0.0.0:9081->80/tcp, :::9081->80/tcp                                                                                                                 docker-apisix_web1_1
```

```
[root@iZ2zeef27fei4hdksh1c3aZ openresty-systemtap-toolkit]# ./sample-bt -p 8389 -t 5 -u > a.bt
WARNING: libdwfl failure getting symbol table for kernel: No symbol table found
WARNING: missing unwind/symbol data for module '/lib/ld-musl-x86_64.so.1'
WARNING: missing unwind/symbol data for module '/lib/libz.so.1.2.12'
WARNING: missing unwind/symbol data for module '/usr/lib/libgcc_s.so.1'
WARNING: missing unwind/symbol data for module '/usr/lib/libstdc++.so.6.0.28'
WARNING: missing unwind/symbol data for module '/usr/local/apisix/deps/lib/lua/5.1/lfs.so'
WARNING: missing unwind/symbol data for module '/usr/local/apisix/deps/lib/lua/5.1/librestyradixtree.so'
WARNING: missing unwind/symbol data for module '/usr/local/apisix/deps/lib/lua/5.1/lpeg.so'
WARNING: missing unwind/symbol data for module '/usr/local/apisix/deps/lib/lua/5.1/pb.so'
WARNING: missing unwind/symbol data for module '/usr/local/apisix/deps/lib/lua/5.1/socket/core.so'
WARNING: missing unwind/symbol data for module '/usr/local/apisix/deps/lib/lua/5.1/socket/unix.so'
WARNING: missing unwind/symbol data for module '/usr/local/apisix/deps/lib/lua/5.1/ssl.so'
WARNING: missing unwind/symbol data for module '/usr/local/openresty/luajit/lib/libluajit-5.1.so.2.1.0'
WARNING: missing unwind/symbol data for module '/usr/local/openresty/lualib/cjson.so'
WARNING: missing unwind/symbol data for module '/usr/local/openresty/nginx/sbin/nginx'
WARNING: missing unwind/symbol data for module '/usr/local/openresty/openssl111/lib/libcrypto.so.1.1'
WARNING: missing unwind/symbol data for module '/usr/local/openresty/openssl111/lib/libssl.so.1.1'
WARNING: missing unwind/symbol data for module '/usr/local/openresty/pcre/lib/libpcre.so.1.2.12'
WARNING: missing unwind/symbol data for module '/usr/local/openresty/wasmtime-c-api/lib/libwasmtime.so'
WARNING: Tracing 8389 (/usr/local/openresty/nginx/sbin/nginx) in user-space only...
WARNING: No backtraces found. Quitting now...
```

## systemtap 

yum install systemtap
stap-prep

```
[root@iZ2zeef27fei4hdksh1c3fZ ~]# stap -v -e 'probe vfs.read {printf("read performed\n"); exit()}'
Pass 1: parsed user script and 473 library scripts using 267036virt/68740res/3440shr/65344data kb, in 600usr/50sys/657real ms.
semantic error: while resolving probe point: identifier 'kernel' at /usr/share/systemtap/tapset/linux/vfs.stp:976:18
        source: probe vfs.read = kernel.function("vfs_read")
                                 ^

semantic error: missing x86_64 kernel/module debuginfo [man warning::debuginfo] under '/lib/modules/3.10.0-862.14.4.el7.x86_64/build'

semantic error: resolution failed in alias expansion builder

semantic error: while resolving probe point: identifier 'vfs' at <input>:1:7
        source: probe vfs.read {printf("read performed\n"); exit()}
                      ^

semantic error: no match

Pass 2: analyzed script: 0 probes, 0 functions, 0 embeds, 0 globals using 278560virt/80136res/5484shr/74768data kb, in 120usr/120sys/239real ms.
Missing separate debuginfos, use: debuginfo-install kernel-3.10.0-862.14.4.el7.x86_64 
Pass 2: analysis failed.  [man error::pass2]
[root@iZ2zeef27fei4hdksh1c3fZ ~]# debuginfo-install kernel-3.10.0-862.14.4.el7.x86_64 
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
Could not find debuginfo for main pkg: kernel-3.10.0-862.14.4.el7.x86_64
No debuginfo packages available to install
```

## kernel debug
```
uname -a
cat /etc/redhat-release 
wget http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-common-x86_64-3.10.0-693.el7.x86_64.rpm
wget http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-3.10.0-693.el7.x86_64.rpm
yum install kernel-debuginfo-common-x86_64-3.10.0-693.el7.x86_64.rpm
yum install kernel-debuginfo-3.10.0-693.el7.x86_64.rpm

```

https://wangmingjun.com/2018/09/15/how-to-download-and-install-debuginfo-packages-for-centos/

## rerun systemtap

```
[root@iZ2zeef27fei4hdksh1c3fZ ~]# stap -v -e 'probe vfs.read {printf("read performed\n"); exit()}'
Pass 1: parsed user script and 473 library scripts using 267036virt/68744res/3444shr/65344data kb, in 610usr/70sys/785real ms.
Pass 2: analyzed script: 1 probe, 1 function, 7 embeds, 0 globals using 426208virt/223168res/4812shr/224516data kb, in 2410usr/890sys/5332real ms.
Pass 3: translated to C into "/tmp/stapn3JuRt/stap_71a14b40f483c8e12de3e370e458e000_2805_src.c" using 426208virt/223428res/5072shr/224516data kb, in 10usr/70sys/88real ms.
Pass 4: compiled C into "stap_71a14b40f483c8e12de3e370e458e000_2805.ko" in 8450usr/1880sys/10759real ms.
Pass 5: starting run.
read performed
Pass 5: run completed in 0usr/20sys/305real ms.
```

It's OK now. 

## nginx debug
```
wget https://nginx.org/download/nginx-1.19.0.tar.gz
tar zxf nginx-1.19.0.tar.gz
cd nginx-1.19.0
sudo yum install pcre-devel
sudo yum install zlib*
./configure --with-debug
make
make install
```

## openresty

basic benchmark：

https://openresty.org/en/getting-started.html
https://openresty.org/en/benchmark.html

```
[root@iZ2zeef27fei4hdksh1c3fZ http_load-09Mar2016]# ps -aux | grep nginx
root      5831  0.0  0.0  55348  1640 ?        Ss   16:31   0:00 nginx: master process nginx -p /root/work/ -c conf/nginx.conf
nobody    5832  0.0  0.1  55736  2888 ?        S    16:31   0:00 nginx: worker process
```

```
http_load -rate 5 -seconds 100 urls.txt
```

```
git clone https://github.com/openresty/openresty-systemtap-toolkit
./openresty-systemtap-toolkit/sample-bt -p 5832 -t 20 -u > a.bt
```

```
git clone https://github.com/brendangregg/FlameGraph
```
## reference

https://www.jianshu.com/p/33a99715af9b
https://github.com/openresty/openresty-systemtap-toolkit/blob/master/README-CN.markdown
https://sourceware.org/systemtap/SystemTap_Beginners_Guide/using-systemtap.html
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/monitoring_and_managing_system_status_and_performance/getting-started-with-systemtap_monitoring-and-managing-system-status-and-performance
https://blog.csdn.net/u013139008/article/details/85015648

## ci

```
sudo apt-get update
sudo apt install git -y
useradd zys
mkdir /home/zys
cd /home/zys
passwd zys 123
echo "zys ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoer
su zys

git clone https://github.com/apache/apisix
cd apisix
sudo apt-get install -y libpcre3 libpcre3-dev
sudo apt-get install -y openssl libssl-dev unzip zlib*
sudo ./ci/performance_test.sh install_dependencies
sudo ./ci/performance_test.sh install_wrk2
sudo ./ci/performance_test.sh install_stap_tools
./ci/performance_test.sh run_performance_test
```

iconv.so: undefined symbol: luaL_setfuncs

## bpf

```
root@iZrj9fvjv9xhtiiv76ryntZ:/home/zys# cat /boot/config-$(uname -r) | grep "BPF"
CONFIG_CGROUP_BPF=y
CONFIG_BPF=y
CONFIG_BPF_UNPRIV_DEFAULT_OFF=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT_ALWAYS_ON=y
CONFIG_NETFILTER_XT_MATCH_BPF=m
CONFIG_NET_CLS_BPF=m
CONFIG_NET_ACT_BPF=m
CONFIG_BPF_JIT=y
CONFIG_BPF_STREAM_PARSER=y
CONFIG_LWTUNNEL_BPF=y
CONFIG_HAVE_EBPF_JIT=y
CONFIG_BPF_EVENTS=y
CONFIG_TEST_BPF=m
```

```
sudo apt-get install bpfcc-tools linux-headers-$(uname -r) 
sudo apt install *bpfcc
sudo apt-get -y install bison build-essential cmake flex git libedit-dev \
  libllvm6.0 llvm-6.0-dev libclang-6.0-dev python zlib1g-dev libelf-dev 
```

```
git clone --depth=1 https://github.com/brendangregg/FlameGraph
sudo bash
perf record -F 49 -a -g -- sleep 30; ./FlameGraph/jmaps
perf script > out.stacks01
cat out.stacks01 | ./FlameGraph/stackcollapse-perf.pl --all | grep -v cpu_idle | \
    ./FlameGraph/flamegraph.pl --color=java --hash > out.stacks01.svg
```