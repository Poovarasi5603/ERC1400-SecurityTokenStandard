// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract IPFShashStorage {
    struct File {
        string fileName;
        string ipfsHash;
    }

    // Mapping from user address to a mapping of file name to File struct
    mapping(address => mapping(string => File)) private userFiles;

    // Event emitted when a file is uploaded
    event FileUploaded(address indexed user, string fileName, string ipfsHash);

    // Function to upload a file
    function upload(string memory fileName, string memory ipfsHash) public {
        require(bytes(userFiles[msg.sender][fileName].ipfsHash).length == 0, "File already exists");
        userFiles[msg.sender][fileName] = File(fileName, ipfsHash);
        emit FileUploaded(msg.sender, fileName, ipfsHash);
    }

    // Function to get the IPFS hash of a file for the caller
    function getIPFSHash(string memory fileName) public view returns (string memory) {
        require(bytes(userFiles[msg.sender][fileName].ipfsHash).length > 0, "File not found");
        return userFiles[msg.sender][fileName].ipfsHash;
    }

    // Function to check if a file is stored for the caller
    function isFileStored(string memory fileName) public view returns (bool) {
        return bytes(userFiles[msg.sender][fileName].ipfsHash).length > 0;
    }

    // Function to get the IPFS hash of a file for a specific user
    function getIPFSHashForUser(address user, string memory fileName) public view returns (string memory) {
        require(bytes(userFiles[user][fileName].ipfsHash).length > 0, "File not found");
        return userFiles[user][fileName].ipfsHash;
    }

    // Function to check if a file is stored for a specific user
    function isFileStoredForUser(address user, string memory fileName) public view returns (bool) {
        return bytes(userFiles[user][fileName].ipfsHash).length > 0;
    }
}


