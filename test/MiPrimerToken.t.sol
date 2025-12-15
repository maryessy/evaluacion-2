// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MiPrimerToken} from "../src/MiPrimerToken.sol";

contract MiPrimerTokenTest is Test {
    MiPrimerToken token;
    uint256 constant INITIAL_SUPPLY = 1000000 * 10 ** 18;

    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        token = new MiPrimerToken();
    }

    // --- 1. Verificar Suministro Inicial (Total Supply) ---
    function test_VerifyTotalSupply() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY, "Total supply no es 1M");
    }

    // --- 2. Verificar Balance del Deployer (address(this)) ---
    function function_VerifyDeployerBalance() public view {
        assertEq(
            token.balanceOf(address(this)),
            INITIAL_SUPPLY,
            "Deployer no tiene el balance completo"
        );
    }

    // --- 3. Probar Transferencias Básicas (Válidas) ---
    function test_Transfer_Valid() public {
        uint256 transferAmount = 100 * 10 ** 18;

        token.transfer(user1, transferAmount);

        assertEq(
            token.balanceOf(address(this)),
            INITIAL_SUPPLY - transferAmount,
            "Balance del Deployer incorrecto"
        );
        assertEq(
            token.balanceOf(user1),
            transferAmount,
            "Balance del User1 incorrecto"
        );
    }

    // --- 4. Probar Transferencia Inválida (Insuficiente Balance) ---
    function test_Transfer_InsufficientBalance() public {
        address sender = address(this);
        uint256 excessAmount = INITIAL_SUPPLY + 1;

        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(
                    keccak256(
                        "ERC20InsufficientBalance(address,uint256,uint256)"
                    )
                ),
                sender,
                INITIAL_SUPPLY,
                excessAmount
            )
        );

        token.transfer(user1, excessAmount);
    }

    // --- 5. Probar Approve y TransferFrom (Flujo Completo) ---
    function test_Approve_TransferFrom_Flow() public {
        uint256 allowanceAmount = 50 * 10 ** 18;
        uint256 transferAmount = 30 * 10 ** 18;
        address deployer = address(this);

        token.approve(user1, allowanceAmount);

        assertEq(
            token.allowance(deployer, user1),
            allowanceAmount,
            "Allowance incorrecto"
        );

        vm.startPrank(user1);
        token.transferFrom(deployer, user2, transferAmount);
        vm.stopPrank();

        assertEq(
            token.allowance(deployer, user1),
            allowanceAmount - transferAmount,
            "Allowance restante incorrecto"
        );
        assertEq(
            token.balanceOf(deployer),
            INITIAL_SUPPLY - transferAmount,
            "Balance del Deployer incorrecto"
        );
        assertEq(
            token.balanceOf(user2),
            transferAmount,
            "Balance del User2 incorrecto"
        );
    }

    // --- 6. Fuzzing de Transferencias ---
    function testFuzz_Transfer(uint256 amount) public {
        amount = bound(amount, 0, INITIAL_SUPPLY);

        token.transfer(user1, amount);

        assertEq(
            token.balanceOf(user1),
            amount,
            "Fuzz Transfer fallo para el receptor"
        );
        assertEq(
            token.balanceOf(address(this)),
            INITIAL_SUPPLY - amount,
            "Fuzz Transfer fallo para el emisor"
        );
    }
}
