pragma solidity >=0.4.21 <0.6.0;

// TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
import "./ERC721Mintable.sol";
import "./Verifier.sol";

contract SquareVerifier is Verifier { }


// TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is BaoHong {
    SquareVerifier private squareVerifier;

    constructor(address verifierAddress) 
        public 
    {
        squareVerifier = SquareVerifier(verifierAddress);
    }

    // TODO define a solutions struct that can hold an index & an address
    struct Solution {
        uint256 solutionIndex;
        address solutionAddress;
        bool isMinted;
    }


    // TODO define an array of the above struct
    uint256 numberOfSolutions = 0;

    // TODO define a mapping to store unique solutions submitted
    mapping(bytes32 => Solution) solutions;

    // TODO Create an event to emit when a solution is added
    event SolutionAdded(uint256 solutionIndex, address indexed solutionAddress);


    // TODO Create a function to add the solutions to the array and emit the event
    function addSolution(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[2] memory input) public {
        bytes32 solutionHash = keccak256(abi.encodePacked(input[0], input[1]));
        require(solutions[solutionHash].solutionAddress == address(0), "Solution is already existed");

        require(squareVerifier.verifyTx(a, b, c, input), "Solution can't be verified");

        solutions[solutionHash] = Solution(numberOfSolutions, msg.sender, false);

        emit SolutionAdded(numberOfSolutions, msg.sender);
        numberOfSolutions++;
    }


    // TODO Create a function to mint new NFT only after the solution has been verified
    //  - make sure the solution is unique (has not been used before)
    //  - make sure you handle metadata as well as tokenSuplly
    function mintNFT(uint a, uint b, address to) public {
        bytes32 solutionHash = keccak256(abi.encodePacked(a, b));
        require(solutions[solutionHash].solutionAddress != address(0), "Solution doesn't exist");
        require(solutions[solutionHash].isMinted == false, "Token is already minted for this solution");
        require(solutions[solutionHash].solutionAddress == msg.sender, "Only solution's address can mint a token");
        super.mint(to, solutions[solutionHash].solutionIndex);
        solutions[solutionHash].isMinted = true;
    }
}



  


























