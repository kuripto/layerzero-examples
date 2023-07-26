const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json")
const LZO_CONFIG = require("../constants/lzoConfig.json")

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
    console.log(`>>> your address: ${deployer}`)

    const lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]
    const lzoConfig = LZO_CONFIG[hre.network.name]
    console.log({ lzoConfig })
    console.log(`[${hre.network.name}] LayerZero Endpoint address: ${lzEndpointAddress}`)

    await deploy("LZO", {
        from: deployer,
        args: [150000, lzEndpointAddress, lzoConfig.startMintId, lzoConfig.endMintId],
        log: true,
        waitConfirmations: 1,
    })
}

module.exports.tags = ["LZO"]
