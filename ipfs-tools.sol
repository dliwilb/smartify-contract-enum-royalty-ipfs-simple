// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

library IPFSTools {

	// function stringToBytes32(string memory _string) public pure returns (bytes32 result) {
	// 	bytes memory tempEmptyStringTest = bytes(_string);
	// 	if (tempEmptyStringTest.length == 0) {
	// 		return 0x0;
	// 	}

	// 	assembly {
	// 		result := mload(add(_string, 32))
	// 	}
	// }

	function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    // function bytesToPackedString(bytes memory _bytes) public pure returns (string memory) {
	// 	return string(abi.encodePacked(_bytes));
	// }

    // function bytesToString(bytes memory _bytes) public pure returns (string memory) {
	// 	return string(_bytes);
	// }

    // function stringToBytes(string memory _string) public pure returns (bytes memory) {
    //     return bytes(_string);

    // }

	function getIpfsGateway(uint8 _ipfsGatewayId) public pure returns (bytes32) {
		uint256[5] memory ipfsGateways = [
			0x697066732e696f2f697066730000000000000000000000000000000000000000,
			0x676174657761792e697066732e696f2f69706673000000000000000000000000,
			0x696e667572612d697066732e696f2f6970667300000000000000000000000000,
			0x676174657761792e70696e6174612e636c6f75642f6970667300000000000000,
			0x636c6f7564666c6172652d697066732e636f6d2f697066730000000000000000
		];
            // bytes32 constant ipfsGateway1 = 0x697066732e696f2f697066730000000000000000000000000000000000000000;
            // bytes32 constant ipfsGateway2 = 0x676174657761792e697066732e696f2f69706673000000000000000000000000;
            // bytes32 constant ipfsGateway3 = 0x696e667572612d697066732e696f2f6970667300000000000000000000000000;
            // bytes32 constant ipfsGateway4 = 0x676174657761792e70696e6174612e636c6f75642f6970667300000000000000;
            // bytes32 constant ipfsGateway5 = 0x636c6f7564666c6172652d697066732e636f6d2f697066730000000000000000;
            // https://ipfs.io/ipfs/
            // ipfs.io/ipfs = 0x697066732e696f2f697066730000000000000000000000000000000000000000
            // https://gateway.ipfs.io/ipfs/
            // gateway.ipfs.io/ipfs = 0x676174657761792e697066732e696f2f69706673000000000000000000000000
            // https://infura-ipfs.io/ipfs/
            // infura-ipfs.io/ipfs = 0x696e667572612d697066732e696f2f6970667300000000000000000000000000
            // https://gateway.pinata.cloud/ipfs/
            // gateway.pinata.cloud/ipfs = 0x676174657761792e70696e6174612e636c6f75642f6970667300000000000000
            // https://cloudflare-ipfs.com/ipfs/
            // cloudflare-ipfs.com/ipfs = 0x636c6f7564666c6172652d697066732e636f6d2f697066730000000000000000

		return bytes32(ipfsGateways[_ipfsGatewayId]);
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

}