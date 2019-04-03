pragma solidity 0.4.24;

import "./helpers/Assert.sol";
import "../common/ConversionHelpers.sol";


contract TestConversionHelpers {
    uint256 constant internal FIRST = uint256(keccak256("0"));
    uint256 constant internal SECOND = uint256(keccak256("1"));
    uint256 constant internal THIRD = uint256(keccak256("2"));

    function testUintArrayConvertedToBytes() public {
        uint256[] memory arr = new uint256[](3);
        arr[0] = FIRST;
        arr[1] = SECOND;
        arr[2] = THIRD;
        uint256 arrLength = arr.length;

        // Do conversion
        bytes memory arrBytes = ConversionHelpers.dangerouslyCastUintArrayToBytes(arr);

        // Check length
        Assert.equal(arrBytes.length, arrLength * 32, "should have correct length as bytes array");

        // Check memory position (conversion should be in place)
        uint256 arrMemLoc;
        uint256 arrBytesMemLoc;
        assembly {
            arrMemLoc := arr
            arrBytesMemLoc := arrBytes
        }
        Assert.equal(arrMemLoc, arrBytesMemLoc, "should have same memory location after conversion");
    }

    function testUintArrayIntactIfConvertedBack() public {
        uint256[] memory arr = new uint256[](3);
        arr[0] = FIRST;
        arr[1] = SECOND;
        arr[2] = THIRD;
        uint256 arrLength = arr.length;

        // Convert to and back
        bytes memory arrBytes = ConversionHelpers.dangerouslyCastUintArrayToBytes(arr);
        uint256[] memory arrReconverted = ConversionHelpers.dangerouslyCastBytesToUintArray(arrBytes);

        // Check length
        Assert.equal(arrLength, arrReconverted.length, "should have correct length after reconverting");

        // Check memory position (conversion should be in place)
        uint256 arrMemLoc;
        uint256 arrReconvertedMemLoc;
        assembly {
            arrMemLoc := arr
            arrReconvertedMemLoc := arrReconverted
        }
        Assert.equal(arrMemLoc, arrReconvertedMemLoc, "should have same memory location after reconverting");

        // Check values
        Assert.equal(arrReconverted[0], FIRST, "should have correct index value at 0");
        Assert.equal(arrReconverted[1], SECOND, "should have correct index value at 1");
        Assert.equal(arrReconverted[2], THIRD, "should have correct index value at 2");
    }

    function testBytesConvertedToUintArray() public {
        bytes memory arr = new bytes(96);

        // Fill in bytes arr
        uint256 first = FIRST;
        uint256 second = SECOND;
        uint256 third = THIRD;
        assembly {
            mstore(add(arr, 0x20), first)
            mstore(add(arr, 0x40), second)
            mstore(add(arr, 0x60), third)
        }
        uint256 arrLength = arr.length;

        // Do conversion
        uint256[] memory arrUint = ConversionHelpers.dangerouslyCastBytesToUintArray(arr);

        // Check length
        Assert.equal(arrUint.length, arrLength / 32, "should have correct length as uint256 array");

        // Check memory position (conversion should be in place)
        uint256 arrMemLoc;
        uint256 arrUintMemLoc;
        assembly {
            arrMemLoc := arr
            arrUintMemLoc := arrUint
        }
        Assert.equal(arrMemLoc, arrUintMemLoc, "should have same memory location after conversion");

        // Check values
        Assert.equal(arrUint[0], FIRST, "should have correct index value at 0");
        Assert.equal(arrUint[1], SECOND, "should have correct index value at 1");
        Assert.equal(arrUint[2], THIRD, "should have correct index value at 2");
    }

    function testBytesIntactIfConvertedBack() public {
        bytes memory arr = new bytes(96);

        // Fill in bytes arr
        uint256 first = FIRST;
        uint256 second = SECOND;
        uint256 third = THIRD;
        assembly {
            mstore(add(arr, 0x20), first)
            mstore(add(arr, 0x40), second)
            mstore(add(arr, 0x60), third)
        }
        uint256 arrLength = arr.length;

        // Convert to and back
        uint256[] memory arrUint = ConversionHelpers.dangerouslyCastBytesToUintArray(arr);
        bytes memory arrReconverted = ConversionHelpers.dangerouslyCastUintArrayToBytes(arrUint);

        // Check length
        Assert.equal(arrLength, arrReconverted.length, "should have correct length after reconverting");

        // Check memory position (conversion should be in place)
        uint256 arrMemLoc;
        uint256 arrReconvertedMemLoc;
        assembly {
            arrMemLoc := arr
            arrReconvertedMemLoc := arrReconverted
        }
        Assert.equal(arrMemLoc, arrReconvertedMemLoc, "should have same memory location after reconverting");

        // Check values
        assembly {
            first := mload(add(arrReconvertedMemLoc, 0x20))
            second := mload(add(arrReconvertedMemLoc, 0x40))
            third := mload(add(arrReconvertedMemLoc, 0x60))
        }
        Assert.equal(first, FIRST, "should have correct first value");
        Assert.equal(second, SECOND, "should have correct second value");
        Assert.equal(third, THIRD, "should have correct third value");
    }
}
