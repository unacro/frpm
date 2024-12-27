#/bin/bash

SCRIPT_VERSION="0.9.0"
AUTHOR="fatedier"
REPO_NAME="frp"
if [ -z "$FRP_CACHE_DIR" ]; then
    FRP_CACHE_DIR="/usr/local/lib/frp/cache"
fi
if [ -z "$FRP_INSTALL_DIR" ]; then
    FRP_INSTALL_DIR="/usr/local/lib/frp"
fi
FRP_BIN_PATH="/usr/local/bin"
if [ -z "$FRP_CONFIG_DIR" ]; then
    FRP_CONFIG_DIR="/usr/local/etc/frp"
fi

create_template() {
    if [[ ! -d "${FRP_CONFIG_DIR}/template" ]]; then
        mkdir -p "${FRP_CONFIG_DIR}/template"
    fi
    cat > "${FRP_CONFIG_DIR}/template/frpc_single_ssh.example.toml" << EOF
# frp Single Client Config

user = "$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)"
serverAddr = "{{ .Envs.FRPC_SERVER_ADDR }}"
serverPort = {{ .Envs.FRPC_SERVER_PORT }}
# auth.token = "xxx"

[[proxies]]
name = "ssh"
type = "tcp"
annotations = { usage = "SSH Proxy" }
localPort = 22
remotePort = 7022
EOF
    cat > "${FRP_CONFIG_DIR}/template/frpc.example.toml" << EOF
# frp Client Config

user = "$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)"
serverAddr = "{{ .Envs.FRPC_SERVER_ADDR }}"
serverPort = {{ .Envs.FRPC_SERVER_PORT }}
includes = [
    "${FRP_CONFIG_DIR}/conf.d/client/meta_web_server.toml",
    "${FRP_CONFIG_DIR}/conf.d/client/proxy_*.toml",
    "${FRP_CONFIG_DIR}/conf.d/client/visitor_*.toml"
] # default: only this config file
# start = [] # default: start all proxies

[auth]
# token = "xxx" # same auth.token with frp server IF exist
EOF
    cat > "${FRP_CONFIG_DIR}/template/frpc_tcp_proxies.example.toml" << EOF
# frp Client TCP Proxy Config

[[proxies]]
name = "a_tcp_proxy"
type = "tcp"
# annotations = { usage = "A Simple TCP Proxy" } # default: null
# localIP = "127.0.0.1" # default: 127.0.0.1
localPort = 80
remotePort = 8080
EOF
    cat > "${FRP_CONFIG_DIR}/template/frpc_stcp_proxies.example.toml" << EOF
# frp Client Secret TCP Proxy Config

[[proxies]]
name = "a_stcp_proxy"
type = "stcp"
# annotations = { usage = "A Secret TCP Proxy" } # default: null
# localIP = "127.0.0.1" # default: 127.0.0.1
localPort = 80
# secretKey = "$(openssl rand -base64 20 | tr -dc 'a-zA-Z0-9' | head -c 16)" # default: null
# allowUsers = ["*"] # default: only allow visitors from the same client user
EOF
    cat > "${FRP_CONFIG_DIR}/template/frpc_stcp_visitors.example.toml" << EOF
# frp Client Secret TCP Visitor Config

[[visitors]]
name = "a_stcp_visitor"
type = "stcp"
# secretKey = "" # same secretKey at stcp proxy IF exist
# serverUser = "" # default: current client user
serverName = "a_stcp_proxy"
# bindAddr = "127.0.0.1" # default: unknown
bindPort = -1
EOF
    cat > "${FRP_CONFIG_DIR}/template/frps.example.toml" << EOF
# frp Server Config
# bindAddr = "0.0.0.0" # default: 0.0.0.0
bindPort = 7000 # default: 7000

[auth]
# method = "token" # default: token (just string "token")
token = "$(openssl rand -base64 20 | tr -dc 'a-zA-Z0-9' | head -c 16)"
EOF
    cat > "${FRP_CONFIG_DIR}/template/meta_web_server.example.toml" << EOF
# frp Web Server Config

[webServer]
# addr = "127.0.0.1" # default: 127.0.0.1
port = 7001
# user = "admin"
# password = "$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 32)"
EOF
    cat > "${FRP_CONFIG_DIR}/template/frpc.example.service" << EOF
[Unit]
Description = frp(A Fast Reverse Proxy) Client
Documentation = https://gofrp.org/
After = network.target syslog.target
Wants = network.target

[Service]
Type = simple
Environment = "FRPC_SERVER_ADDR=192.168.1.1"
Environment = "FRPC_SERVER_PORT=7000"
ExecStart = ${FRP_INSTALL_DIR}/frpc -c ${FRP_CONFIG_DIR}/frpc.toml
ExecReload = ${FRP_INSTALL_DIR}/frpc reload -c ${FRP_CONFIG_DIR}/frpc.toml
WorkingDirectory = ${FRP_INSTALL_DIR}

[Install]
WantedBy = multi-user.target
EOF
    cat > "${FRP_CONFIG_DIR}/template/frps.example.service" << EOF
[Unit]
Description = frp(A Fast Reverse Proxy) Server
Documentation = https://gofrp.org/
After = network.target syslog.target
Wants = network.target

[Service]
Type = simple
ExecStart = ${FRP_INSTALL_DIR}/frps -c ${FRP_CONFIG_DIR}/frps.toml
ExecReload = ${FRP_INSTALL_DIR}/frps reload -c ${FRP_CONFIG_DIR}/frps.toml
WorkingDirectory = ${FRP_INSTALL_DIR}

[Install]
WantedBy = multi-user.target
EOF
}

