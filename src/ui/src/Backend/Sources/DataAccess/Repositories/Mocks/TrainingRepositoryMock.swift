//
//  TrainingRepositoryMock.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Foundation
import Domain

public actor TrainingRepositoryMock {
    private var trainings: [Training] = []
}

// MARK: - ITrainingRepository

extension TrainingRepositoryMock: ITrainingRepository {
    public func create(_ training: Training) async throws {
        trainings.append(training)
    }

    public func update(_ training: Training) async throws {
        guard
            let index = trainings.firstIndex(
                where: {
                    $0.id == training.id
                }
            )
        else { return }

        trainings[index] = training
    }

    public func delete(id: UUID) async throws {
        guard
            let index = trainings.firstIndex(
                where: {
                    $0.id == id
                }
            )
        else {
            throw TrainingError.trainingNotFound
        }
        trainings.remove(at: index)
    }

    public func find(id: UUID) async throws -> Training? {
        trainings.first(where: { $0.id == id })
    }

    public func find(trainerId: UUID) async throws -> [Training] {
        trainings.filter { $0.trainerId == trainerId }
    }

    public func find(specializationId: UUID) async throws -> [Training] {
        trainings.filter { $0.specializationId == specializationId }
    }

    public func find(trainingRoomId: UUID) async throws -> [Training] {
        trainings.filter { $0.roomId == trainingRoomId }
    }

    public func find(date: Date) async throws -> [Training] {
        trainings.filter {
            Calendar.current.isDate(
                $0.date,
                inSameDayAs: date
            )
        }
    }

    public func findAll() async throws -> [Training] {
        trainings
    }
}
