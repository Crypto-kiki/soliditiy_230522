// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.18;
// 안건을 올리고 이에 대한 찬성과 반대를 할 수 있는 기능을 구현하세요. 

// 안건은 번호, 제목, 내용, 제안자(address) 그리고 찬성자 수와 반대자 수로 이루어져 있습니다.(구조체)
// 안건들을 모아놓은 자료구조도 구현하세요. 

// 사용자는 자신의 이름과 주소, 자신이 만든 안건 그리고 자신이 투표한 안건과 어떻게 투표했는지(찬/반)에 대한 정보로 이루어져 있습니다.(구조체)

// * 사용자 등록 기능 - 사용자를 등록하는 기능
// * 투표하는 기능 - 특정 안건에 대하여 투표하는 기능, 안건은 제목으로 검색, 이미 투표한 건에 대해서는 재투표 불가능
// * 안건 제안 기능 - 자신이 원하는 안건을 제안하는 기능
// * 제안한 안건 확인 기능 - 자신이 제안한 안건에 대한 현재 진행 상황 확인기능
// * 전체 안건 확인 기능 - 제목으로 안건을 검색하면 번호, 제목, 내용, 제안자, 찬반 수 모두를 반환하는 기능
// -------------------------------------------------------------------------------------------------
// * 안건 진행 과정 - 투표 진행중, 통과, 기각 상태를 구별하여 알려주고 전체의 70% 그리고 투표자의 66% 이상이 찬성해야 통과로 변경, 둘 중 하나라도 만족못하면 기각

contract Q6 {
    // 안건 진행 과정
    enum agendaStatus{inProgress, pass, dismissal}

    // 안건은 번호, 제목, 내용, 제안자(address) 그리고 찬성자 수와 반대자 수로 이루어져 있습니다.(구조체)
    struct Agenda {
        uint index;
        string title;
        string content;
        address proponent;
        uint votesAgree;
        uint votesDisagree;
    }

    // 사용자는 자신의 이름과 주소, 자신이 만든 안건 그리고 자신이 투표한 안건과 어떻게 투표했는지(찬/반)에 대한 정보[string => bool]로 이루어져 있습니다.(구조체)
    struct User {
        string name;
        address wallet;
        // 내가 만든 안건
        Agenda[] myAgenda;

        // 자신이 투표한 안건 이름으로 검색.
        mapping(string => Agenda) myVotedAgenda;

        // 찬/반 여부
        mapping(string => bool) isVoted;
    }

    // 안건들을 모아 놓은 자료구조(안건은 제목으로 검색)
    mapping(string => Agenda) agendas;

    // 유저가 자기 주소로 들어오면 본인의 정보를 확인할 수 있게 모아 둠.
    // 유저 지갑으로 검색하면 유저 정보 나옴.
    mapping(address => User) users;

    // 이렇게 하면 배열에 유저를 저장해 주는 건데... 여기에 유저 넣으려면 struct의 모든 정보를 다 기입해줘야 한다는 문제가 있는듯??
    // User[] users;

    // 자신의 안건을 타이틀로 검색해서 확인
    mapping(string => Agenda) myAgenda;

    // 왜 1번? 인간은 1번으로 시작하는게 익숙하기 때문이다..
    uint countAgenda = 1;

    // 사용자 등록이랑 등록 후에 안건이 등록되는 거랑 별개? => ㅇㅇ 회원 가입에는 이름만 넣으면 실행한 주소로 자동 가입되어야함.
    // * 사용자 등록 기능 - 사용자를 등록하는 기능 (완료)
    function register(string memory _name) public returns(string memory, address) {
        // 이미 가입되어 있으면 하지 마세요;; = 가입 안되어야지만 가입할 수 있음.
        // 근데 이거 require에서 실행한 에러 메세지 어디서 보냐.. 왜 콘솔에 안뜸;
        require(users[msg.sender].wallet != msg.sender, "you already registed");
        // 실행 시킨 사람의 주소가 자동으로 address에 들어감.
        address userAddress = msg.sender;
        // users 객체에 접근해서 거기에 있는 userAddress 주소를 검색하고 그 userAddress의 wallet과 name에 값을 넣어서 유저로 등록해줌.
        users[userAddress].wallet = msg.sender;
        users[userAddress].name = _name;
        return(users[userAddress].name, users[userAddress].wallet);
    }

    // * 투표하는 기능 - 특정 안건에 대하여 투표하는 기능, 안건은 제목으로 검색, 이미 투표한 건에 대해서는 재투표 불가능
    function voteAgenda(string memory _title, bool _isAgree) public {
        // 이미 투표했으면 하지마!!!!!!!!!
        require(users[msg.sender].isVoted[_title] != false);

        if(_isAgree == false) {
            agendas[_title].votesDisagree++;
        } else {
            agendas[_title].votesAgree++;
        }
    }

    // * 안건 제안 기능 - 자신이 원하는 안건을 제안하는 기능
    function addAgenda(string memory _title, string memory _content) public {
        // 가입이 되어 계신가요?
        // 지금 이거 실행시키는 사람이 users 맵핑에서 msg.sender로 검색한 지갑이랑 일치? == 가입 되어잇음.
        require(msg.sender == users[msg.sender].wallet, "Regist First");

        // 안건 번호는 알아서 기록
        // 안건 몇 개인지 counting 해야 하는거 아닌가.. 상태변수로 count 하면 안댐? 근데 그게 아니면 배열의 길이로 count 해야? ㅡㅡ;
        // 근데 그렇게 하려면 또 동적 정적 계산해야해하는거 아님? 아....;
        
        // 안건의 주인도 알아서 기록
        address _proponent = msg.sender;
        // 투표자 수는 0으로 첨부터 초기화
        agendas[_title] = Agenda(countAgenda++, _title, _content, _proponent, 0, 0);
    }

    // * 제안한 안건 확인 기능 - 자신이 제안한 안건에 대한 현재 진행 상황 확인기능 - (번호, 제목, 내용, 찬반 반환 // 밑의 심화 문제 풀었다면 상태도 반환)
    function getMyAgenda() public view returns(Agenda[] memory) {
        // 이거 실행한 사람의 것을 보여줘야 함.
        return users[msg.sender].myAgenda;
    }
}