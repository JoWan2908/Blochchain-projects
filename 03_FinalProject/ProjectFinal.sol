// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract RadnikProfil {
    address public adminFirme;
    address public novcanikRadnika;
    string public ime;
    uint public satnica;
    uint public vremeDolaska;
    uint public ukupnaZarada;

    constructor(address _radnik, string memory _ime, uint _satnica, address _admin) {
        novcanikRadnika = _radnik;
        ime = _ime;
        satnica = _satnica;
        adminFirme = _admin;
    }

    function prijaviDolazak() public {
        require(msg.sender == novcanikRadnika, "Samo radnik se prijavljuje");
        vremeDolaska = block.timestamp;
    }

    function odjaviSe() public {
        require(msg.sender == novcanikRadnika, "Samo radnik se odjavljuje");
        require(vremeDolaska > 0, "Niste prijavljeni");
        
        uint protekloVreme = block.timestamp - vremeDolaska;
        if(protekloVreme == 0) protekloVreme = 1;
        
        ukupnaZarada += protekloVreme * satnica;
        vremeDolaska = 0;
    }

    function podigniPlatu() public {
        require(msg.sender == novcanikRadnika, "Samo radnik podize novac");
        uint iznos = address(this).balance;
        require(iznos > 0, "Nema sredstava na ugovoru");
        (bool success, ) = payable(novcanikRadnika).call{value: iznos}("");
        require(success, "Transfer failed");
    }

    receive() external payable {}
}

contract FirmaManager {
    address public direktor;
    mapping(address => address) public radnikNaUgovor;

    constructor() {
        direktor = msg.sender;
    }

    function registrujRadnika(address _radnik, string memory _ime, uint _satnica) public {
        require(msg.sender == direktor, "Samo direktor registruje");
        RadnikProfil noviUgovor = new RadnikProfil(_radnik, _ime, _satnica, direktor);
        radnikNaUgovor[_radnik] = address(noviUgovor);
    }

    function isplatiRadnika(address _radnik) public payable {
        require(msg.sender == direktor, "Samo direktor placa");
        address ugovorRadnika = radnikNaUgovor[_radnik];
        require(ugovorRadnika != address(0), "Radnik nije registrovan");
        
        (bool uspeh, ) = payable(ugovorRadnika).call{value: msg.value}("");
        require(uspeh, "Transfer nije uspeo");
    }
}