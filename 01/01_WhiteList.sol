pragma solidity 0.4.21;


contract CrowdsaleWithWhiteList is Crowdsale, Ownable {
	
    mapping(address => bool) users;
	
    modifier isInWhiteList(address user) {
	require(users[user]);
	_;
    }
    
    function addToWhiteList(address user) public external onlyOwner {
        require(user != address(0));
	users[user] = true;
    }
	
    function addManyToWhiteList(address[] user) public external onlyOwner {
	for (int i = 0; i < user.length; i++) {
	    addToWhiteList(user[i]);
	}
    }

    function removeFromWhiteList(address user) public external onlyOwner {
        require(user != address(0));
	users[user] = false;
    }
	
    function removeManyFromWhiteList(address[] user) public external onlyOwner {
	for (int i = 0; i < user.length; i++) {
	    removeFromWhiteList(user[i]);
	}
    }
}
