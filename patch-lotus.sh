#! /bin/bash

cd lotus/build

sed 's/var UpgradeWatermelonHeight = abi.ChainEpoch(200)/var UpgradeWatermelonHeight = abi.ChainEpoch(-24)/' params_2k.go > params_2k.go2
mv -f params_2k.go2 params_2k.go

sed 's/const GenesisNetworkVersion = network.Version20/const GenesisNetworkVersion = network.Version21/' params_2k.go > params_2k.go2
mv -f params_2k.go2 params_2k.go

