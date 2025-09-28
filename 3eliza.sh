#!/bin/bash

start=${1:-7} 

# 1. Установка git и curl (без вопросов)
sudo apt update
sudo apt install -y git curl build-essential

# 2. Установка nvm и загрузка в этот скрипт
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 3. Установка Node через nvm
nvm install v23.9.0
nvm use v23.9.0

# 4. Установка pnpm
curl -fsSL https://get.pnpm.io/install.sh | sh -

export PATH="$PATH:$HOME/.local/share/pnpm"
source ~/.bashrc

# 5. pm2 глобально
npm install pm2 -g


sudo fallocate -l 20G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
swapon --show
free -h


# 6. Цикл
for i in $(seq $start $((start+2)))
do
    git clone --depth=1 https://github.com/elizaos/eliza.git --branch v0.25.9
    cd eliza
    git clone https://github.com/elizaos-plugins/client-twitter.git packages/client-twitter
    git clone https://github.com/elizaos-plugins/plugin-giphy.git packages/plugin-giphy
    pnpm install --no-frozen-lockfile
    pnpm add @elizaos/core@workspace:* --filter ./packages/client-twitter
    pnpm add @elizaos-plugins/client-twitter@workspace:* --filter ./agent
    pnpm add @elizaos/core@workspace:* --filter ./packages/plugin-giphy
    pnpm add @elizaos-plugins/plugin-giphy@workspace:* --filter ./agent
    pnpm build
    cd ..
    mv eliza hool$i
done
