pragma solidity ^0.4.24;

import "./ERC721Token.sol";

 /**
 * @title Repository of ERC721 Tokens
 * This contract contains the list of tokens registered by users
 * Shows how tokens can be minted and added to the repository
 */
 contract TokenRepository is ERC721Token {

   /**
   * @dev Created a TokenRepository with a name and symbol
   * @param name string represents the name of the repository
   * @param symbol string represents the symbol of the repository
   */
   constructor(string name, string symbol) public ERC721Token(name, symbol) { }
    
   /**
   * @dev Registers a new token and add metadata to a token
   * @dev Call the ERC721Token minter
   * @param tokenId uint represents s pecific token
   * @param uri string containing metadata/uri that characterised a given token
   */
   function registerToken(uint tokenId, string uri) public {
       _mint(msg.sender, tokenId);
       _setTokenURI(tokenId, uri);
       emit TokenRegistered(msg.sender, tokenId);
   }
   
   /**
   * @dev Gets list of owned token IDs
   * @param owner address representing the owner
   * @return list of owned tokens
   */
   function getOwnedTokens(address owner) public view returns(uint[]){
       return ownedTokens[owner];
   }
   
   /**
   * @dev Removes a token ID from the list of a given address
   * @param from address representing the previous owner of the given token ID
   * @param tokenId uint ID of the token to be removed from the tokens list of the given address
   */
   function removeToken(address from, uint tokenId) public {
       return removeTokenFrom(from, tokenId);
   }
   
   /**
   * @dev Event is registered if token is registered
   * @param by address of the registrar
   * @param tokenId uint represents a specific token
   */
   event TokenRegistered(address by, uint tokenId);
}

 /**
 * @title Dog Adoption Repository
 * This contract allows dog adopters to be created for non-fungible tokens and participate in dog adaption
 */
 contract DogAdoptionRepository {
    
    // Dog adoption struct
    struct DogAdoption {
      string name;
      address tokenRegistrationAddress; 
      uint tokenId;
      address owner;
      bool approved;
      bool canceled;
      uint endBlock;
    }
    
    // Array with all dog adoptions
    DogAdoption[] public dogAdoptions; 
   
    // Dog adopter to hold dog adopter address, amount, tokenId, and refunded
    struct DogAdopter {
     address from;
     uint amount;
     uint tokenId;
     bool refunded;
    }
   
    // Mapping from dog adoption index to dog adoption addresses
    mapping(uint => address[]) public dogAdopterAddresses;
    
    // Mapping from dog adoption index to mapping from dog adopter address to dog adopter
    mapping(uint => mapping(address => DogAdopter)) public dogAdopters;  //Remove public. It is only for Remix debugging
   
    /**
    * @dev Creates a dog adoption with the given information
    * @param name string containing dog adoption name
    * @param tokenRegistrationAddress address of the TokenRepository contract
    * @param tokenId uint of the token registered in TokenRepository
    * @param endBlock uint of an Ethereum block
    */
    function createDogAdoption(string name, address tokenRegistrationAddress, uint tokenId, uint endBlock) 
        contractIsTokenOwner(tokenRegistrationAddress, tokenId) public {
        
        DogAdoption memory newDogAdoption = DogAdoption({
            name: name, 
            tokenRegistrationAddress: tokenRegistrationAddress, 
            tokenId: tokenId, 
            owner: msg.sender, 
            approved: false,
            canceled: false,
            endBlock: endBlock
        });
        
        dogAdoptions.push(newDogAdoption);
        
        emit DogAdoptinCreated(msg.sender, name);
    }
    
    /**
    * @dev Adding a dog adopter
    * @dev Dog adoption should be an active and not ended
    * @param dogAdoptionId uint of the dog adoption
    * @param tokenRegistrationAddress address of the TokenRepository contract
    * @param tokenId uint of the token registered in TokenRepository
    */
    function addDogAdopter(uint dogAdoptionId, address tokenRegistrationAddress, uint tokenId) 
        contractIsTokenOwner(tokenRegistrationAddress, tokenId) isNotOwner(dogAdoptionId) 
        /* beforeEnd(dogAdopterId) commented for remix debugging*/  public payable {

        DogAdopter memory existingAdopter = dogAdopters[dogAdoptionId][msg.sender];
        
        require(existingAdopter.tokenId == 0, "You already have been added as a dog adopter to this dog adoption");
        
        DogAdopter memory adopter = DogAdopter({
            from: msg.sender,
            amount: msg.value,
            tokenId: tokenId,
            refunded: false
        });
    
        dogAdopters[dogAdoptionId][msg.sender] = adopter;
        dogAdopterAddresses[dogAdoptionId].push(msg.sender);
        
        emit DogAdopterAdded(msg.sender, dogAdoptionId);
    }
    
    /**
    * @dev Cancels an ongoing dog adoption by the owner
    * @dev TokenId is transfered back to the dog adotion owner
    * @param dogAdoptionId uint ID of the created dog adoption
    */
    function cancelDogAdoption(uint dogAdoptionId) 
        isOwner(dogAdoptionId) notApproved(dogAdoptionId) notCaneled(dogAdoptionId) public {
            
        DogAdoption storage dogAdoption = dogAdoptions[dogAdoptionId];
        dogAdoption.canceled = true;
        
        if(approveAndTransfer(address(this), dogAdoption.owner, dogAdoption.tokenRegistrationAddress, dogAdoption.tokenId)) {
        }
    }
    
    /**
    * @dev Dog adoption owner approves a dog adopter
    * @param dogAdoptionId uint ID of the created dog adoption 
    * @param dogAdopterAddress address of a dog adopter 
    */ 
    function approveDogAdopter(uint dogAdoptionId, address dogAdopterAddress) 
        isOwner(dogAdoptionId) notApproved(dogAdoptionId) notCaneled(dogAdoptionId) public {

        DogAdopter storage dogAdopter = dogAdopters[dogAdoptionId][dogAdopterAddress];
        
        require(dogAdopter.tokenId != 0, "Dog Adopter is not found");
        
        DogAdoption memory dogAdoption = dogAdoptions[dogAdoptionId];
        
        // Money goes to the dog adoption owner
        if(!dogAdoption.owner.send(dogAdopter.amount)) {
            revert("Can not send money to dog adotption owner");
        }
        
        dogAdopter.refunded = true;
        
        // approve and transfer from this contract to approved dog adopter the dogadopter tokenId
        if(approveAndTransfer(address(this), dogAdopter.from, dogAdoption.tokenRegistrationAddress, dogAdopter.tokenId)) {
            
            // approve and transfer from this contract to approved dog adopter the dogadoption tokenId
            if(approveAndTransfer(address(this), dogAdopter.from, dogAdoption.tokenRegistrationAddress, dogAdoption.tokenId)) {
                dogAdoption.approved = true;
                emit DogAdopterApproved(msg.sender, dogAdoptionId);
            }
        }
    }
    
    /**
    * @dev Dog adopter withrows his/her money for the dog adoption
    * @param dogAdoptionId uint ID of the created dog adoption
    */
    function withdraw(uint dogAdoptionId) canceledOrEnded(dogAdoptionId) isNotOwner(dogAdoptionId) public {
        
        DogAdopter storage dogAdopter = dogAdopters[dogAdoptionId][msg.sender];
        
        if(dogAdopter.refunded == false) {
            //Refund the dog adopter
            if(!dogAdopter.from.send(dogAdopter.amount)) {
                revert("Failed to send money to a registered dog adopter");
            }
            
            dogAdopter.refunded = true;
            
            DogAdoption memory dogAdoption = dogAdoptions[dogAdoptionId];
            
            // approve and transfer from this contract to the dog adopter the dogadoption tokenId
            if(approveAndTransfer(address(this), dogAdopter.from, dogAdoption.tokenRegistrationAddress, dogAdopter.tokenId)) {
               emit DogAdopterRefunded(msg.sender, dogAdoptionId);
            }
        }
    }
    
    /**
    * @dev Gets dog adopters addresses for a dog adoption 
    * @param dogAdoptionId uint ID of the created dog adoption
    * @return uint representing the dog adopters count
    */
    function getDogAdopterAddressesCount(uint dogAdoptionId) view public returns(uint){
        return dogAdopterAddresses[dogAdoptionId].length;
    }
    
    /**
    * @dev Gets dog adopter info
    * @param dogAdoptionId uint ID of the created dog adoption 
    * @param position uint of dog adopter addresses of the specified dog adoption
    * @return from address of a dog adopter
    * @return amount uint of a dog adopter
    * @return refunded bool of a dog adopter
    */
    function getDogAdopter(uint dogAdoptionId, uint position) view public returns (address from, uint amount, bool refunded) {
        address dogAdopteraddress = dogAdopterAddresses[dogAdoptionId][position];
        
        DogAdopter memory dogAdopter = dogAdopters[dogAdoptionId][dogAdopteraddress];
        
        require(dogAdopter.tokenId != 0, "Dog Adopter is not found");
        
        return(
            dogAdopter.from,
            dogAdopter.amount,
            dogAdopter.refunded
        );
    }

    //Only for Remix debugging
    function currentBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    /**
    * @dev Disallow payments to this contract directly
    */
    function() public payable {
        revert("Direct payments to this contract is disallowed");
    }
    
    function approveAndTransfer(address from, address to, address tokenRegistrationAddress, uint tokenId) internal returns(bool) {
        TokenRepository remoteContract = TokenRepository(tokenRegistrationAddress);
        remoteContract.approve(to, tokenId);
        remoteContract.transferFrom(from, to, tokenId);
        return true;
    }
    
    /**
    * @dev Guarantees this contract is owner of the given token
    * @param tokenRegistrationAddress address of the token respository to validate from
    * @param tokenId uint ID of the token which has been registered in the token repository
    */
    modifier contractIsTokenOwner(address tokenRegistrationAddress, uint tokenId) {
        address tokenOwner = TokenRepository(tokenRegistrationAddress).ownerOf(tokenId);
        require(tokenOwner == address(this), "Contract is not owner of given token");
        _;
    }
    
    /**
    * @dev Guarantees msg.sender is onwer of the given dog adoption
    * @param dogAdoptionId uint ID of the dog adoption to validate its ownership belongs to msg.sender
    */
    modifier isOwner(uint dogAdoptionId) {
        require(dogAdoptions[dogAdoptionId].owner == msg.sender, "Message sender is not the dog adoption owner");
        _;
    }
    
    /**
     * @dev Guarantees msg.sender is not onwer of the given dog adoption
     * @param dogAdoptionId uint ID of the dog adoption to validate its ownership does not belong to msg.sender
    */
    modifier isNotOwner(uint dogAdoptionId) {
        require(dogAdoptions[dogAdoptionId].owner != msg.sender, "Message sender is the dog adoption owner");
        _;
    }
    
    /**
    * @dev Guarantees dog adoption is not approved
    * @param dogAdoptionId uint ID of the created dog adoption
    */
    modifier notApproved(uint dogAdoptionId) {
        require(dogAdoptions[dogAdoptionId].approved == false, "Dog adoption is already approved");
        _;
    }
    
    /**
     * @dev Guarantees dog adoption is canceled
     * @param dogAdoptionId uint ID of the created dog adoption
    */
    modifier caneled(uint dogAdoptionId) {
        require(dogAdoptions[dogAdoptionId].canceled == true, "Dog adoption is not canceled");
        _;
    }
    
    /**
    * @dev Guarantees dog adoption is not canceled
    * @param dogAdoptionId uint ID of the created dog adoption
    */
    modifier notCaneled(uint dogAdoptionId) {
        require(dogAdoptions[dogAdoptionId].canceled == false, "Dog adoption is already canceled");
        _;
    }
   
    /**
    * @dev Guarantees dog adoption block number is less than the current Ethereum block number
    * @param dogAdoptionId uint ID of the created dog adoption
    */
    modifier beforeEnd(uint dogAdoptionId) {
        require(block.number < dogAdoptions[dogAdoptionId].endBlock, "Dog adoption has already ended");
        _;
    }
    
    /**
    * @dev Guarantees dog adoption is either canceled or ended
    * @param dogAdoptionId uint ID of the created dog adoption
    */
    modifier canceledOrEnded(uint dogAdoptionId) {
       // require(dogAdoptions[dogAdoptionId].canceled == true || block.number >= dogAdoptions[dogAdoptionId].endBlock, 
       require(dogAdoptions[dogAdoptionId].canceled == true, // we need this line for remix debugging. In the app the line above.
        "You can withdraw your money after dog adoption is ended or canceled");
        _;
    }
    
    // DogAdoptinCreated is fired when a dog adoption is created
    event DogAdoptinCreated(address owner, string dogAdoptionName);
    
    // DogAdopterApproved is fired when a dog adopter is selected
    event DogAdopterApproved(address owner, uint dogAdoptionId);
    
    // DogAdopterAdded is fired when a dog adopter is added
    event DogAdopterAdded(address from, uint dogAdoptionId);
    
    // DogAdoptionCanceled is fired when a dog adoption is canceled
    event DogAdoptionCanceled(address owner, uint dogAdoptionId);
    
    // DogAdopterRefunded is fired when a dog adopter is refunded
    event DogAdopterRefunded(address from, uint dogAdoptionId);
    
}

