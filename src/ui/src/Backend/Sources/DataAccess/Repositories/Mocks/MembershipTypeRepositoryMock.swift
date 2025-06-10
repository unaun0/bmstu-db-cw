//
//  MembershipTypeRepositoryMock.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Foundation
import Domain

public actor MembershipTypeRepositoryMock {
    private var membershipTypes: [MembershipType] = []
}

// MARK: - IMembershipTypeRepository

extension MembershipTypeRepositoryMock: IMembershipTypeRepository {
    public func create(_ membershipType: MembershipType) async throws {
        membershipTypes.append(membershipType)
    }

    public func update(_ membershipType: MembershipType) async throws {
        guard
            let index = membershipTypes.firstIndex(
                where: {
                    $0.id == membershipType.id
                }
            )
        else { return }

        membershipTypes[index] = membershipType
    }

    public func delete(id: UUID) async throws {
        guard
            let index = membershipTypes.firstIndex(
                where: {
                    $0.id == id
                }
            )
        else {
            throw MembershipTypeError.membershipTypeNotFound
        }

        membershipTypes.remove(at: index)
    }

    public func find(id: UUID) async throws -> MembershipType? {
        membershipTypes.first(where: { $0.id == id })
    }

    public func find(name: String) async throws -> MembershipType? {
        membershipTypes.first(where: { $0.name == name })
    }

    public func findAll() async throws -> [MembershipType] {
        membershipTypes
    }
}
