## NGROK 国内加速版本



中文 / [English](./README.md)

鉴于本人在自己的服务器搭建 `ngrok` 由于国内访问 GitHub 是出奇的慢，所以将一个已经完全可以直接编译的包分享出来，能快速搭建就快速搭建。



原仓库地址： [https://github.com/inconshreveable/ngrok](https://github.com/inconshreveable/ngrok)

国内fork仓库：https://gitee.com/mrc1999/ngrok



### 使用容器生成【推荐】

直接在容器内生成客户端和服务端，无需额外安装环境

```bash
# check docker version
docker -v

# clone repository
git clone https://gitee.com/mrc1999/ngrok.git

cd ngrok

# set your domain
export NGROK_DOMAIN=ngrok.example.com

# build images
docker build -t ngrok:1 --build-arg NGROK_DOMAIN=$NGROK_DOMAIN .

# start docker
docker run -d -v `pwd`/bin:/ngrok/bin --rm --name ngrok ngrok:1

# test ngrokd
bin/ngrokd -domain="$NGROK_DOMAIN"
```



```tex
[root@VM-0-17-centos ngrok]# bin/ngrokd -domain="$NGROK_DOMAIN"
[16:57:04 CST 2022/04/08] [INFO] (ngrok/log.(*PrefixLogger).Info:83) [registry] [tun] No affinity cache specified
[16:57:04 CST 2022/04/08] [INFO] (ngrok/log.Info:112) Listening for public http connections on [::]:80
[16:57:04 CST 2022/04/08] [INFO] (ngrok/log.Info:112) Listening for public https connections on [::]:443
[16:57:04 CST 2022/04/08] [INFO] (ngrok/log.Info:112) Listening for control and proxy connections on [::]:4443
[16:57:04 CST 2022/04/08] [INFO] (ngrok/log.(*PrefixLogger).Info:83) [metrics] Reporting every 30 seconds

```



### 使用物理机生成

这种情况仅限于没有安装Docker的情况下使用，但需要有如下配置：

- openssl
- go 1.8 需要[手动安装]()
- make

```bash
# clone
git clone https://gitee.com/mrc1999/ngrok.git

# check go version
go version

cd ngrok

# set your domain
export NGROK_DOMAIN=ngrok.example.com

# make default
sh ./build.sh
```



默认生成：

1. LINUX 服务端 `bin/ngrokd`
2. Windows 客户端 `bin/windows_amd64/ngrok.exe`
3. Linux 客户端 `bin/ngrok`

> 如需生成其他版本操作系统的版本，请修改 `build.sh` 参照 【如何编译不同系统的客户端】



#### Go语言环境

这里踩了几个坑，试过了好几个版本，最终发现 `go1.8 linux/amd64` 适合于当前的编译过程。

这里请使用国内加速的镜像站点进行下载包，国外的实在是慢的扣脚。。

> https://golang.google.cn/

选择合适的架构包进行下载。我这里选择`1.8`

> wget https://golang.google.cn/dl/go1.8.linux-amd64.tar.gz


```bash
# download
wget https://golang.google.cn/dl/go1.8.linux-amd64.tar.gz

# unzip
tar -zxvf go1.8.linux-amd64.tar.gz

# move
mv go /usr/local

# ln
ln -s /usr/local/go/bin/* /usr/bin/

# check version
go version
```

做到这里，如果正确打印出go 所在的版本，我们已经正确的安装了它。



### 如何编译不同系统的客户端

```bash
# make default (linux)
make release-server
make release-client

# make custom
GOOS="darwin" GOARCH="amd64" make release-client
GOOS="linux" GOARCH="amd64" make release-client
GOOS="windows" GOARCH="amd64" make release-client
```

> 参考：https://golang.org/doc/install/source#environment

编译指定类型的客户端和服务端，如果不设置 `GOOS` 和 `GOARCH` 则默认生成和本机一样的架构和系统运行包。

这里以我的服务为例，我是用 `Centos-amd64` 作为我的服务器，则命令如下：

```bash
make release-server

GOOS="linux" GOARCH="amd64" make release-client
```



### 准备域名

这里我们需要准备一个基础域名，例如：我的 `chaobei.xyz` 是我购买的域名，当然，我给它分配了一个三级域名 `ngrok.chaobei.xyz` 作为服务端的基础域名来使用。



而客户端则在连接服务端的时候，可以指定一个域名前缀，例如：`test.ngrok.chaobei.xyz` . 当我们访问 `test.ngrok.chaobei.xyz`  就能访问到我内网的机器了。



#### 添加 DNS 映射

在你域名的服务商处，增加两条记录。还是按照我上面的域名为例。

`ngrok` -------> 你服务器的IP

`*.ngrok` -------> 你服务器的IP



### 运行

#### 运行服务端

注意：这里要开启两个端口，需要在服务器那边进行放行。

```bash
bin/ngrokd -domain="$NGROK_DOMAIN" -httpAddr=":8088" -httpsAddr=":8089"
```

```
[14:58:56 CST 2021/07/20] [INFO] (ngrok/log.(*PrefixLogger).Info:83) [registry] [tun] No affinity cache specified
[14:58:56 CST 2021/07/20] [INFO] (ngrok/log.Info:112) Listening for public http connections on [::]:8088
[14:58:56 CST 2021/07/20] [INFO] (ngrok/log.Info:112) Listening for public https connections on [::]:8089
[14:58:56 CST 2021/07/20] [INFO] (ngrok/log.Info:112) Listening for control and proxy connections on [::]:4443
[14:58:56 CST 2021/07/20] [INFO] (ngrok/log.(*PrefixLogger).Info:83) [metrics] Reporting every 30 seconds
```

- 8088 对外HTTP连接端口
- 8089 对外HTTPS 连接端口
- 4443 客户端通信端口



#### 运行客户端

这里以`windows` 平台为例，同级目录下添加一个`ngrok.yml` 配置文件。

```yaml
server_addr: "ngrok.chaobei.xyz:4443"  
trust_host_root_certs: false
```

```cmd
ngrok.exe -subdomain mrc -config ngrok.yml 80
```

- subdomain 指定子域名
- config 指定配置文件所在位置
- 80 映射到外网的地址

![image-20210720150657237](https://file.chaobei.xyz/20210720150657.png_imagess)



### 参考

https://github.com/inconshreveable/ngrok/blob/master/docs/SELFHOSTING.md

https://gist.github.com/lyoshenka/002b7fbd801d0fd21f2f

https://golang.org/doc/install/source#environment

https://www.cnblogs.com/flhs/p/13194357.html