//
//  SpecializationMongoDBRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 29.05.2025.
//

import Fluent
import Vapor
import Domain

public final class SpecializationMongoDBRepository {
    private let db: Database

    public init(db: Database) {
        self.db = db
    }
}

// MARK: - ISpecializationRepository

extension SpecializationMongoDBRepository: ISpecializationRepository {
    public func create(_ specialization: Specialization) async throws {
        try await SpecializationMongoDBDTO(
            from: specialization
        ).create(on: db)
    }

    public func update(_ specialization: Specialization) async throws {
        guard
            let existing = try await SpecializationMongoDBDTO.find(
                specialization.id,
                on: db
            )
        else {
            throw SpecializationError.specializationNotFound
        }

        existing.name = specialization.name

        try await existing.update(on: db)
    }

    public func delete(id: UUID) async throws {
        guard
            let room = try await SpecializationMongoDBDTO.find(
                id,
                on: db
            )
        else {
            throw SpecializationError.specializationNotFound
        }

        try await room.delete(on: db)
    }

    public func find(id: UUID) async throws -> Specialization? {
        try await SpecializationMongoDBDTO.find(
            id, on: db
        )?.toSpecialization()
    }

    public func find(name: String) async throws -> Specialization? {
        try await SpecializationMongoDBDTO.query(
            on: db
        ).filter(
            \.$name == name
        ).first()?.toSpecialization()
    }

    public func findAll() async throws -> [Specialization] {
        return try await SpecializationMongoDBDTO.query(
            on: db
        ).all().compactMap { $0.toSpecialization() }
    }
}
