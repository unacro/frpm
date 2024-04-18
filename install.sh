#!/bin/bash

APP_PATH="/usr/local/share/frp"
mkdir -p "${APP_PATH}"
rm -f "${APP_PATH}/frpm"
ln -s "${PWD}/prototype.sh" "${APP_PATH}/frpm"
chmod +x "${APP_PATH}/frpm"
echo -e "frpm installed at \033[1;32m${APP_PATH}/frpm\033[0m"
