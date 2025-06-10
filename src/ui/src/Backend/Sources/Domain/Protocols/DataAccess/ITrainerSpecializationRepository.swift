//
//  ITrainerSpecializationRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public protocol ITrainerSpecializationRepository: Sendable {
    func create(_ trainerSpecialization: TrainerSpecialization) async throws
    func update(_ trainerSpecialization: TrainerSpecialization) async throws
    func delete(id: UUID) async throws
    func find(id: UUID) async throws -> TrainerSpecialization?
    func find(trainerId: UUID) async throws -> [TrainerSpecialization]
    func find(specializationId: UUID) async throws -> [TrainerSpecialization]
    func findAll() async throws -> [TrainerSpecialization]
}
