# PryzmSetupTheNode
Обзор проекта Pryzm + инструкция по установке

```
sudo apt update && sudo apt upgrade -y
```

```
sudo apt install dos2unix
```

```
wget https://raw.githubusercontent.com/Mozgiii9/PryzmSetupTheNode/main/pryzm.sh && chmod +x pryzm.sh && dos2unix pryzm.sh
```

```
bash pryzm.sh
```

Как только пошли логи, нажимаем комбинацию CTRL+C для выхода из режима отображения логов.

Ставим последние апдейты:

```
cd $HOME
```

```
wget -O pryzmd https://storage.googleapis.com/pryzm-zone/core/0.13.0/pryzmd-0.13.0-linux-amd64
```

```
chmod +x $HOME/pryzmd
```

```
sudo mv $HOME/pryzmd $(which pryzmd)
```

```
sudo systemctl restart pryzmd && sudo journalctl -u pryzmd -f
```

Создаем кошелек. "$WALLET" замените на имя кошелька, которое Вы присвоили в Bash-скрипте:

```
pryzmd keys add $WALLET
```

```
WALLET_ADDRESS=$(pryzmd keys show $WALLET -a)
```

```
VALOPER_ADDRESS=$(pryzmd keys show $WALLET --bech val -a)
```
