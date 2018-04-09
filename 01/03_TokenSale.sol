pragma solidity 0.4.21;


contract ERC20Basic {

    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);

}
 

contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) public view returns (uint256);
  	function transferFrom(address from, address to, uint256 value) public returns (bool);
  	function approve(address spender, uint256 value) public returns (bool);
  	event Approval(address indexed owner, address indexed spender, uint256 value);

}
 

library SafeMath {

  	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    	uint256 c = a * b;
    	assert(a == 0 || c / a == b);
    	return c;

  	}
 
  	function div(uint256 a, uint256 b) internal pure returns (uint256) {
    	// assert(b > 0); // Solidity automatically throws when dividing by 0
    	uint256 c = a / b;
    	// assert(a == b * c + a % b); // There is no case in which this doesn't hold
    	return c;
  	}
 
  	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    	require(b <= a); 
    	return a - b; 
  	} 
  
  	function add(uint256 a, uint256 b) internal pure returns (uint256) { 
    	uint256 c = a + b; 
    	assert(c >= a);
    	return c;
  	}
 
}
 

library DateTime {
        /*
         *  Date and Time utilities for ethereum contracts
         *
         */
        struct _DateTime {
                uint16 year;
                uint8 month;
                uint8 day;
                uint8 hour;
                uint8 minute;
                uint8 second;
                uint8 weekday;
        }

        uint constant DAY_IN_SECONDS = 86400;
        uint constant YEAR_IN_SECONDS = 31536000;
        uint constant LEAP_YEAR_IN_SECONDS = 31622400;

        uint constant HOUR_IN_SECONDS = 3600;
        uint constant MINUTE_IN_SECONDS = 60;

        uint16 constant ORIGIN_YEAR = 1970;

        function isLeapYear(uint16 year) public pure returns (bool) {
                if (year % 4 != 0) {
                        return false;
                }
                if (year % 100 != 0) {
                        return true;
                }
                if (year % 400 != 0) {
                        return false;
                }
                return true;
        }

        function leapYearsBefore(uint year) public pure returns (uint) {
                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }

        function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                        return 31;
                }
                else if (month == 4 || month == 6 || month == 9 || month == 11) {
                        return 30;
                }
                else if (isLeapYear(year)) {
                        return 29;
                }
                else {
                        return 28;
                }
        }

        function parseTimestamp(uint timestamp) internal pure returns (_DateTime dt) {
                uint secondsAccountedFor = 0;
                uint buf;
                uint8 i;

                // Year
                dt.year = getYear(timestamp);
                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
                secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

                // Month
                uint secondsInMonth;
                for (i = 1; i <= 12; i++) {
                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                        if (secondsInMonth + secondsAccountedFor > timestamp) {
                                dt.month = i;
                                break;
                        }
                        secondsAccountedFor += secondsInMonth;
                }

                // Day
                for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                        if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                                dt.day = i;
                                break;
                        }
                        secondsAccountedFor += DAY_IN_SECONDS;
                }

                // Hour
                dt.hour = getHour(timestamp);

                // Minute
                dt.minute = getMinute(timestamp);

                // Second
                dt.second = getSecond(timestamp);

                // Day of week.
                dt.weekday = getWeekday(timestamp);
        }

        function getYear(uint timestamp) public pure returns (uint16) {
                uint secondsAccountedFor = 0;
                uint16 year;
                uint numLeapYears;

                // Year
                year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
                secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

                while (secondsAccountedFor > timestamp) {
                        if (isLeapYear(uint16(year - 1))) {
                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                secondsAccountedFor -= YEAR_IN_SECONDS;
                        }
                        year -= 1;
                }
                return year;
        }

        function getMonth(uint timestamp) public pure returns (uint8) {
                return parseTimestamp(timestamp).month;
        }

        function getDay(uint timestamp) public pure returns (uint8) {
                return parseTimestamp(timestamp).day;
        }

        function getHour(uint timestamp) public pure returns (uint8) {
                return uint8((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) public pure returns (uint8) {
                return uint8((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) public pure returns (uint8) {
                return uint8(timestamp % 60);
        }

        function getWeekday(uint timestamp) public pure returns (uint8) {
                return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint timestamp) {
                return toTimestamp(year, month, day, 0, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public pure returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public pure returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, minute, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint timestamp) {
                uint16 i;

                // Year
                for (i = ORIGIN_YEAR; i < year; i++) {
                        if (isLeapYear(i)) {
                                timestamp += LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                timestamp += YEAR_IN_SECONDS;
                        }
                }

                // Month
                uint8[12] memory monthDayCounts;
                monthDayCounts[0] = 31;
                if (isLeapYear(year)) {
                        monthDayCounts[1] = 29;
                }
                else {
                        monthDayCounts[1] = 28;
                }
                monthDayCounts[2] = 31;
                monthDayCounts[3] = 30;
                monthDayCounts[4] = 31;
                monthDayCounts[5] = 30;
                monthDayCounts[6] = 31;
                monthDayCounts[7] = 31;
                monthDayCounts[8] = 30;
                monthDayCounts[9] = 31;
                monthDayCounts[10] = 30;
                monthDayCounts[11] = 31;

                for (i = 1; i < month; i++) {
                        timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
                }

                // Day
                timestamp += DAY_IN_SECONDS * (day - 1);

                // Hour
                timestamp += HOUR_IN_SECONDS * (hour);

                // Minute
                timestamp += MINUTE_IN_SECONDS * (minute);

                // Second
                timestamp += second;

                return timestamp;
        }
}


contract BasicToken is ERC20Basic {

  	using SafeMath for uint256;
 
  	mapping(address => uint256) balances;
 
  	function transfer(address _to, uint256 _value) public returns (bool) {
    	require(_to != address(0));
    	require(_value <= balances[msg.sender]); 
    	// SafeMath.sub will throw if there is not enough balance. 
    	balances[msg.sender] = balances[msg.sender].sub(_value); 
    	balances[_to] = balances[_to].add(_value); 
    	emit Transfer(msg.sender, _to, _value); 
    	return true; 
  	} 
 
  	function balanceOf(address _owner) public view returns (uint256 balance) { 
  		require(_owner != address(0));
    	return balances[_owner]; 
  	} 
} 
 

contract StandardToken is ERC20, BasicToken {
 
  	mapping (address => mapping (address => uint256)) internal allowed;
 
  	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
  		require(_from != address(0));
    	require(_to != address(0));
    	require(_value <= balances[_from]);
    	require(_value <= allowed[_from][msg.sender]); 

    	balances[_from] = balances[_from].sub(_value); 
    	balances[_to] = balances[_to].add(_value); 
    	allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value); 
    	emit Transfer(_from, _to, _value); 
	    return true; 
	} 
 
  	function approve(address _spender, uint256 _value) public returns (bool) { 
  		require(_spender != address(0));

    	allowed[msg.sender][_spender] = _value; 
    	emit Approval(msg.sender, _spender, _value); 
    	return true; 
  	}
 
  	function allowance(address _owner, address _spender) public view returns (uint256 remaining) { 
  		require(_owner != address(0));
  		require(_spender != address(0));

    	return allowed[_owner][_spender]; 
  	} 
 
  	function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
  		require(_spender != address(0));

    	allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    	emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]); 
    	return true; 
  	}
 
  	function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
  		require(_spender != address(0));

    	uint oldValue = allowed[msg.sender][_spender]; 
    	if (_subtractedValue > oldValue) {
      		allowed[msg.sender][_spender] = 0;
    	} else {
      		allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    	}
    	emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    	return true;
  	}
 
  	function () public payable {
    	revert();
  	}
 
}
 

