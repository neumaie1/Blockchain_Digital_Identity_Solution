// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFT is ERC721URIStorage {
    struct Person {
        uint256 id;
        uint256 age;
        string name;
        string surname;
        uint256 height;
        string eyeColor;
        string religion;
        string location;
        string eId;
        uint256 issueDate;
        uint256 expiryDate;
    }

    Person[] private persons;
    mapping(string => bool) private personExists;
    mapping(string => bool) private eIdExists;
    mapping(uint256 => address) private personIdToOwner;
    mapping(address => uint256) private numOfIds;

    event NFTCreated(
        uint256 id,
        uint256 age,
        string name,
        string surname,
        uint256 height,
        string eyeColor,
        string religion,
        string location,
        string eId,
        uint256 issueDate,
        uint256 expiryDate,
        string uri
    );

    constructor() ERC721("NFT", "NFT") {}

    function createNFT(
        uint256 _age,
        string memory _name,
        string memory _surname,
        uint256 _height,
        string memory _eyeColor,
        string memory _religion,
        string memory _location,
        string memory _eId,
        uint256 _issueDate,
        string memory _uri
    ) public {
        require(!personExists[_name], "Person already exists");
        require(!eIdExists[_eId], "E-ID already exists");

        uint256 _expiryDate = _issueDate + 6;

        Person memory newPerson = Person({
            id: persons.length,
            age: _age,
            name: _name,
            surname: _surname,
            height: _height,
            eyeColor: _eyeColor,
            religion: _religion,
            location: _location,
            eId: _eId,
            issueDate: _issueDate,
            expiryDate: _expiryDate
        });

        persons.push(newPerson);
        personExists[_name] = true;
        eIdExists[_eId] = true;

        uint256 tokenId = persons.length - 1;
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, _uri);

        personIdToOwner[tokenId] = msg.sender;
        numOfIds[msg.sender]++;

        emit NFTCreated(
            newPerson.id,
            newPerson.age,
            newPerson.name,
            newPerson.surname,
            newPerson.height,
            newPerson.eyeColor,
            newPerson.religion,
            newPerson.location,
            newPerson.eId,
            newPerson.issueDate,
            newPerson.expiryDate,
            _uri
        );
    }

    function getNFTInfo(string memory _searchField)
        public
        view
        returns (
            uint256,
            uint256,
            string memory,
            string memory,
            uint256,
            string memory,
            string memory,
            string memory,
            string memory,
            uint256,
            uint256,
            string memory
        )
    {
        if (bytes(_searchField).length > 0) {
            // Search by E-ID
            if (eIdExists[_searchField]) {
                for (uint256 i = 0; i < persons.length; i++) {
                    if (
                        keccak256(bytes(persons[i].eId)) ==
                        keccak256(bytes(_searchField))
                    ) {
                        Person memory person = persons[i];
                        return (
                            person.id,
                            person.age,
                            person.name,
                            person.surname,
                            person.height,
                            person.eyeColor,
                            person.religion,
                            person.location,
                            person.eId,
                            person.issueDate,
                            person.expiryDate,
                            tokenURI(i)
                        );
                    }
                }
            }
            // Search by Name
            else if (personExists[_searchField]) {
                for (uint256 i = 0; i < persons.length; i++) {
                    if (
                        keccak256(bytes(persons[i].name)) ==
                        keccak256(bytes(_searchField))
                    ) {
                        Person memory person = persons[i];
                        return (
                            person.id,
                            person.age,
                            person.name,
                            person.surname,
                            person.height,
                            person.eyeColor,
                            person.religion,
                            person.location,
                            person.eId,
                            person.issueDate,
                            person.expiryDate,
                            tokenURI(i)
                        );
                    }
                }
            }
        }
        revert("Person not found");
    }
}
