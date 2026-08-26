// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

/**
 * @title NamingUtil library
 * @author Spectra Finance
 * @notice Provides miscellaneous utils for token naming.
 */
library NamingUtil {
    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    int256 constant OFFSET19700101 = 2440588;

    function genYTSymbol(string memory _ibtSymbol, string memory _underlyingSymbol, uint256 _dateOfExpiry)
        public
        pure
        returns (string memory)
    {
        string memory date = timestampToDateString(_dateOfExpiry);

        // Pattern: YT-{_ibtSymbol}({_underlyingSymbol})-{date}
        return concatenate(
            concatenate(concatenate("YT-", _ibtSymbol), concatenate("(", concatenate(_underlyingSymbol, ")-"))), date
        );
    }

    function genYTName(string memory _ibtSymbol, string memory _underlyingSymbol, uint256 _dateOfExpiry)
        public
        pure
        returns (string memory)
    {
        string memory date = timestampToDateString(_dateOfExpiry);

        // Pattern: Yield Token: {_ibtSymbol}({_underlyingSymbol}) {date}
        return concatenate(
            concatenate(
                "Yield Token: ", concatenate(_ibtSymbol, concatenate("(", concatenate(_underlyingSymbol, ") ")))
            ),
            date
        );
    }

    function genPTSymbol(string memory _ibtSymbol, string memory _underlyingSymbol, uint256 _dateOfExpiry)
        public
        pure
        returns (string memory)
    {
        string memory date = timestampToDateString(_dateOfExpiry);

        // Optimized: Build string in fewer operations by grouping smallest parts first
        // Pattern: PT-{_ibtSymbol}({_underlyingSymbol})-{date}
        return concatenate(
            concatenate(concatenate("PT-", _ibtSymbol), concatenate("(", concatenate(_underlyingSymbol, ")-"))), date
        );
    }

    function genPTName(string memory _ibtSymbol, string memory _underlyingSymbol, uint256 _dateOfExpiry)
        public
        pure
        returns (string memory)
    {
        string memory date = timestampToDateString(_dateOfExpiry);

        // Pattern: Principal Token: {_ibtSymbol}({_underlyingSymbol}) {date}
        return concatenate(
            concatenate(
                "Principal Token: ", concatenate(_ibtSymbol, concatenate("(", concatenate(_underlyingSymbol, ") ")))
            ),
            date
        );
    }

    function concatenate(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }

    function uintToString(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function timestampToDateString(uint256 timestamp) internal pure returns (string memory) {
        (uint256 year, uint256 month, uint256 day) = timestampToDate(timestamp);

        string memory y = uintToString(year);
        string memory m = month < 10 ? concatenate("0", uintToString(month)) : uintToString(month);
        string memory d = day < 10 ? concatenate("0", uintToString(day)) : uintToString(day);

        return concatenate(concatenate(concatenate(y, "/"), m), concatenate("/", d));
    }

    // Timestamp to date calculations (forked from https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary/tree/master)

    function _daysToDate(uint256 _days) internal pure returns (uint256 year, uint256 month, uint256 day) {
        int256 __days = int256(_days);

        int256 L = __days + 68569 + OFFSET19700101;
        int256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        int256 _year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * _year) / 4 + 31;
        int256 _month = (80 * L) / 2447;
        int256 _day = L - (2447 * _month) / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint256(_year);
        month = uint256(_month);
        day = uint256(_day);
    }

    function timestampToDate(uint256 timestamp) internal pure returns (uint256 year, uint256 month, uint256 day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
}