contract Ownable {

  	address public owner;
 
  	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
  	function Ownable() public {
    	owner = msg.sender;
  	}
 
  	modifier onlyOwner() {
    	require(msg.sender == owner);
    	_;
  	}
 
  	function transferOwnership(address newOwner) public onlyOwner {
    	require(newOwner != address(0));

    	emit OwnershipTransferred(owner, newOwner);
    	owner = newOwner;
  	}
 
}


contract BurnableToken is StandardToken {
  
  	event Burn(address indexed burner, uint indexed value);

  	function burn (uint _value) {
    	require (_value > 0);

    	address burner = msg.sender;
    	balances[burner] = balances[burner].sub(_value);
    	totalSupply = totalSupply.sub(_value);
    	emit Burn(burner, _value);
  	}  

}
 
contract BestTokenCoin is BurnableToken {
    
    string public constant name = "Best Coin Token";
    
    string public constant symbol = "BCT";
    
    uint32 public constant decimals = 18;

    uint256 public INITIAL_SUPPLY = 100000000 * 1 ether;



    function BestTokenCoin(){
      	totalSupply = INITIAL_SUPPLY;
      	balances[msg.sender] = INITIAL_SUPPLY;
    }
    
}

contract Crowdsale is Ownable {

    using SafeMath for uint;

    using DateTime for uint;

    address multisig;

    address bounty;

    address reserve;

	address[] users;

    uint restrictedPercent;

    uint start;

    uint end;

    uint hardcap;

    uint rate;

    BestTokenCoin public token = new BestTokenCoin();

    function Crowdsale() public {

        multisig = 0xEA15Adb66DC92a4BbCcC8Bf32fd25E2e86a2A770;
        bounty = 0xb3eD172CC64839FB0C0Aa06aa129f402e994e7De;
        reserve = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
        restrictedPercent = 30;
        rate = 10000000000000000;

    }

    modifier saleIsOn() {

        require(now > start && now < end);
        _;

    }

	modifier inListUsers() { 

		bool flgInList = false;

		for(uint i = 0; i < users.length; i++)
		{
			if (msg.sender == users[i])
			{
				flgInList = true;
				break;
			}
		}

		assert (flgInList);
		_; 

	}

    function createTokens() public saleIsOn inListUsers payable {

        multisig.transfer(msg.value);
        uint tokens = rate.mul(msg.value).div(1 ether);
        uint bonusTokens = 0;
        if(now < start + (period * 1 days).div(4)){
          bonusTokens = tokens.div(4);
        } else if(now < start + (period * 1 days).div(2)){
          bonusTokens = tokens.div(10);
        } else if(now < start + (period * 1 days).div(4).mul(3)){
          bonusTokens = tokens.div(20);
        }
        uint tokensWithBonus = tokens.add(bonusTokens);
        token.transfer(msg.sender, tokensWithBonus);
        uint restrictedTokens = tokens.mul(restrictedPercent).div(100 - restrictedPercent);
        token.transfer(restricted, restrictedTokens);

    }

    function isDateCorrect (uint _year, uint _month, uint _day) public returns (bool)	{

		if (_year < 1970) return false;
		else if (_month <= 0 && _month > 12) return false;
    	else if (
    		((_month == 1 || _month == 3 || _month == 5 || _month == 7 || _month == 8 || _month == 10 || _month == 12) && (_day <= 0 ||_day > 31)) || 
    		((_month == 4 || _month == 6 || _month == 9 || _month == 11) && (_day <= 0 || _day > 30)) || 
    		(_month == 2 && isLeapYear(_year) && (_day <= 0 || _day > 29) || (_month == 2 && !isLeapYear(_year) && (_day <= 0 || _day > 28)))
    		) return false;
    	else return true;

    }

    function setStartDate (uint _year, uint _month, uint _day) public onlyOwner {

    	assert(isDateCorrect(_year, _month, _day));
    	
    	start = toTimestamp(_year, _month, _day);
    	
    }

    function setEndDate (uint _year, uint _month, uint _day) public onlyOwner {

    	assert(isDateCorrect(_year, _month, _day));
    	
    	end = toTimestamp(_year, _month, _day);
    	
    }
    
    function setRate (uint _rate) public onlyOwner {

    	rate = _rate;

    }

    function addUser (address _newUser) public onlyOwner {
		require (_newUser != address(0));
		
		users.push(_newUser);
	}

    function() external payable {
        createTokens();
    }
    
}