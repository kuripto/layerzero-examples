// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;


import "../token/onft/ONFT721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract LZO is ONFT721 {
    uint256 public nextMintId;
    uint256 public maxMintId;
    mapping (uint256 => uint256) imageIndex;

    constructor(uint256 _minGasToStore, address _layerZeroEndpoint, uint _startMintId, uint _endMintId) ONFT721("LayerZeroOsawari", "LZO", _minGasToStore, _layerZeroEndpoint) {
        nextMintId = _startMintId;
        maxMintId = _endMintId;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{',
                        '"name": "LZO #', Strings.toString(tokenId), '",',
                        '"description": "I love LayerZero",',
                        '"image": "https://kuripto.github.io/nft/lzo/png/', Strings.toString(imageIndex[tokenId]), '.png"'
                        '}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function mint(uint256 amount) external {
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

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64, /*_nonce*/
        bytes memory _payload
    ) internal virtual override {
        // decode and load the toAddress
        (bytes memory toAddressBytes, uint[] memory tokenIds) = abi.decode(_payload, (bytes, uint[]));

        address toAddress;
        assembly {
            toAddress := mload(add(toAddressBytes, 20))
        }

        uint nextIndex = _creditTill(_srcChainId, toAddress, 0, tokenIds);
        if (nextIndex < tokenIds.length) {
            // not enough gas to complete transfers, store to be cleared in another tx
            bytes32 hashedPayload = keccak256(_payload);
            storedCredits[hashedPayload] = StoredCredit(_srcChainId, toAddress, nextIndex, true);
            emit CreditStored(hashedPayload, _payload);
        }

        for (uint256 i = 0; i < tokenIds.length; ++i) {
            uint256 num = uint256(keccak256(abi.encodePacked(blockhash(block.number-1), tokenIds[i]))) % 100;
            if (num < 10) {
                imageIndex[tokenIds[i]] = 0;
            } else if (num < 20) {
                imageIndex[tokenIds[i]] = 1;
            } else if (num < 30) {
                imageIndex[tokenIds[i]] = 2;
            } else if (num < 39) {
                imageIndex[tokenIds[i]] = 3;
            } else if (num < 47) {
                imageIndex[tokenIds[i]] = 4;
            } else if (num < 55) {
                imageIndex[tokenIds[i]] = 5;
            } else if (num < 63) {
                imageIndex[tokenIds[i]] = 6;
            } else if (num < 70) {
                imageIndex[tokenIds[i]] = 7;
            } else if (num < 76) {
                imageIndex[tokenIds[i]] = 8;
            } else if (num < 82) {
                imageIndex[tokenIds[i]] = 9;
            } else if (num < 88) {
                imageIndex[tokenIds[i]] = 10;
            } else if (num < 93) {
                imageIndex[tokenIds[i]] = 11;
            } else if (num < 95) {
                imageIndex[tokenIds[i]] = 12;
            } else if (num < 97) {
                imageIndex[tokenIds[i]] = 13;
            } else if (num < 99) {
                imageIndex[tokenIds[i]] = 14;
            } else if (num < 100) {
                imageIndex[tokenIds[i]] = 15;
            }

        }

        emit ReceiveFromChain(_srcChainId, _srcAddress, toAddress, tokenIds);
    }

}
