// SPDX-Licence-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {ISuperchainTokenBridge} from "optimism/packages/contracts-bedrock/src/L2/interfaces/ISuperchainTokenBridge.sol";
import {ISuperchainWETH} from "optimism/packages/contracts-bedrock/src/L2/interfaces/ISuperchainWETH.sol";

contract SupersimInteractions is Script {
    address public constant SUPERCHAIN_TOKEN_BRIDGE =
        0x4200000000000000000000000000000000000028;
    address public constant SUPERCHAIN_WETH_TOKEN =
        0x4200000000000000000000000000000000000024;
    uint256 private privateKey;

    function mintWETH() public {
        vm.startBroadcast(privateKey);
        (bool success, ) = SUPERCHAIN_WETH_TOKEN.call{value: 1 ether}("");
        require(success, "Transfer failed!");
        vm.stopBroadcast();
        uint256 userBalanceOfWETH = ISuperchainWETH(
            payable(SUPERCHAIN_WETH_TOKEN)
        ).balanceOf(vm.addr(privateKey));
        console.log("WETH balance: ", userBalanceOfWETH);
    }

    function sendWETHToOtherChain(uint256 amount) public {
        uint256 chain_b_chainid = 902; // Chain ID for Chain B
        address to = vm.addr(privateKey); // send tokens to the same address on chain B
        console.log(
            "WETH balance before transfer: ",
            ISuperchainWETH(payable(SUPERCHAIN_WETH_TOKEN)).balanceOf(to)
        );
        vm.startBroadcast(privateKey);
        ISuperchainTokenBridge(SUPERCHAIN_TOKEN_BRIDGE).sendERC20(
            SUPERCHAIN_WETH_TOKEN,
            to,
            amount,
            chain_b_chainid
        );
        vm.stopBroadcast();
        console.log(
            "WETH balance after transfer: ",
            ISuperchainWETH(payable(SUPERCHAIN_WETH_TOKEN)).balanceOf(to)
        );
    }

    function getWETHTokenBalance() public view {
        address account = vm.addr(privateKey);
        uint256 balance = ISuperchainWETH(payable(SUPERCHAIN_WETH_TOKEN)).balanceOf(
            account
        );
        console.log("WETH balance of user: ", balance);
    }

    function run() public {
        privateKey = vm.envUint("ANVIL_ACCOUNT1_PRIVATE_KEY");
        // mintWETH();
        // sendWETHToOtherChain(1 ether);
        getWETHTokenBalance();
    }
}



// INFO [12-11|12:27:34.205] L2ToL2CrossChainMessenger#SentMessage    sourceChainID=901 destinationChainID=902 nonce=0 sender=0x4200000000000000000000000000000000000028 target=0x4200000000000000000000000000000000000028 txHash=0x2a186a3ce87b682d7ac86b2db753776fdbe6d88cff6b4d9c0c59e7540719f1ee
// INFO [12-11|12:27:34.203] SuperchainWETH#CrosschainBurn            chain.id=901 from=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 amount=1,000,000,000,000,000,000 sender=0x4200000000000000000000000000000000000028
// INFO [12-11|12:27:34.203] SuperchainTokenBridge#SendERC20          chain.id=901 token=0x4200000000000000000000000000000000000024 from=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 to=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 amount=1,000,000,000,000,000,000 destination=902
// INFO [12-11|12:27:36.198] SuperchainTokenBridge#RelayERC20         chain.id=902 token=0x4200000000000000000000000000000000000024 from=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 to=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 amount=1,000,000,000,000,000,000 source=901
// INFO [12-11|12:27:36.198] SuperchainWETH#CrosschainMint            chain.id=902 to=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 amount=1,000,000,000,000,000,000 sender=0x4200000000000000000000000000000000000028
// INFO [12-11|12:27:36.199] L2ToL2CrossChainMessenger#RelayedMessage sourceChainID=901 destinationChainID=902 nonce=0 sender=0x4200000000000000000000000000000000000028 target=0x4200000000000000000000000000000000000028 txHash=0xa220d1fc45bda705cbb04a64c5a03f008cbb7e37d01a0d4d2dfb5abdc1d803c7
