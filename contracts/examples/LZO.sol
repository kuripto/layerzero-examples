// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;


import "../token/onft/extension/UniversalONFT721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract LZO is UniversalONFT721 {
    constructor(uint256 _minGasToStore, address _layerZeroEndpoint, uint _startMintId, uint _endMintId) UniversalONFT721("LayerZeroOsawari", "LZO", _minGasToStore, _layerZeroEndpoint, _startMintId, _endMintId) {}

    function generateSVG(uint256 tokenId) public view returns(string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 350 350">',
            '<text y="30">', "ChainID: ", Strings.toString(lzEndpoint.getChainId()), '</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }

    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{',
                        '"name": "LZO #', Strings.toString(tokenId), '",',
                        '"description": "I love LayerZero",',
                        '"image": "', generateSVG(tokenId), '"'
                        '}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function mint(uint256 amount) external payable {
        require(nextMintId + amount <= maxMintId, "LZO: max mint limit reached");

        for (uint256 i = 0; i < amount; i++) {
            uint newId = nextMintId;
            nextMintId++;
            _safeMint(msg.sender, newId);
        }
    }

    function sendMultiChain(uint16[] calldata _dstChainIds, uint[] calldata _tokenIds) public payable {
        for (uint16 i = 0; i < _dstChainIds.length; i++) {
            uint16 dstChainId = _dstChainIds[i];
            bytes memory adapterParams = hex"00010000000000000000000000000000000000000000000000000000000000030d40";

            bytes memory toAddress = abi.encodePacked(msg.sender);

            _debitFrom(msg.sender, dstChainId, toAddress, _tokenIds[i]);

            bytes memory payload = abi.encode(toAddress, _toSingletonArray(_tokenIds[i]));

            _checkGasLimit(dstChainId, FUNCTION_TYPE_SEND, adapterParams, dstChainIdToTransferGas[dstChainId]);
            _lzSend(dstChainId, payload, payable(msg.sender), 0x0000000000000000000000000000000000000000, adapterParams, msg.value/_dstChainIds.length);
            emit SendToChain(dstChainId, msg.sender, toAddress, _toSingletonArray(_tokenIds[i]));
        }
    }

    function estimateSendMultiChainFee(uint16[] calldata _dstChainIds, uint[] memory _tokenIds, bool _useZro) public view virtual returns (uint nativeFee, uint zroFee) {
        bytes memory toAddress = abi.encodePacked(msg.sender);
        bytes memory payload = abi.encode(toAddress, _tokenIds);
        for (uint16 i = 0; i < _dstChainIds.length; i++) {
            (uint nfee, uint zfee) = lzEndpoint.estimateFees(_dstChainIds[i], address(this), payload, _useZro, hex"00010000000000000000000000000000000000000000000000000000000000030d40");
            nativeFee += nfee;
            zroFee += zfee;
        }
    }

}
