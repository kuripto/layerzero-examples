#!/bin/bash

npx hardhat --network goerli deploy --tags LZO
npx hardhat --network bsc-testnet deploy --tags LZO
npx hardhat --network fuji deploy --tags LZO
npx hardhat --network mantle-testnet verifyContract --contract LZO

npx hardhat --network goerli verifyContract --contract LZO 
# npx hardhat --network bsc-testnet verifyContract --contract LZO 
npx hardhat --network mantle-testnet verifyContract --contract LZO

npx hardhat --network goerli setTrustedRemote --target-network bsc-testnet --contract LZO
npx hardhat --network goerli setTrustedRemote --target-network fuji --contract LZO
npx hardhat --network bsc-testnet setTrustedRemote --target-network goerli --contract LZO
npx hardhat --network bsc-testnet setTrustedRemote --target-network fuji --contract LZO
npx hardhat --network fuji setTrustedRemote --target-network goerli --contract LZO
npx hardhat --network fuji setTrustedRemote --target-network bsc-testnet --contract LZO

npx hardhat --network goerli setMinDstGas --target-network bsc-testnet --contract LZO --packet-type 1 --min-gas 100000
npx hardhat --network goerli setMinDstGas --target-network fuji --contract LZO --packet-type 1 --min-gas 100000