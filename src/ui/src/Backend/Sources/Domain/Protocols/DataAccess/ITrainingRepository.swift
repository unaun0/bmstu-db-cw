//
//  ITrainingRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Vapor

public protocol ITrainingRepository: Sendable {
    func create(_ training: Training) async throws
    func update(_ training: Training) async throws
    func delete(id: UUID) async throws
    func find(id: UUID) async throws -> Training?
    func find(trainerId: UUID) async throws -> [Training]
    func find(specializationId: UUID) async throws -> [Training]
    func find(trainingRoomId: UUID) async throws -> [Training]
    func find(date: Date) async throws -> [Training]
    func findAll() async throws -> [Training]
}