init() {
    if [ ! command -v curl &> /dev/null || ! command -v jq &> /dev/null ]; then
        echo "请先安装依赖库 \033[1;36mcurl & jq\033[0m"
        sudo apt-get install -y curl jq
    fi
    mkdir -p "${FRP_CACHE_DIR}"
    mkdir -p "${FRP_INSTALL_DIR}"
    mkdir -p "${FRP_CONFIG_DIR}/conf.d/client"
    mkdir -p "${FRP_CONFIG_DIR}/conf.d/server"
    create_template
    if [ ! -f "${FRP_CONFIG_DIR}/frpc.toml" ]; then
        cp "${FRP_CONFIG_DIR}/template/frpc.example.toml" "${FRP_CONFIG_DIR}/frpc.toml"
    fi
    if [ ! -f "${FRP_CONFIG_DIR}/frps.toml" ]; then
        cp "${FRP_CONFIG_DIR}/template/frps.example.toml" "${FRP_CONFIG_DIR}/frps.toml"
    fi
}

reset_config() {
    cp -f "${FRP_CONFIG_DIR}/template/frpc.example.toml" "${FRP_CONFIG_DIR}/frpc.toml"
    cp -f "${FRP_CONFIG_DIR}/template/frps.example.toml" "${FRP_CONFIG_DIR}/frps.toml"
    echo "已重设配置文件: ${FRP_CONFIG_DIR} 下的 frps.toml / frpc.toml"
}

