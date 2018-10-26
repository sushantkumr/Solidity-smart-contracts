/**
 * @title Shopping
 * @section DESCRIPTION
 * Simple shopping operations
 * Deployed at https://rinkeby.etherscan.io/address/0x14c200ef28c6de1e061096e827be85639a591628
 */

import "./ReentrancyGuard.sol";
import "./SafeMath.sol";

pragma solidity ^0.4.24;

contract Shopping  is ReentrancyGuard {

    using SafeMath for uint256;

    struct Product {
        bytes32 id;
        uint256 price;
    }
    
    address public admin;
    mapping(address => bool) public sellers;
    mapping (address => Product[]) public sellersProductsList;
    mapping (address => bytes32[]) private buyersProductList;
    uint256 public productsCount;
    
    modifier isAdmin() {
        require(msg.sender == admin);
        _;
    }
    
    modifier isSeller() {
        require(sellers[msg.sender]);
        _;
    }

    /**
    * @dev Setting admin
    */    
    constructor () public {
        admin = msg.sender;
    }

    /**
    * @dev Added seller as authorized to sell on this platform
    * @param addressOfSeller address of the seller
    */    
    function addSeller(address addressOfSeller) isAdmin public {
        sellers[addressOfSeller] = true;
    }
    
    /**
    * @dev Check if the product exsists in the list of products
    * @param _seller address of the registered seller
    * @param _id id of the registered product
    * @return uint256 price of the product if it does not exist it returns 0
    */ 
    function checkIfProductExists(address _seller, bytes32 _id) private view returns(uint256) {
        Product[] storage sellersProducts = sellersProductsList[_seller];
         for(uint256 i = 0; i < sellersProducts.length; i = i.add(1)) {
            Product memory existingProdcut = sellersProducts[i];
            if(existingProdcut.id == _id)
                return existingProdcut.price;
        }
        return 0;
    }
    
    /**
    * @dev Adding buyer to the complete list
    * @param _id id of the product bought by the buyer
    */
    function addBuyer(bytes32 _id) private {
        bytes32[] storage buyerProdcuts = buyersProductList[msg.sender];
        buyerProdcuts.push(_id);
    }

    /**
    * @dev Add products to the list of the products of the seller
    * @param _id id of the product bought by the buyer
    */
    function addProduct(bytes32 _id, uint256 _price) isSeller public {
        Product memory newProduct = Product({ id: _id, price: _price });
        Product[] storage sellersProducts = sellersProductsList[msg.sender];
        uint256 doesItHaveAPrice = checkIfProductExists(msg.sender, _id);
        
        if(doesItHaveAPrice == 0) {
            sellersProducts.push(newProduct);
            productsCount = productsCount.add(1);
        }
    }
    
    /**
    * @dev Buying contents from the seller
    * @param _id id of the product bought by the buyer
    * @param _seller seller from whom the buyer wants to buy the product
    */
    function buyContent(bytes32 _id, address _seller) nonReentrant payable public {
        uint256 price = checkIfProductExists(_seller, _id);
        if(price != 0) {
            if(msg.value >= price) {
                addBuyer(_id);
                uint256 paymentForProduct = price;
                uint256 balanceToBeReturned = msg.value.sub(price);
                msg.sender.transfer(balanceToBeReturned);
                _seller.transfer(paymentForProduct);
            }
            
            else {
                revert();
            }
        }
        else {
            revert();
        }
    }
    
    /**
    * @dev Getting the count of the products added to the system
    * @return uint256 product count
    */
    function getContentCount() public view returns(uint256) {
        return productsCount;
    }
    
    /**
    * @dev Check if the buyer has purchased a particular product
    * @param _id id of the product bought by the buyer
    * @param _buyer address of the buyer
    * @return bool if purchased or not
    */
    function checkIfProductPurchased(address _buyer, bytes32 _id) public view returns(bool) {
        bytes32[] storage buyerProdcuts = buyersProductList[_buyer];
        for(uint256 i = 0; i < buyerProdcuts.length; i = i.add(1)) {
            if(buyerProdcuts[i] == _id) {
                return true;
            }
        }
        return false;
    }
}