//
//  UserRepositoryMock.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Foundation
import Domain

public actor UserRepositoryMock {
    private var users: [User] = []
}

// MARK: - IUserRepository

extension UserRepositoryMock: IUserRepository {
    public func create(_ user: User) async throws {
        users.append(user)
    }

    public func update(_ user: User) async throws {
        guard
            let index = users.firstIndex(
                where: {
                    $0.id == user.id
                }
            )
        else { return }

        users[index] = user
    }

    public func delete(id: UUID) async throws {
        if let index = users.firstIndex(where: { $0.id == id }) {
            users.remove(at: index)
        }
    }

    public func find(email: String) async throws -> User? {
        users.first { $0.email == email }
    }

    public func find(phoneNumber: String) async throws -> User? {
        users.first { $0.phoneNumber == phoneNumber }
    }

    public func find(id: UUID) async throws -> User? {
        users.first { $0.id == id }
    }
    
    public func find(role: String) async throws -> [User] {
        users.filter { $0.role.rawValue == role }
    }

    public func findAll() async throws -> [User] {
        users
    }
}
