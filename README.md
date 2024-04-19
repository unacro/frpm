# frpm - frp Manager

> 一键安装 / 更新 / 配置 frp

## Library - frp

- [Source Code](https://github.com/fatedier/frp)
- [Documentation](https://gofrp.org/)

## Usage

```bash
# 如果直连 GitHub 速度堪忧, 可以 *为本脚本* 设置 Github 镜像
$ export GITHUB_PROXY_URL="https://mirror.ghproxy.com/"

# clone 后从源码运行脚本
$ git clone https://github.com/unacro/frpm.git && cd frpm
$ git pull && bash install.sh && bash prototype.sh

# 从国内镜像下载并执行脚本
$ mkdir -p /usr/local/share/frp && cd /usr/local/share/frp
$ curl -fsSLO osrp.run/frpm && chmod +x frpm && ./frpm
```

## File structure

```goat
/
 ├─etc
 │  └─frp # 默认配置目录 `FRP_CONFIG_DIR`
 │     ├─conf.d
 │     │  ├─client
 │     │  │  ├─meta_web_server.toml
 │     │  │  ├─proxy_other.toml
 │     │  │  ├─proxy_ssh.toml
 │     │  │  └─proxy_web.toml
 │     │  └─server
 │     │     └─meta_web_server.toml
 │     ├─template
 │     │  ├─frpc.example.toml # 示例默认客户端配置
 │     │  ├─frpc_single_ssh.example.toml # 示例单文件客户端配置
 │     │  ├─frpc_tcp_proxies.example.toml # 示例客户端独立 tcp 代理配置
 │     │  ├─frpc_stcp_proxies.example.toml # 示例客户端独立 stcp 代理配置
 │     │  ├─frpc_stcp_visitors.example.toml # 示例客户端独立 stcp 访问者配置
 │     │  ├─frpc.example.service # 示例默认客户端后台服务
 │     │  ├─frps.example.toml # 示例默认服务端配置
 │     │  ├─frps.example.service # 示例默认服务端后台服务
 │     │  └─meta_web_server.example.toml # 示例通用 Web 界面独立配置
 │     ├─frpc.toml
 │     └─frps.toml
 └─usr
    └─local
       ├─bin
       │  ├─frpc -> ../share/frp/frpc
       │  ├─frpm -> ../share/frp/frpm
       │  └─frps -> ../share/frp/frps
       └─share
          └─frp # 默认安装目录 `FRP_INSTALL_DIR`
             ├─cache # 默认缓存目录 `FRP_CACHE_DIR`
             │  └─frp_0.57.0_linux_amd64.tar.gz
             ├─releases
             │  └─frp_0.57.0_linux_amd64
             │     ├─frpc
             │     └─frps
             ├─frpc -> ./releases/frp_0.57.0_linux_amd64/frpc
             ├─frps -> ./releases/frp_0.57.0_linux_amd64/frps
             └─frpm # 本应用实际存在的位置
```

## Todo

- [ ] 使用 Go 重构（编译为单文件可执行程序）
   1. 每次启动时自动检查 _frpm_ 更新情况（还是手动 `frpm update`？）
   2. 每次启动时自动检查 _frp_ 更新情况
   3. 下载最新版 _frp_ 到 `$FRP_CACHE_DIR` 并 **即时显示进度条**
   4. 下载完成后解压可执行文件（`frps` / `frpc`）到 `$FRP_INSTALL_DIR`
   5. 配置文件放在 `$FRP_CONFIG_DIR`
   6. 支持快速配置 `frpm config frpc "frps_host:frps_port?auth_token"`\
      （参考解析用正则 `^(?<host>[\w\.]+):(?<port>\d+)(\?(?<token>\w+))?$`）
   7. 运行 `frpm` 进入 TUI（交互式命令行界面）
   8. 运行 `frpm client` 直接运行 `frpc` 重定向 `stdout` 到当前窗口
   9. 运行 `frpm server --slient` 后台运行 `frps`
   10. 缓存目录 `$FRP_CACHE_DIR` & 配置目录 `$FRP_CONFIG_DIR` 可在 `$FRP_INSTALL_DIR/.env` 中手动配置\
      （安装目录 `$FRP_INSTALL_DIR` 只能使用环境变量）
