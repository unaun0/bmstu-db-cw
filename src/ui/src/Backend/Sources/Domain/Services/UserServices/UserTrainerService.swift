//
//  UserTrainerService.swift
//  Backend
//
//  Created by Цховребова Яна on 04.05.2025.
//

import Vapor

public final class UserTrainerService {
    private let service: IUserService
    
    public init(userService: IUserService) {
        self.service = userService
    }
}

// MARK: - IUserTrainerService

extension UserTrainerService: IUserTrainerService {
    public func findClient(byID id: UUID) async throws -> User? {
        try await service.find(id: id)
    }

    public func findClient(byEmail email: String) async throws -> User? {
        try await service.find(email: email)
    }

    public func findClient(byPhone phoneNumber: String) async throws -> User? {
        try await service.find(phoneNumber: phoneNumber)
    }

    public func findAllClients() async throws -> [User] {
        try await service.findAll()
    }
}
