# frpm - frp Manager

- [Source Code](https://github.com/fatedier/frp)
- [Documentation](https://gofrp.org/)

```goat
/etc
  frp 默认配置目录 `FRP_CONFIG_DIR`
    conf.d
      client
        meta_web_server.toml
        proxy_other.toml
        proxy_ssh.toml
        proxy_web.toml
      server
        meta_web_server.toml
    template
      frpc.example.toml
      frpc_single_ssh.example.toml
      frpc_tcp_proxies.example.toml
      frpc_stcp_proxies.example.toml
      frpc_stcp_visitors.example.toml
      frpc.example.service
      frps.example.toml
      frps.example.service
      meta_web_server.example.toml
    frpc.toml
    frps.toml
/usr
  bin
      frpc -> ../share/frp/frpc
      frpm -> ../share/frp/frpm
      frps -> ../share/frp/frps
  share
    frp 默认安装目录 `FRP_INSTALL_DIR`
      cache 默认缓存目录 `FRP_CACHE_DIR`
        frp_0.57.0_linux_amd64.tar.gz
      releases
        frp_0.57.0_linux_amd64
          frpc
          frps
      frpc -> ./releases/frp_0.57.0_linux_amd64/frpc
      frps -> ./releases/frp_0.57.0_linux_amd64/frps
      frpm
```
