// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: Copyright 2024 Symbiotic
pragma solidity 0.8.25;

interface IFactory {
    error EntityNotExist();

    /**
     * @notice Emitted when an entity is added.
     * @param entity address of the added entity
     */
    event AddEntity(address indexed entity);

    /**
     * @notice Get if a given address is an entity.
     * @param entity address to check
     * @return if the given address is an entity
     */
    function isEntity(address entity) external view returns (bool);

    /**
     * @notice Get a total number of entities.
     * @return total number of entities created
     */
    function totalEntities() external view returns (uint256);

    /**
     * @notice Get an entity given its index.
     * @param index index of the entity to get
     * @return address of the entity
     */
    function entity(uint256 index) external view returns (address);
}
