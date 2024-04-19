![image](https://github.com/Mozgiii9/PryzmSetupTheNode/assets/74683169/1fbfcd0e-ec3e-439a-9c40-740cc8524975)

# Pryzm

## Дата создания гайда: 19.04.2024.

### Описание проекта:

**[Pryzm](https://pryzm.zone/) — это блокчейн L1, предназначенный для оптимизации доходности. Проект предлагает широкий спектр функций, в том числе: LSD, токенизацию доходности, полномочия по управлению ликвидностью, DEX доходности, подтверждение ликвидности и многое другое.**

**Информация об инвестициях:**

Официальную информацию не нашел, но на Twitter подписаны фаундеры a16z и другие фаундеры известных фондов.

**Официальные ресурсы:**

- Веб-сайт : [перейти](https://pryzm.zone/)
- Twitter : [перейти](https://twitter.com/Pryzm_Zone)
- Discord : [перейти](http://discord.gg/sJN5Q2DBcP)
- Medium : [перейти](https://pryzm.medium.com/)
- Docs : [перейти](https://docs.pryzm.zone/)
- Telegram : [перейти](https://t.me/pryzm_zone)
- Официальный гайд по установке ноды : [перейти](https://docs.pryzm.zone/overview/maintain-guides/run-node/running-pryzmd/)
- Ссылка на кран : [перейти](https://testnet.pryzm.zone/faucet)
- Ссылка на эксплорер : [перейти](https://testnet.chainsco.pe/pryzm/validators)

**Требования к серверу:**

- *CPU : 4 CORES 2.5 GHz;*
- *RAM : 8 GB;*
- *Storage : 500 GB SSD NVME;*
- *OS : Ubuntu 20.04 / Ubuntu 22.04* 

### Инструкция по установке ноды:

**1. Обновляем пакеты:**
```
sudo apt update && sudo apt upgrade -y
```

**2. Устанавливаем Bash-скрипт:**
```
source <(curl -s https://itrocket.net/api/testnet/pryzm/autoinstall/)
```

**3. Заполняем имя кошелька, имя ноды(moniker'a), ставим дефолтный порт(26). Скрипт начнет уставливать ПО ноды.**

**4. Как только пошли логи, нажимаем комбинацию CTRL+C для выхода из режима отображения логов.**

**5. Ставим последние апдейты:**

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

**Пойдут логи, так же выходим из них комбинациях CTRL+C.**

**6. Проверяем статус синхронизации ноды. Ждем, когда значение "catching_up" изменится с "true" на "false":**

```
pryzmd status 2>&1 | jq .SyncInfo
```

**7. Как только "catching_up" изменился на "false", переходим к созданию кошелька. "$WALLET" замените на имя кошелька, которое Вы присвоили в Bash-скрипте:**

```
pryzmd keys add $WALLET
```

**Создаем passpharse(пароль Вашего кошелька). Вводим его два раза, после чего сохраняем адрес кошелька, а также seed-фразу(mnemonic phrase) в надежное место.**

**8. Далее исполняем такую команду. "$WALLET" замените на имя Вашего кошелька:**
```
WALLET_ADDRESS=$(pryzmd keys show $WALLET -a)
```

**9. Также меняем "$WALLET" на имя Вашего кошелька. Вводим passphrase:**

```
VALOPER_ADDRESS=$(pryzmd keys show $WALLET --bech val -a)
```

**10. Перед созданием валидатора еще раз проверим статус синхронизации ноды:**

```
pryzmd status 2>&1 | jq .SyncInfo
```

**11. Переходим в [кран](https://testnet.pryzm.zone/faucet), запрашиваем токены.**

**12. После получения создадим валидатора. Для этого введем такую команду:**

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

**Замените следующие значения на собственные:**

*- "moniker" : Укажите в кавычках имя вашей ноды, которое Вы указывали в момент запуска Bash-скрипта;*

*- "details" : Укажите любое описание. Можно оставить как в примере.*

**13. Вводим пароль от кошелька, транзакция должна успешно выполниться. Копируем хэш транзакции, который вернул сервер и переходим в [эксплорер](https://testnet.chainsco.pe/pryzm/validators)**

**ВАЖНО: Ваш валидатор будет иметь статус "inactive". Для того, чтобы Ваш валидатор поменял статус на "active" Вам необходимо начать делегировать токены другим валидаторам, а также сделать так, чтобы Вам тоже делегировали токены. Для этого можно перейти в Discord проекта и попросить делегировать токены на адрес Вашего валидатора. Узнать адрес валидатора можно в эксплорере.**

**Шпаргалка по командам:**

**1. Проверка логов:**

```
sudo journalctl -u pryzmd -f
```

**2. Проверка синхронизации ноды:**

```
pryzmd status 2>&1 | jq .SyncInfo
```

**3. Проверка информации ноды:**

```
pryzmd status 2>&1 | jq .NodeInfo
```

**4.  Перезапуск сервиса:**

```
sudo systemctl restart pryzmd
```

**5. Восстановление кошелька:**

```
pryzmd keys add $WALLET --recover
```

**6. Получить список доступных кошельков:**

```
pryzmd keys list
```

**7. Проверка баланса:**

```
pryzmd q bank balances $(pryzmd keys show $WALLET -a)
```

**8. Информация о валидаторе:**

```
pryzmd status 2>&1 | jq .ValidatorInfo
```

**9. Информация о тюрьме:**

```
pryzmd q slashing signing-info $(pryzmd tendermint show-validator)
```

**10. Вывести валидатора из тюрьмы:**

```
pryzmd tx slashing unjail --from $WALLET --chain-id indigo-1 --fees 3000upryzm -y
```

**11. Можно поставить автоапдейт. Не выходите из логов, иначе скрипт прекратит работу:**

```
cd $HOME && \
wget -O pryzmd https://storage.googleapis.com/pryzm-zone/core/0.13.0/pryzmd-0.13.0-linux-amd64 && \
chmod +x $HOME/pryzmd && \
old_bin_path=$(which pryzmd) && \
home_path=$HOME && \
rpc_port=$(grep -m 1 -oP '^laddr = "\K[^"]+' "$HOME/.pryzm/config/config.toml" | cut -d ':' -f 3) && \
tmux new -s pryzm-upgrade "sudo bash -c 'curl -s https://raw.githubusercontent.com/itrocket-team/testnet_guides/main/utils/autoupgrade/upgrade.sh | bash -s -- -u \"1865300\" -b pryzmd -n \"$HOME/pryzmd\" -o \"$old_bin_path\" -h \"$home_path\" -p \"https://pryzm-testnet-api.itrocket.net/cosmos/gov/v1/proposals/449\" -r \"$rpc_port\"'"
```

**12. Делегировать токены самому себе:**

```
pryzmd tx staking delegate $(pryzmd keys show $WALLET --bech val -a) 1000000upryzm --from $WALLET --chain-id indigo-1 --fees 3000upryzm -y
```

**13. Делегировать токены другому валидатору. Замените <TO_VALOPER_ADDRESS> на адрес валидатора, которому хотите длегировать токены:**

```
pryzmd tx staking delegate <TO_VALOPER_ADDRESS> 1000000upryzm --from $WALLET --chain-id indigo-1 --fees 3000upryzm -y
```

### Обязательно проведите собственный ресерч проектов перед тем как ставить ноду. Сообщество NodeRunner не несет ответственность за Ваши действия и средства. Помните, проводя свой ресёрч, Вы учитесь и развиваетесь.

### Связь со мной: [Telegram(@M0zgiii)](https://t.me/m0zgiii)

### Мои соц. сети: [Twitter](https://twitter.com/m0zgiii) 
