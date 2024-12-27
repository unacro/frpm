#!/bin/bash

APP_PATH="/usr/local/lib/frp"
mkdir -p "${APP_PATH}"
rm -f "${APP_PATH}/frpm"
cat > "${APP_PATH}/frpm" << EOF
#!/bin/bash

bash ${PWD}/prototype.sh
EOF
chmod +x "${APP_PATH}/frpm"
echo -e "frpm installed at \033[1;32m${APP_PATH}/frpm\033[0m"
