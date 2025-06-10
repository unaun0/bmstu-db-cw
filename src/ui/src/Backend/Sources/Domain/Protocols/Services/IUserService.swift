//
//  IUserService.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Vapor

public protocol IUserService: Sendable {
    func create(_ data: UserCreateDTO) async throws -> User?
    func update(id: UUID, with data: UserUpdateDTO) async throws -> User?
    func find(email: String) async throws -> User?
    func find(id: UUID) async throws -> User?
    func find(phoneNumber: String) async throws -> User?
    func find(role: String) async throws -> [User]
    func delete(id: UUID) async throws
    func findAll() async throws -> [User]
}

public protocol IUserTrainerService: Sendable {
    func findClient(byID id: UUID) async throws -> User?
    func findClient(byEmail email: String) async throws -> User?
    func findClient(byPhone phoneNumber: String) async throws -> User?
    func findAllClients() async throws -> [User]
}

public protocol IUserSelfService: Sendable {
    func getMyProfile(id: UUID) async throws -> User?
    func updateMyProfile(id: UUID, data: UserSelfUpdateDTO) async throws -> User?
    func deleteMyProfile(id: UUID) async throws
}

