//
//  TrainerSpecializationRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Fluent
import Vapor
import Domain

public final class TrainerSpecializationMongoDBRepository {
    private let db: Database

    public init(db: Database) {
        self.db = db
    }
}

// MARK: - ITrainerSpecializationRepository

extension TrainerSpecializationMongoDBRepository: ITrainerSpecializationRepository {
    public func create(_ trainerSpecialization: TrainerSpecialization) async throws {
        try await TrainerSpecializationMongoDBDTO(
            from: trainerSpecialization
        ).create(on: db)
    }

    public func update(_ trainerSpecialization: TrainerSpecialization) async throws {
        guard
            let existing = try await TrainerSpecializationMongoDBDTO.find(
                trainerSpecialization.id,
                on: db
            )
        else {
            throw TrainerSpecializationError.trainerSpecializationNotFound
        }

        existing.trainerId = trainerSpecialization.trainerId
        existing.specializationId = trainerSpecialization.specializationId
        existing.years = trainerSpecialization.years

        try await existing.update(on: db)
    }

    public func delete(id: UUID) async throws {
        guard
            let entity = try await TrainerSpecializationMongoDBDTO.find(
                id,
                on: db
            )
        else {
            throw TrainerSpecializationError.trainerSpecializationNotFound
        }

        try await entity.delete(on: db)
    }

    public func find(id: UUID) async throws -> TrainerSpecialization? {
        try await TrainerSpecializationMongoDBDTO.find(
            id,
            on: db
        )?.toTrainerSpecialization()
    }

    public func find(trainerId: UUID) async throws -> [TrainerSpecialization] {
        try await TrainerSpecializationMongoDBDTO.query(
            on: db
        ).filter(
            \.$trainerId == trainerId
        ).all().compactMap { $0.toTrainerSpecialization() }
    }

    public func find(specializationId: UUID) async throws -> [TrainerSpecialization] {
        try await TrainerSpecializationMongoDBDTO.query(
            on: db
        ).filter(
            \.$specializationId == specializationId
        ).all().compactMap { $0.toTrainerSpecialization() }
    }

    public func findAll() async throws -> [TrainerSpecialization] {
        try await TrainerSpecializationMongoDBDTO.query(
            on: db
        ).all().compactMap { $0.toTrainerSpecialization() }
    }
}
