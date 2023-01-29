#! /bin/bash

cd lotus/build

sed 's/var UpgradeHyggeHeight = abi.ChainEpoch(30)/var UpgradeHyggeHeight = abi.ChainEpoch(-21)/' params_2k.go > params_2k.go2
mv -f params_2k.go2 params_2k.go

sed 's/const GenesisNetworkVersion = network.Version17/const GenesisNetworkVersion = network.Version18/' params_2k.go > params_2k.go2
mv -f params_2k.go2 params_2k.go
