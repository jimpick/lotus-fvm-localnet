#! /bin/bash

cd lotus/build

perl -pi \
  -e 's/var UpgradeLightningHeight = abi.ChainEpoch\(30\)/var UpgradeLightningHeight = abi.ChainEpoch(-22)/;' \
  -e 's/var UpgradeThunderHeight = abi.ChainEpoch\(1000\)/var UpgradeThunderHeight = abi.ChainEpoch(-23)/;' \
  -e 's/const GenesisNetworkVersion = network.Version18/const GenesisNetworkVersion = network.Version20/;' \
  params_2k.go
