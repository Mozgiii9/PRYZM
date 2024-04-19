# PryzmSetupTheNode
Обзор проекта Pryzm + инструкция по установке


1. Обновляем пакеты:
```
sudo apt update && sudo apt upgrade -y
```

2. Устанавливаем Bash-скрипт:
```
source <(curl -s https://itrocket.net/api/testnet/pryzm/autoinstall/)
```

3. Заполняем имя кошелька, имя ноды(moniker'a), ставим дефолтный порт(26). Скрипт начнет уставливать ПО ноды.

4. Как только пошли логи, нажимаем комбинацию CTRL+C для выхода из режима отображения логов.

5. Ставим последние апдейты:

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

Пойдут логи, так же выходим из них комбинациях CTRL+C.

6. Проверяем статус синхронизации ноды. Ждем, когда значение "catching_up" изменится с "true" на "false":

```
pryzmd status 2>&1 | jq .SyncInfo
```

7. Как только "catching_up" изменился на "false", переходим к созданию кошелька. "$WALLET" замените на имя кошелька, которое Вы присвоили в Bash-скрипте:

```
pryzmd keys add $WALLET
```

Создаем passpharse(пароль Вашего кошелька). Вводим его два раза, псоле чего сохраняем адрес кошелька, а также seed-фразу(mnemonic phrase).

8. Далее исполняем такую команду. "$WALLET" замените на имя Вашего кошелька:
```
WALLET_ADDRESS=$(pryzmd keys show $WALLET -a)
```

9. Также меняем "$WALLET" на имя Вашего кошелька. Вводим passphrase:

```
VALOPER_ADDRESS=$(pryzmd keys show $WALLET --bech val -a)
```

10. Перед созданием валидатора еще раз проверим статус синхронизации ноды:

```
pryzmd status 2>&1 | jq .SyncInfo
```

11. Переходим в кран, запрашиваем токены.

12. После получения токенов мы можем делегировать их самому себе. Для этого введем такую команду:

```
pryzmd tx staking create-validator \
--amount 1000000upryzm \
--from $WALLET \
--commission-rate 0.1 \
--commission-max-rate 0.2 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--pubkey $(pryzmd tendermint show-validator) \
--moniker "moniker1" \
--identity "" \
--details "I love blockchain" \
--chain-id indigo-1 \
--fees 3000upryzm \
-y
```

Замените следующие значения на собственные:
- "moniker" : Укажите в кавычках имя вашей ноды, которое Вы указывали в момент запуска Bash-скрипта;
- "details" : Укажите любое описание. Можно оставить как в примере.

Шпаргалка по командам:

1. Проверка логов:

```
sudo journalctl -u pryzmd -f
```

2. Проверка синхронизации ноды:

```
pryzmd status 2>&1 | jq .SyncInfo
```

3. Проверка информации ноды:

```
pryzmd status 2>&1 | jq .NodeInfo
```

4.  Перезапуск сервиса:

```
sudo systemctl restart pryzmd
```

5. Восстановление кошелька:

```
pryzmd keys add $WALLET --recover
```

6. Получить список доступных кошельков:

```
pryzmd keys list
```

7. Проверка баланса:

```
pryzmd q bank balances $(pryzmd keys show $WALLET -a)
```

8. Информация о валидаторе:

```
pryzmd status 2>&1 | jq .ValidatorInfo
```

9. Информация о тюрьме:

```
pryzmd q slashing signing-info $(pryzmd tendermint show-validator)
```

10. Вывести валидатора из тюрьмы:

```
pryzmd tx slashing unjail --from $WALLET --chain-id indigo-1 --fees 3000upryzm -y
```

11. Можно поставить автоапдейт. Не выходите из логов:

```
cd $HOME && \
wget -O pryzmd https://storage.googleapis.com/pryzm-zone/core/0.13.0/pryzmd-0.13.0-linux-amd64 && \
chmod +x $HOME/pryzmd && \
old_bin_path=$(which pryzmd) && \
home_path=$HOME && \
rpc_port=$(grep -m 1 -oP '^laddr = "\K[^"]+' "$HOME/.pryzm/config/config.toml" | cut -d ':' -f 3) && \
tmux new -s pryzm-upgrade "sudo bash -c 'curl -s https://raw.githubusercontent.com/itrocket-team/testnet_guides/main/utils/autoupgrade/upgrade.sh | bash -s -- -u \"1865300\" -b pryzmd -n \"$HOME/pryzmd\" -o \"$old_bin_path\" -h \"$home_path\" -p \"https://pryzm-testnet-api.itrocket.net/cosmos/gov/v1/proposals/449\" -r \"$rpc_port\"'"
