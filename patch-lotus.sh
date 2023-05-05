#! /bin/bash

cd lotus/build

sed 's/var UpgradeLightningHeight = abi.ChainEpoch(30)/var UpgradeLightningHeight = abi.ChainEpoch(-22)/' params_2k.go > params_2k.go2
mv -f params_2k.go2 params_2k.go

sed 's/var UpgradeThunderHeight = abi.ChainEpoch(1000)/var UpgradeThunderHeight = abi.ChainEpoch(-23)/' params_2k.go > params_2k.go2
mv -f params_2k.go2 params_2k.go

sed 's/const GenesisNetworkVersion = network.Version18/const GenesisNetworkVersion = network.Version20/' params_2k.go > params_2k.go2
mv -f params_2k.go2 params_2k.go