check_version() {
    latest_release_info=$(curl -s "https://api.github.com/repos/${AUTHOR}/${REPO_NAME}/releases/latest")
    latest_release_version=$(echo "$latest_release_info" | jq -r '.tag_name' | sed s/^v//)
}

relink() {
    latest_release_name=$(echo $latest_release_file | sed 's/\.tar\.gz$//')
    mkdir -p "${FRP_INSTALL_DIR}/releases"
    if [ -d "${FRP_INSTALL_DIR}/releases/${latest_release_name}" ]; then
        rm -rf "${FRP_INSTALL_DIR}/releases/${latest_release_name}"
    fi
    tar -xzvf "${FRP_CACHE_DIR}/${latest_release_file}" -C "${FRP_INSTALL_DIR}/releases"
    rm -f "${FRP_INSTALL_DIR}/frpc" "${FRP_INSTALL_DIR}/frps"
    ln -s ${FRP_INSTALL_DIR}/releases/${latest_release_name}/frps ${FRP_INSTALL_DIR}/frps
    ln -s ${FRP_INSTALL_DIR}/releases/${latest_release_name}/frpc ${FRP_INSTALL_DIR}/frpc
    rm -f "${FRP_BIN_PATH}/frpc" "${FRP_BIN_PATH}/frpm" "${FRP_BIN_PATH}/frps"
    ln -s ${FRP_INSTALL_DIR}/frpc ${FRP_BIN_PATH}/frpc
    ln -s ${FRP_INSTALL_DIR}/frpm ${FRP_BIN_PATH}/frpm
    ln -s ${FRP_INSTALL_DIR}/frps ${FRP_BIN_PATH}/frps
}

upgrade() {
    check_version
    download_url=$(echo "$latest_release_info" | jq -r ".assets | map(select(.name | contains(\"linux_$(dpkg --print-architecture)\"))) | .[0].browser_download_url")
    latest_release_file=$(basename $download_url)
    if [ -f "${FRP_CACHE_DIR}/${latest_release_file}" ]; then
        echo "Use cache ${FRP_CACHE_DIR}/${latest_release_file}"
    else
        wget -P "${FRP_CACHE_DIR}" "${GITHUB_PROXY_URL}${download_url}"
    fi
    if [ -f "${FRP_CACHE_DIR}/${latest_release_file}" ]; then
        relink
    else
        exit 1
    fi
    echo -e "Now \033[1;4;96mfrp\033[0m is \033[5;32mup to date\033[0m. Current version: \033[1;33m$(${FRP_INSTALL_DIR}/frpc -v)\033[0m"
}

install_service() {
    cp -f "${FRP_CONFIG_DIR}/template/frps.example.service" /etc/systemd/system/frps.service
    cp -f "${FRP_CONFIG_DIR}/template/frpc.example.service" /etc/systemd/system/frpc.service
    sudo systemctl daemon-reload
    echo "系统服务已安装完成"
    echo -e "- (退出本脚本后)运行 \033[1;36msystemctl start frpc\033[0m(或者 frps) 启动\033[1;33m后台服务\033[0m"
    echo -e "- (退出本脚本后)运行 \033[1;36msystemctl enable frpc\033[0m(或者 frps) 启用\033[1;33m开机自启\033[0m"
}

configure_client() {
    if [ ! -f "/etc/systemd/system/frpc.service" ]; then
        cp "${FRP_CONFIG_DIR}/template/frpc.example.service" /etc/systemd/system/frpc.service
    fi
    server_addr=$(awk -F= '/FRPC_SERVER_ADDR/ {gsub(/"/,"",$3); print $3}' /etc/systemd/system/frpc.service)
    server_port=$(awk -F= '/FRPC_SERVER_PORT/ {gsub(/"/,"",$3); print $3}' /etc/systemd/system/frpc.service)
    echo "当前指定的 frp 服务端: ${server_addr}:${server_port}"
    echo "请指定新的服务端地址:"
    read new_server_addr
    if [ -n "$new_server_addr" ]; then
        sed -i "s/FRPC_SERVER_ADDR=[^\"]*/FRPC_SERVER_ADDR=${new_server_addr}/" /etc/systemd/system/frpc.service
    fi
    echo "请指定新的服务端端口:"
    read new_server_port
    if [ -n "$new_server_port" ]; then
        sed -i "s/FRPC_SERVER_PORT=[^\"]*/FRPC_SERVER_PORT=${new_server_port}/" /etc/systemd/system/frpc.service
    fi
    sudo systemctl daemon-reload
    echo "请指定新的服务端验证密钥:"
    read new_server_token
    if [ -n "$new_server_token" ]; then
        # sed -i "s/^(auth\.|#)?\s*token\s*=.*$/token = ${new_server_token}/" "${FRP_CONFIG_DIR}/frpc.toml" # todo 严格正则未通过
        sed -i "/\[auth\]/{n;s/.*token\s*=.*/token = \"${new_server_token}\"/}" "${FRP_CONFIG_DIR}/frpc.toml"
    fi
    echo "已更新配置"
}

reload_client() {
    export FRPC_SERVER_ADDR="$(awk -F= '/FRPC_SERVER_ADDR/ {gsub(/"/,"",$3); print $3}' /etc/systemd/system/frpc.service)"
    export FRPC_SERVER_PORT="$(awk -F= '/FRPC_SERVER_PORT/ {gsub(/"/,"",$3); print $3}' /etc/systemd/system/frpc.service)"
    ${FRP_INSTALL_DIR}/frpc reload -c ${FRP_INSTALL_DIR}/frpc.toml
}

