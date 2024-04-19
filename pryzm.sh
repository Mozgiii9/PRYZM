#!/bin/bash

echo -e '\e[40m\e[92m'
echo -e '███╗   ██╗ ██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗'
echo -e '████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗'
echo -e '██╔██╗ ██║██║   ██║██║  ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝'
echo -e '██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗'
echo -e '██║ ╚████║╚██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║'
echo -e '╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝'
echo -e '\e[0m'

sleep 2

read -p "Enter WALLET name: " WALLET
echo 'export WALLET='$WALLET
read -p "Enter your MONIKER: " MONIKER
echo 'export MONIKER='$MONIKER
read -p "Enter your PORT (for example 17, default port=26): " PORT
echo 'export PORT='$PORT

# set vars
echo "export WALLET="$WALLET"" >> $HOME/.bash_profile
echo "export MONIKER="$MONIKER"" >> $HOME/.bash_profile
echo "export PRYZM_CHAIN_ID="indigo-1"" >> $HOME/.bash_profile
echo "export PRYZM_PORT="$PORT"" >> $HOME/.bash_profile
source $HOME/.bash_profile

printLine
echo -e "Moniker :        \e[1m\e[32m$MONIKER\e[0m"
echo -e "Wallet :         \e[1m\e[32m$WALLET\e[0m"
echo -e "Chain id :       \e[1m\e[32m$PRYZM_CHAIN_ID\e[0m"
echo -e "Node custom port :  \e[1m\e[32m$PRYZM_PORT\e[0m"
printLine
sleep 1

printGreen "1. Installing go..." && sleep 1
# install go, if needed
cd $HOME
VER="1.20.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin

echo $(go version) && sleep 1

source <(curl -s https://raw.githubusercontent.com/itrocket-team/testnet_guides/main/utils/dependencies_install)

printGreen "4. Installing binary..." && sleep 1
# download binary
cd $HOME
wget https://storage.googleapis.com/pryzm-zone/core/0.13.0/pryzmd-0.13.0-linux-amd64.tar.gz
tar -xzvf $HOME/pryzmd-0.13.0-linux-amd64.tar.gz
mv pryzmd $HOME/go/bin

printGreen "5. Configuring and init app..." && sleep 1
# config and init app
pryzmd config node tcp://localhost:${PRYZM_PORT}657
pryzmd config keyring-backend os
pryzmd config chain-id indigo-1
pryzmd init "$MONIKER" --chain-id indigo-1
sleep 1
echo done

printGreen "6. Downloading genesis and addrbook..." && sleep 1
# download genesis and addrbook
wget -O $HOME/.pryzm/config/genesis.json https://testnet-files.itrocket.net/pryzm/genesis.json
wget -O $HOME/.pryzm/config/addrbook.json https://testnet-files.itrocket.net/pryzm/addrbook.json
sleep 1
echo done

printGreen "7. Adding seeds, peers, configuring custom ports, pruning, minimum gas price..." && sleep 1
# set seeds and peers
SEEDS="fbfd48af73cd1f6de7f9102a0086ac63f46fb911@pryzm-testnet-seed.itrocket.net:41656"
PEERS="713307ce72306d9e86b436fc69a03a0ab96b678f@pryzm-testnet-peer.itrocket.net:41656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.pryzm/config/config.toml

# set custom ports in app.toml
sed -i.bak -e "s%:1317%:${PRYZM_PORT}317%g;
s%:8080%:${PRYZM_PORT}080%g;
s%:9090%:${PRYZM_PORT}090%g;
s%:9091%:${PRYZM_PORT}091%g;
s%:8545%:${PRYZM_PORT}545%g;
s%:8546%:${PRYZM_PORT}546%g;
s%:6065%:${PRYZM_PORT}065%g" $HOME/.pryzm/config/app.toml


# set custom ports in config.toml file
sed -i.bak -e "s%:26658%:${PRYZM_PORT}658%g;
s%:26657%:${PRYZM_PORT}657%g;
s%:6060%:${PRYZM_PORT}060%g;
s%:26656%:${PRYZM_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${PRYZM_PORT}656\"%;
s%:26660%:${PRYZM_PORT}660%g" $HOME/.pryzm/config/config.toml

# config pruning
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.pryzm/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.pryzm/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.pryzm/config/app.toml

# set minimum gas price, enable prometheus and disable indexing
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.015upryzm"|g' $HOME/.pryzm/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.pryzm/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.pryzm/config/config.toml
sleep 1
echo done

# create service file
sudo tee /etc/systemd/system/pryzmd.service > /dev/null <<EOF
[Unit]
Description=pryzm node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.pryzm
ExecStart=$(which pryzmd) start --home $HOME/.pryzm
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

printGreen "8. Downloading snapshot and starting node..." && sleep 1
# reset and download snapshot
pryzmd tendermint unsafe-reset-all --home $HOME/.pryzm
if curl -s --head curl https://testnet-files.itrocket.net/pryzm/snap_pryzm.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
  curl https://testnet-files.itrocket.net/pryzm/snap_pryzm.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.pryzm
    else
  echo no have snap
fi

# enable and start service
sudo systemctl daemon-reload
sudo systemctl enable pryzmd
sudo systemctl restart pryzmd && sudo journalctl -u pryzmd -f
