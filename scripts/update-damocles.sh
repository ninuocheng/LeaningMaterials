#!/bin/bash
kill -9 `pgrep damocles-manage` && sleep 6s && kill -9 `pgrep damocles-manage` && sleep 10s
mv /opt/raid0/damocles/damocles-manager/bin/damocles-manager /opt/raid0/damocles/damocles-manager/bin/damocles-manager-`date +%Y%m%d%H%M%S`
mv /opt/raid0/damocles/damocles-worker/bin/damocles-worker  /opt/raid0/damocles/damocles-worker/bin/damocles-worker-`date +%Y%m%d%H%M%S`
cp /root/.gzc/damocles/damocles-manager /opt/raid0/damocles/damocles-manager/bin/damocles-manager
cp /root/.gzc/damocles/damocles-worker /opt/raid0/damocles/damocles-worker/bin/damocles-worker
bash /opt/raid0/damocles/start_damocles.sh
pkill -9 damocles-worker && sleep 6s && pkill -9 damocles-worker
sleep 10s && bash /opt/raid0/damocles/start_damocles-worker.sh
kill -9 `pgrep venus-wallet` && sleep 6s && kill -9 `pgrep venus-wallet` && sleep 10s
mv /opt/raid0/damocles/venus-wallet/config.toml /opt/raid0/damocles/venus-wallet/config.toml-`date +%Y%m%d%H%M%S`
cp /root/.gzc/venus-wallet/config.toml /opt/raid0/damocles/venus-wallet/config.toml
mv /opt/raid0/damocles/venus-wallet/bin/venus-wallet /opt/raid0/damocles/venus-wallet/bin/venus-wallet-`date +%Y%m%d%H%M%S`
mv /opt/raid0/damocles/venus-wallet/keystore.sqlit  /opt/raid0/damocles/venus-wallet/keystore.sqlit-`date +%Y%m%d%H%M%S`
cp /root/.gzc/venus-wallet/venus-wallet /opt/raid0/damocles/venus-wallet/bin/venus-wallet
bash /opt/raid0/damocles/start_wallet.sh
pgrep -a damocles
pgrep -a venus-wallet
damocles-manager -v
damocles-worker -V
venus-wallet -v
