# week 1 TiDB 总体架构

## 要求

本地下载 TiDB，TiKV，PD 源代码，改写源码并编译部署以下环境：

* 1 TiDB
* 1 PD
* 3 TiKV

改写后，使得 TiDB 启动事务时，能打印出一个 “hello transaction” 的 日志

作业提交方式：提交至个人 github ，将链接发送给 talent-plan@tidb.io

## 第一步：源码编译

安装 go：

- 下载安装包：https://studygolang.com/dl
- sudo tar -C /usr/local -xzf go1.15.linux-amd64.tar.gz
- export PATH=$PATH:/usr/local/go/bin

下载 TiDB 源码并编译(已安装 go, make)

```bash
git clone https://github.com/pingcap/tidb.git
cd tidb
make
```

下载 TiKV 源码并编译(已安装 rustup, cmake, make)

```bash
git clone https://github.com/tikv/tikv.git
rustup component add rustfmt
rustup component add clippy
cd tikv
make build
```

下载 PD 源码并编译(已安装 go, make)

```bash
git clone https://github.com/pingcap/pd.git
cd pd
make
```

## 第二步：运行集群

运行 1 个 PD

```bash
cd pd
nohup bin/pd-server --name="pd" \
          --data-dir="data/pd" \
          --client-urls="http://127.0.0.1:2379" \
          --peer-urls="http://127.0.0.11:2380" \
          --log-file="log/pd.log" >/dev/null 2>&1 &
```

调整系统最大可以打开的文件数量，TiKV 实例要求该数量不小于 82920

```bash
sudo launchctl limit maxfiles 82920
```

运行 3 个 TiKV

```bash
nohup tikv/target/debug/tikv-server --log-file="log/tikv1.log" \
                --addr="127.0.0.1:20160" \
                --data-dir="data/tikv1" \
                --pd-endpoints="http://127.0.0.1:2379" >/dev/null 2>&1 &

nohup tikv/target/debug/tikv-server --log-file="log/tikv2.log" \
                --addr="127.0.0.1:20161" \
                --data-dir="data/tikv2" \
                --pd-endpoints="http://127.0.0.1:2379" >/dev/null 2>&1 &

nohup tikv/target/debug/tikv-server --log-file="log/tikv3.log" \
                --addr="127.0.0.1:20162" \
                --data-dir="data/tikv3" \
                --pd-endpoints="http://127.0.0.1:2379" >/dev/null 2>&1 &
```

运行 1 个 TiDB

```bash
nohup ./tidb/bin/tidb-server --store="tikv" \
                --path="127.0.0.1:2379" \
                --log-file="log/tidb.log" >/dev/null 2>&1 &
```

用 mysql 客户端连接集群

```bash
mysql -h 127.0.0.1 -P 4000 -u root -D test
```

测试查询

```sql
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| INFORMATION_SCHEMA |
| METRICS_SCHEMA     |
| PERFORMANCE_SCHEMA |
| mysql              |
| test               |
+--------------------+
5 rows in set (0.00 sec)

```

## 第三步：修改 Transaction

打开 kv/txn.go，在函数 RunInNewTxn 函数中加入

```go
func RunInNewTxn(store Storage, retryable bool, f func(txn Transaction) error) error {
	logutil.BgLogger().Info("hello transaction")
    ...
}
```

重启 TiDB 实例，即可看到结果

```bash
...
[2020/08/16 19:32:56.878 +08:00] [INFO] [server.go:235] ["server is running MySQL protocol"] [addr=0.0.0.0:4000]
[2020/08/16 19:32:56.878 +08:00] [INFO] [http_status.go:82] ["for status and metrics report"] ["listening on addr"=0.0.0.0:10080]
[2020/08/16 19:32:57.435 +08:00] [INFO] [txn.go:30] ["hello transaction"]
[2020/08/16 19:32:57.435 +08:00] [INFO] [txn.go:30] ["hello transaction"]
[2020/08/16 19:32:58.435 +08:00] [INFO] [txn.go:30] ["hello transaction"]
[2020/08/16 19:32:58.435 +08:00] [INFO] [txn.go:30] ["hello transaction"]
...

```