check_client() {
    export FRPC_SERVER_ADDR="$(awk -F= '/FRPC_SERVER_ADDR/ {gsub(/"/,"",$3); print $3}' /etc/systemd/system/frpc.service)"
    export FRPC_SERVER_PORT="$(awk -F= '/FRPC_SERVER_PORT/ {gsub(/"/,"",$3); print $3}' /etc/systemd/system/frpc.service)"
    ${FRP_INSTALL_DIR}/frpc status -c ${FRP_INSTALL_DIR}/frpc.toml
}

main() {
    divider=$(printf "%0.s=" $(seq 1 66))
    divider2=$(printf "%0.s*" $(seq 1 66))
    echo "${divider}"
    echo -e "一个简陋的 frp 工具脚本 v${SCRIPT_VERSION} by unacro"
    echo "frp - A Fast Reverse Proxy (https://gofrp.org)"
    echo "自动检查 frp 版本更新中..."
    check_version
    installed=$([[ -x "${FRP_INSTALL_DIR}/frpc" ]] && echo "\033[1;32m已安装\033[0m ($(${FRP_INSTALL_DIR}/frpc -v) $([[ "$(${FRP_INSTALL_DIR}/frpc -v)" = "${latest_release_version}" ]] && echo "\033[1;32m已是最新\033[0m" || echo "- \033[1;34m可以更新\033[0m ${latest_release_version}"))" || echo "\033[1;31m未安装\033[0m")
    echo -e "当前 frp 安装状态: ${installed}"
    frps_systemd_installed=$([[ -f "/etc/systemd/system/frps.service" ]] && echo "\033[1;32m已安装\033[0m" || echo "\033[1;33m未安装\033[0m")
    frpc_systemd_installed=$([[ -f "/etc/systemd/system/frpc.service" ]] && echo "\033[1;32m已安装\033[0m" || echo "\033[1;33m未安装\033[0m")
    echo -e "当前 frp 系统服务: 服务端${frps_systemd_installed} / 客户端${frpc_systemd_installed}"
    frps_running=$(pgrep -x "frps" >/dev/null && echo "\033[1;32m运行中\033[0m" || echo "\033[1;33m未运行\033[0m")
    frpc_running=$(pgrep -x "frpc" >/dev/null && echo "\033[1;32m运行中\033[0m" || echo "\033[1;33m未运行\033[0m")
    echo -e "当前 frp 运行状态: 服务端${frps_running} / 客户端${frpc_running}"
    init
    echo "${divider2}"
    options=(
        "更新应用版本"
        "安装系统服务"
        "修改配置文件"
        "重载配置文件"
        "查看代理状态"
        "重置配置文件"
        "退出当前脚本"
    )
    select choice in "${options[@]}"; do
        case $REPLY in
        1)
            upgrade
            ;;
        2)
            install_service
            ;;
        3)
            configure_client # 默认配置 frpc
            ;;
        4)
            reload_client # 默认重载 frpc
            ;;
        5)
            check_client # 只有客户端可以使用 status 命令查看代理运行状态
            ;;
        6)
            reset_config
            ;;
        7)
            echo "886"
            break
            ;;
        *)
            echo "无效选项，请重新选择"
            ;;
        esac
        echo "${divider2}"
    done
    echo "${divider}"
}

main
