//
//  SpecializationRepositoryMock.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Foundation
import Domain

public actor SpecializationRepositoryMock {
    private var specializations: [Specialization] = []
}

// MARK: - ISpecializationRepository

extension SpecializationRepositoryMock: ISpecializationRepository {
    public func create(_ specialization: Specialization) async throws {
        specializations.append(specialization)
    }

    public func update(_ specialization: Specialization) async throws {
        guard
            let index = specializations.firstIndex(
                where: {
                    $0.id == specialization.id
                }
            )
        else { return }

        specializations[index] = specialization
    }

    public func delete(id: UUID) async throws {
        guard
            let index = specializations.firstIndex(
                where: {
                    $0.id == id
                }
            )
        else {
            throw SpecializationError.specializationNotFound
        }

        specializations.remove(at: index)
    }

    public func find(id: UUID) async throws -> Specialization? {
        specializations.first(where: { $0.id == id })
    }

    public func find(name: String) async throws -> Specialization? {
        specializations.first(where: { $0.name == name })
    }

    public func findAll() async throws -> [Specialization] {
        specializations
    }
}
