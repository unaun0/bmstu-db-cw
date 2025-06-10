//
//  TrainingRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 15.04.2025.
//

import Fluent
import Vapor
import Domain

public final class TrainingRepository {
    private let db: Database

    public init(db: Database) {
        self.db = db
    }
}

// MARK: - ITrainingRepository

extension TrainingRepository: ITrainingRepository {
    public func create(_ training: Training) async throws {
        try await TrainingDBDTO(from: training).create(on: db)
    }

    public func update(_ training: Training) async throws {
        guard
            let existing = try await TrainingDBDTO.find(
                training.id,
                on: db
            )
        else {
            throw TrainingError.trainingNotFound
        }

        existing.specializationId = training.specializationId
        existing.roomId = training.roomId
        existing.trainerId = training.trainerId
        existing.date = training.date

        try await existing.update(on: db)
    }

    public func delete(id: UUID) async throws {
        guard
            let training = try await TrainingDBDTO.find(
                id,
                on: db
            )
        else {
            throw TrainingError.trainingNotFound
        }

        try await training.delete(on: db)
    }

    public func find(id: UUID) async throws -> Training? {
        try await TrainingDBDTO.find(
            id,
            on: db
        )?.toTraining()
    }

    public func find(trainerId: UUID) async throws -> [Training] {
        return try await TrainingDBDTO.query(
            on: db
        ).filter(
            \.$trainerId == trainerId
        ).all().compactMap { $0.toTraining() }
    }

    public func find(specializationId: UUID) async throws -> [Training] {
        return try await TrainingDBDTO.query(
            on: db
        ).filter(
            \.$specializationId == specializationId
        ).all().compactMap { $0.toTraining() }
    }

    public func find(trainingRoomId: UUID) async throws -> [Training] {
        return try await TrainingDBDTO.query(
            on: db
        ).filter(
            \.$roomId == trainingRoomId
        ).all().compactMap { $0.toTraining() }
    }

    public func find(date: Date) async throws -> [Training] {
        return try await TrainingDBDTO.query(
            on: db
        ).filter(
            \.$date == date
        ).all().compactMap { $0.toTraining() }
    }

    public func findAll() async throws -> [Training] {
        try await TrainingDBDTO.query(
            on: db
        ).all().compactMap { $0.toTraining() }
    }
}
