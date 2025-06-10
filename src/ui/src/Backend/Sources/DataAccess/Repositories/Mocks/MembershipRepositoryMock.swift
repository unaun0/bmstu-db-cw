//
//  MembershipRepositoryMock.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Foundation
import Domain

public actor MembershipRepositoryMock {
    private var memberships: [Membership] = []
}

// MARK: - IMembershipRepository

extension MembershipRepositoryMock: IMembershipRepository {
    public func create(_ membership: Membership) async throws {
        memberships.append(membership)
    }

    public func update(_ membership: Membership) async throws {
        guard
            let index = memberships.firstIndex(
                where: {
                    $0.id == membership.id
                }
            )
        else { return }

        memberships[index] = membership
    }

    public func delete(id: UUID) async throws {
        guard
            let index = memberships.firstIndex(
                where: { $0.id == id }
            )
        else {
            throw MembershipError.membershipNotFound
        }

        memberships.remove(at: index)
    }

    public func find(id: UUID) async throws -> Membership? {
        memberships.first(where: { $0.id == id })
    }
    
    public func find(userId: UUID) async throws -> [Membership] {
        memberships.filter { $0.userId == userId }
    }

    public func find(membershipTypeId: UUID) async throws -> [Membership] {
        memberships.filter { $0.membershipTypeId == membershipTypeId }
    }

    public func findAll() async throws -> [Membership] {
        memberships
    }
}
