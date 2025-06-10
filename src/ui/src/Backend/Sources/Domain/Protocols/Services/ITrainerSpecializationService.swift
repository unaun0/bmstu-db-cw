//
//  ITrainerSpecializationSpecializationService.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public protocol ITrainerSpecializationService: Sendable {
    func create(
        _ data: TrainerSpecializationCreateDTO
    ) async throws -> TrainerSpecialization?
    func update(
        id: UUID,
        with data: TrainerSpecializationUpdateDTO
    ) async throws -> TrainerSpecialization?
    func find(id: UUID) async throws -> TrainerSpecialization?
    func find(trainerId: UUID) async throws -> [TrainerSpecialization]
    func find(specializationId: UUID) async throws -> [TrainerSpecialization]
    func findAll() async throws -> [TrainerSpecialization]
    func delete(id: UUID) async throws
}
