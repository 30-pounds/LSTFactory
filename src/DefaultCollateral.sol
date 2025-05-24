// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: Copyright 2024 Symbiotic
pragma solidity 0.8.25;

import {IDefaultCollateral} from "src/interfaces/defaultCollateral/IDefaultCollateral.sol";
import {ICollateral} from "src/interfaces/ICollateral.sol";
import {Permit2Lib} from "src/interfaces/Permit2Lib.sol";

import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DefaultCollateral is ERC20Upgradeable, ReentrancyGuardUpgradeable, IDefaultCollateral {
    using SafeERC20 for IERC20;
    using Permit2Lib for IERC20;

    uint8 private DECIMALS;

    /**
     * @inheritdoc ICollateral
     */
    address public asset;

    /**
     * @inheritdoc ICollateral
     */
    uint256 public totalRepaidDebt;

    /**
     * @inheritdoc ICollateral
     */
    mapping(address => uint256) public issuerRepaidDebt;

    /**
     * @inheritdoc ICollateral
     */
    mapping(address => uint256) public recipientRepaidDebt;

    /**
     * @inheritdoc ICollateral
     */
    mapping(address => mapping(address => uint256)) public repaidDebt;

    /**
     * @inheritdoc ICollateral
     */
    uint256 public totalDebt;

    /**
     * @inheritdoc ICollateral
     */
    mapping(address => uint256) public issuerDebt;
}