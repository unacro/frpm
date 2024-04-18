#!/bin/bash

APP_PATH="/usr/local/bin/frpm"
rm -f "${APP_PATH}"
ln -s "${PWD}/prototype.sh" "${APP_PATH}"
chmod +x "${APP_PATH}"
