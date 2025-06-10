//
//  SpecializationRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Fluent
import Vapor
import Domain

public final class SpecializationRepository {
    private let db: Database

    public init(db: Database) {
        self.db = db
    }
}

// MARK: - ISpecializationRepository

extension SpecializationRepository: ISpecializationRepository {
    public func create(_ specialization: Specialization) async throws {
        try await SpecializationDBDTO(
            from: specialization
        ).create(on: db)
    }

    public func update(_ specialization: Specialization) async throws {
        guard
            let existing = try await SpecializationDBDTO.find(
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
            let room = try await SpecializationDBDTO.find(
                id,
                on: db
            )
        else {
            throw SpecializationError.specializationNotFound
        }

        try await room.delete(on: db)
    }

    public func find(id: UUID) async throws -> Specialization? {
        try await SpecializationDBDTO.find(
            id, on: db
        )?.toSpecialization()
    }

    public func find(name: String) async throws -> Specialization? {
        try await SpecializationDBDTO.query(
            on: db
        ).filter(
            \.$name == name
        ).first()?.toSpecialization()
    }

    public func findAll() async throws -> [Specialization] {
        return try await SpecializationDBDTO.query(
            on: db
        ).all().compactMap { $0.toSpecialization() }
    }
}
