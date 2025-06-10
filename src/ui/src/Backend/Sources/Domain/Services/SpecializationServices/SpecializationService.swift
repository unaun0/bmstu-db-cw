//
//  SpecializationService.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Fluent
import Vapor

public final class SpecializationService {
    private let repository: ISpecializationRepository
    
    public init(repository: ISpecializationRepository) {
        self.repository = repository
    }
}

// MARK: - ISpecializationService

extension SpecializationService: ISpecializationService {
    public func create(
        _ data: SpecializationCreateDTO
    ) async throws -> Specialization? {
        if try await repository.find(name: data.name) != nil {
            throw SpecializationError.nameAlreadyExists
        }
        let specialization = Specialization(
            id: UUID(),
            name: data.name
        )
        try await repository.create(specialization)

        return specialization
    }

    public func update(
        id: UUID,
        with data: SpecializationUpdateDTO
    ) async throws -> Specialization? {
        guard
            let specialization = try await repository.find(
                id: id
            )
        else { throw SpecializationError.specializationNotFound }
        if let name = data.name {
            if try await repository.find(name: name) != nil {
                throw SpecializationError.nameAlreadyExists
            }
            specialization.name = name
        }
        try await repository.update(specialization)
        return specialization
    }

    public func find(id: UUID) async throws -> Specialization? {
        return try await repository.find(id: id)
    }

    public func find(name: String) async throws -> Specialization? {
        return try await repository.find(name: name)
    }

    public func findAll() async throws -> [Specialization] {
        return try await repository.findAll()
    }

    public func delete(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
