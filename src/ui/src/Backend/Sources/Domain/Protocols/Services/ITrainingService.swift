//
//  ITrainingService.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public protocol ITrainingService: Sendable {
    func create(_ data: TrainingCreateDTO) async throws -> Training?
    func update(
        id: UUID,
        with data: TrainingUpdateDTO
    ) async throws -> Training?
    func find(id: UUID) async throws -> Training?
    func find(trainerId: UUID) async throws -> [Training]
    func find(specializationId: UUID) async throws -> [Training]
    func find(trainingRoomId: UUID) async throws -> [Training]
    func find(date: Date) async throws -> [Training]
    func findAll() async throws -> [Training]
    func delete(id: UUID) async throws
}

public protocol ITrainingUserService: Sendable {
    func findAvailableTrainings() async throws -> [TrainingInfoDTO]
}

public protocol ITrainingTrainerService: Sendable {
    func findAvailableTrainings(userId: UUID) async throws -> [TrainingInfoDTO]
    func findAllTrainings(userId: UUID) async throws -> [TrainingInfoDTO]
    func create(userId: UUID, _ data: TrainingCreateDTO) async throws -> Training?
    func update(
        userId: UUID,
        trainingId: UUID,
        with data: TrainingUpdateDTO
    ) async throws -> Training?
    func delete(userId: UUID, trainingId: UUID) async throws
    func findAllRooms() async throws -> [TrainingRoom]
}
