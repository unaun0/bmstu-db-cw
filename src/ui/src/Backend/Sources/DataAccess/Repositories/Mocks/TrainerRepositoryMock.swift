//
//  TrainerRepositoryMock.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Foundation
import Domain

public actor TrainerRepositoryMock {
    private var trainers: [Trainer] = []
}

// MARK: - ITrainerRepository

extension TrainerRepositoryMock: ITrainerRepository {
    public func create(_ trainer: Trainer) async throws {
        trainers.append(trainer)
    }

    public func update(_ trainer: Trainer) async throws {
        guard
            let index = trainers.firstIndex(
                where: {
                    $0.id == trainer.id
                }
            )
        else { return }

        trainers[index] = trainer
    }

    public func find(id: UUID) async throws -> Trainer? {
        trainers.first(where: { $0.id == id })
    }

    public func find(userId: UUID) async throws -> Trainer? {
        trainers.first(where: { $0.userId == userId })
    }

    public func findAll() async throws -> [Trainer] {
        trainers
    }

    public func delete(id: UUID) async throws {
        guard
            let index = trainers.firstIndex(
                where: {
                    $0.id == id
                }
            )
        else { throw TrainerError.trainerNotFound }

        trainers.remove(at: index)
    }
}
