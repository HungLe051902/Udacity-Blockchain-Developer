pragma solidity ^0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false
    mapping(address => uint256) private authorizedContracts;

    struct Airline {
        address wallet;
        bool isRegistered;
        string name;
        uint256 funded;
        uint256 votes;
    }
    mapping(address => Airline) private airlines;

    struct Passenger {
        address wallet;
        mapping(string => uint256) boughtFlight;
        uint256 credit;
    }
    mapping(address => Passenger) private passengers;
    address[] public passengerAddresses;

    uint256 public constant INSURANCE_LIMIT_PRICE = 1 ether;
    uint256 public constant MINIMUM_FUNDS = 10 ether;
    uint8 private constant MULTIPARTY_CONSENSUS = 4;

    uint256 public airlinesCount;
    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/


    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                ) 
                                public 
    {
        contractOwner = msg.sender;
        authorizedContracts[msg.sender] = 1;
        airlinesCount = 0;
        passengerAddresses = new address[](0);

        // First Airline
        airlines[msg.sender] = Airline({
            wallet: msg.sender,
            isRegistered: true,
            name: "FirstAirline",
            funded: 0,
            votes: 0
        });
        airlinesCount++;
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier requireIsCallerAuthorized() {
        require(authorizedContracts[msg.sender] == 1, "Caller is not an authorized contract");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            public 
                            view 
                            returns(bool) 
    {
        return operational;
    }

    function isAirlineActive (address airline) public view returns(bool) {
        return(airlines[airline].funded >= MINIMUM_FUNDS);
    }

    function isAirline (
                            address airline
                        )
                        external
                        view
                        returns (bool) {
        if (airlines[airline].wallet == airline) {
            return true;
        } else {
            return false;
        }
    }

    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus
                            (
                                bool mode
                            ) 
                            external
                            requireContractOwner 
    {
        operational = mode;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function registerAirline
                            (   
                                address airlineAddress,
                                string name
                            )
                            external
                            requireIsOperational
                            requireIsCallerAuthorized
                            
    {
        require(airlineAddress != address(0), 'Airline address is not valid');
        require(airlines[airlineAddress].isRegistered == false, "Airline is registerd");

        if (airlinesCount < MULTIPARTY_CONSENSUS) {
            airlines[airlineAddress] = Airline({
                                                wallet: airlineAddress,
                                                isRegistered: true,
                                                name: name,
                                                funded: 0,
                                                votes: 1
                                        });
            airlinesCount++;
        }
        else {
            vote(airlineAddress);
        }
    }

    function vote(address airlineAddress) internal requireIsOperational {
        airlines[airlineAddress].votes++;
        if (airlines[airlineAddress].votes >= airlinesCount.div(2)) {
            airlines[airlineAddress].isRegistered = true;
            airlinesCount++;
        }
    }

    function checkIfContains(address passenger) internal view returns(bool isExist){
        isExist = false;
        for (uint256 c = 0; c < passengerAddresses.length; c++) {
            if (passengerAddresses[c] == passenger) {
                isExist = true;
                break;
            }
        }
        return isExist;
    }

   /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy
            ( 
                string flightCode                            
            )
            external
            requireIsOperational
            payable
    {
        require(msg.value > 0, "You don't have enough money");
        if (!checkIfContains(msg.sender)) {
            passengerAddresses.push(msg.sender);
        }
        if (passengers[msg.sender].wallet != msg.sender) {
            passengers[msg.sender] = Passenger({
                wallet: msg.sender,
                credit: 0
            });
            passengers[msg.sender].boughtFlight[flightCode] = msg.value;
        }
        else {
            passengers[msg.sender].boughtFlight[flightCode] = msg.value;
        }
        if (msg.value > INSURANCE_LIMIT_PRICE) {
            msg.sender.transfer(msg.value.sub(INSURANCE_LIMIT_PRICE));
        }
    }

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees
                (
                    string flightCode
                )
                external
                
    {
        for (uint256 i = 0; i < passengerAddresses.length; i++) {
            if (passengers[passengerAddresses[i]].boughtFlight[flightCode] != 0) {
                uint256 oldCredit = passengers[passengerAddresses[i]].credit;
                uint256 payedPrice = passengers[passengerAddresses[i]].boughtFlight[flightCode];
                passengers[passengerAddresses[i]].boughtFlight[flightCode] = 0;
                passengers[passengerAddresses[i]].credit = oldCredit + payedPrice + payedPrice.div(2);
            }
        }
    }
    

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
                (
                    address insuredPassenger
                )
                external
                returns (uint256, uint256, uint256, uint256, address, address)
    {
        require(passengers[insuredPassenger].credit > 0, "");
        uint256 initialBalance = address(this).balance;
        uint256 credit = passengers[insuredPassenger].credit;
        require(address(this).balance > credit, "The contract does not have enough funds");
        passengers[insuredPassenger].credit = 0;
        insuredPassenger.transfer(credit);
        uint256 finalCredit = passengers[insuredPassenger].credit;
        return (initialBalance, credit, address(this).balance, finalCredit, insuredPassenger, address(this));
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */   
    function fund
                            (   
                            )
                            public
                            requireIsOperational
                            payable
    {
        uint256 currentFund = airlines[msg.sender].funded;
        airlines[msg.sender].funded = currentFund.add(msg.value);
    }

    function authorizeCaller (address contractAddress) external requireContractOwner {
        authorizedContracts[contractAddress] = 1;
    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function() 
                            external 
                            payable 
    {
        fund();
    }


}

