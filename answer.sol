// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
안건을 올리고 이에 대한 찬성과 반대를 할 수 있는 기능을 구현하세요. 안건은 번호, 제목, 내용, 제안자(address) 그리고 찬성자 수와 반대자 수로 이루어져 있습니다.(구조체)
안건들을 모아놓은 자료구조도 구현하세요. 

사용자는 자신의 이름과 주소, 자신이 만든 안건 그리고 자신이 투표한 안건과 어떻게 투표했는지(찬/반)에 대한 정보[string => bool]로 이루어져 있습니다.(구조체)

* 사용자 등록 기능 - 사용자를 등록하는 기능
* 투표하는 기능 - 특정 안건에 대하여 투표하는 기능, 안건은 제목으로 검색, 이미 투표한 건에 대해서는 재투표 불가능
* 안건 제안 기능 - 자신이 원하는 안건을 제안하는 기능
* 제안한 안건 확인 기능 - 자신이 제안한 안건에 대한 현재 진행 상황 확인기능 - (번호, 제목, 내용, 찬반 반환 // 밑의 심화 문제 풀었다면 상태도 반환)
* 전체 안건 확인 기능 - 제목으로 안건을 검색하면 번호, 제목, 내용, 제안자, 찬반 수 모두를 반환하는 기능
-------------------------------------------------------------------------------------------------
* 안건 진행 과정 - 투표 진행중, 통과, 기각 상태를 구별하여 알려주고 전체의 70% 그리고 투표자의 66% 이상이 찬성해야 통과로 변경, 둘 중 하나라도 만족못하면 기각
*/

contract QUIZ {

    // 안건은 번호, 제목, 내용, 제안자(address) 그리고 찬성자 수와 반대자 수로 이루어져 있습니다.(구조체)
    struct poll {
        uint number;
        string title;
        string context;
        address by;
        uint pros;
        uint cons;
    }

    // 안건들을 모아놓은 자료구조도 구현하세요. (array or mapping)
    /* array or mapping
        mapping : 검색할 때 더 유리함.
        array : 단, 순차적으로 증가하는 경우는 mapping보다 array가 더 유리할 수도 있음. (번호로 검색 등)
    */


    /* 사용자는 자신의 이름과 주소, 자신이 만든 안건
    그리고 자신이 투표한 안건과 어떻게 투표했는지(찬/반)에 대한 정보[string => bool]로 이루어져 있습니다.(구조체)*/
    struct user {
        string name;
        address addr;
        string[] suggested;
        mapping(string => votingStatus) voted;
    }

    // user를 관리할 자료구조, array or mapping (visibility는 default 값이 internal임)
    user[] public Users;

    // enum 활용하기 : 총 3가지 상태임. 투표안함 / 투표했는데 찬성 / 투표했는데 반대
    enum votingStatus {
        notVoted,
        pro,
        con
    }

    // * 사용자 등록 기능 - 사용자를 등록하는 기능
    function setUser(string memory _name) public {
        /* 아래는 에러 발생. Struct containing a (nested) mapping cannot be constructed. 맵핑을 초기값 주는 방법은 없음.
        Users.push(user(_name, msg.sender, new string[](0)));
        따라서 아래처럼 우회해야 함.*/
        user storage _newuser = Users.push();
        Users[Users.length - 1].name = _name;
    }
    function getUsersLength() public view returns(uint) {
        return Users.length;
    }
    function pushUser(uint number, string memory _name, address _addr) public {
        user storage _newuser = Users.push();
        Users[Users.length - 1].number = number;
        Users[Users.length - 1].name = _name;
        Users[Users.length - 1].addr = msg.sender;
    }


    // * 투표하는 기능 - 특정 안건에 대하여 투표하는 기능, 안건은 제목으로 검색(array 대신 mapping), 이미 투표한 건에 대해서는 재투표 불가능
    mapping(string => poll) polls;
    function vote(string memory _title, bool _vote) public {
        // 찬성이냐 반대이냐?
        polls[_title].pros++;
    }

    uint count;
    // * 안건 제안 기능 - 자신이 원하는 안건을 제안하는 기능 (msg.sender로 안쓰고 address _addr받는 이유는 유저에서 요청하는거면 msg.sender는 userContract임.
    function suggest(string calldata _title, string calldata _context, address _addr) public {    
        polls[_title] = poll(++count, _title, _context, _addr, 0, 0);
    }



}


contract User {
    // 컨트렉트 instance하기.
    QUIZ polls;
    constructor(address _a) {
        polls = QUIZ(_a);
    }
    enum votingStatus {
        notVoted, // 0 : default 값이기 때문에 맨 위에 적은거임.
        pro, // 1
        con // 2
    }

    struct user {
        uint number;  // 얘가 User contract 분리 이유임. 위 컨트렉트에서는 알 수가 없어서.
        string name;
        address addr;
        string[] suggested;
        mapping(string=>votingStatus) voted;
    }

    user MyAccount;


    function setUser(string memory _name) public {
        (MyAccount.number, MyAccount.name, MyAccount.addr) = (polls.getUsersLength(), _name, msg.sender);
        polls.Users.push();
    }



    /*
        // * 사용자 등록 기능 - 사용자를 등록하는 기능
    function setUser(string memory _name) public {
        user storage _newuser = Users.push();
        // Users[Users.length-1].number = Users.length;
        Users[Users.length-1].name = _name;
        Users[Users.length-1].addr = msg.sender;
    }

    function getUsers() public view returns(uint) {
        return(Users.length);
    }

    function getUser(uint _n) public view returns(string memory, address, string[] memory) {
        return (Users[_n].name, Users[_n].addr, Users[_n].suggested);
    }

    function getUser2(uint _n, string memory _a) public view returns(string memory, address, string[] memory) {
        return (Users[_n].name, Users[_n].addr, Users[_n].suggested);
    }

    */
}


contract INITIALIZATION {

    uint a;
    string b;
    address c;
    bytes1 d;
    bytes e;
    bool f;

    struct set1 {
        uint a;
        string b;
        address c;
        bytes32 d;
        bytes e;
        bool f;
    }
    set1 public S1;
    set1[] group1;

    // strct안에서 모두 array로만 선언되어있으면 초기값을 아얘 반환하지 않음. array가 아닌 uint aa; 를 하거나 set2 public S2에서 public을 빼야함.
    struct set2 {
        // uint aa;
        uint[] g;
        string[] h;
        bytes1[4] i;
        // uint[4] j;
        // address[4] k;
        // string[4] l;
    }
    // 초기값을 설정해 줘야 함.
    function pushG1() public {
        group1.push(set1(0,"",address(0),bytes32(0),new bytes(0),false));
    }

    function pushG2() public {
        bytes1[4] memory _i;
        group2.push(set2(new uint[](0), new string[](0), _i));  /*bytes1[4] 대신 _i선언해서 넣기*/
        // bytes[4], new bytes[4], new bytes[](4) 다 안됨.
        /* type(bytes1[4] memory) to bytes1[4] memory requested. 에러가 발생. 형이 같은게아닌가? 하지만 다르게 선언해줘야 됨.
        따라서 bytes1[4]를 따로 선언해라.
        초기값 : tuple(uint256[],string[],bytes1[4])[]: 
        */
    }
    function getG2() public view returns(set2[] memory){
        return group2;
    }

    // set2 public S2;
    set2 S2;
    set2[] group2;
    function getS2() public view returns(set2 memory) {
        return S2;
    }
    /*
    tuple(uint256,uint256[],string[],bytes1[4],uint256[4],address[4],string[4]): 0,,,0x00,0x00,0x00,0x00,0,0,0,0,0x0000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000,,,,
    */

    uint[] g;
    string[] h;
    bytes1[4] i;
    uint[4] j;
    address[4] k;
    string[4] l;
    
    function getA() public view returns(uint, string memory, address, bytes1, bytes memory, bool) {
        return (a, b, c, d, e, f);
    }
    /* 초기값
    uint256: 0
    string:
    address: 0x0000000000000000000000000000000000000000
    bytes1: 0x00
    bytes: 0x
    bool: false
    */

    function getG() public view returns(uint[] memory, string[] memory, bytes1[4] memory, uint[4] memory, address[4] memory, string[4] memory) {
        return (g, h, i,j ,k ,l);
    }
    /* 초기값
    uint256[]:
    string[]:
    bytes1[4]: 0x00,0x00,0x00,0x00
    uint256[4]: 0,0,0,0
    address[4]: 0x0000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000
    string[4]: ,,,*/


}


contract doubleMapping {
    struct user {
        uint number;
        string name;
    }
    user B;

    mapping(address => uint) balance;
    mapping(address => mapping(string => uint)) bankAccounts;
    /* Only elementary types, user defined value types, contract types or enums are allowed as mapping keys.
    struct user는 reference 타입이고, reference 타입은 key값으로 사용하지 못함.
    mapping(user => mapping(string => uint)) bankAccouts2;
    */
    mapping(address => mapping(string => user)) bankAccounts2; // 이건 가능함. value로만 사용 가능.
    mapping(string => mapping(string => mapping(uint => user))) bankAccounts3;  // 3중맵핑

    uint[] A;
    /* uint[]에서 A는 변수명임! 변수 형이 아님.
    mapping(address => A) As;

    mapping(uint[] => address) As2;
    위에도 에러임. 맵핑은 key값을 넣으면 value가 나오는데, 키 값이 배열로 들어가는건 안됨.*/

    function setBalance() public {
        balance[msg.sender] = (msg.sender).balance;
    }

    function setBankAccounts(string calldata _name) public {
        bankAccounts[msg.sender][_name] = 100;
    }

    function setBankAccounts2(string calldata _city, string calldata _state, uint number) public {
        bankAccounts3[_city][_state][number] = B;
    }

    function getbankAccounts(address _addr, string memory _name) public view returns(uint) {
        return bankAccounts[_addr][_name];
    }



}