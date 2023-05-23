// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Quiz {

    struct Time {
        uint day;
        uint hour;
        uint min;
        uint sec;
    }

    Time times;
    
    function time(uint _a) public returns(Time memory) {
        uint d = 60 ** 2 * 24;
        uint h = 60 ** 2;
        uint m = 60;

        times.day = _a / d;
        times.hour = (_a - (times.day * d)) / h;
        times.min = (_a - (times.day * d) - (times.hour * h)) / m;
        times.sec = _a % m;

        

        return times;
    }

}
