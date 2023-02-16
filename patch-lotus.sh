#! /bin/bash

cd lotus/build

sed 's/var UpgradeHyggeHeight = abi.ChainEpoch(30)/var UpgradeHyggeHeight = abi.ChainEpoch(-21)/' params_2k.go > params_2k.go2
mv -f params_2k.go2 params_2k.go

sed 's/var UpgradeHyperspaceNV19Height = abi.ChainEpoch(60)/var UpgradeHyperspaceNV19Height = abi.ChainEpoch(-22)/' params_2k.go > params_2k.go2
mv -f params_2k.go2 params_2k.go

sed 's/var UpgradeHyperspaceNV20Height = abi.ChainEpoch(120)/var UpgradeHyperspaceNV20Height = abi.ChainEpoch(-23)/' params_2k.go > params_2k.go2
mv -f params_2k.go2 params_2k.go

sed 's/const GenesisNetworkVersion = network.Version17/const GenesisNetworkVersion = network.Version20/' params_2k.go > params_2k.go2
mv -f params_2k.go2 params_2k.go
