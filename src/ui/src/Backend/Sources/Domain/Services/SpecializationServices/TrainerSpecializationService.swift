//
//  TrainerSpecializationService.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Fluent
import Vapor

public final class TrainerSpecializationService {
    private let repository: ITrainerSpecializationRepository
    
    public init(repository: ITrainerSpecializationRepository) {
        self.repository = repository
    }
}

// MARK: - ITrainerSpecializationService

extension TrainerSpecializationService: ITrainerSpecializationService {
    public func create(
        _ data: TrainerSpecializationCreateDTO
    ) async throws -> TrainerSpecialization? {
        if try await repository.find(
            trainerId: data.trainerId
        ).contains(
            where: {
                $0.specializationId == data.specializationId
            }
        ) { throw TrainerSpecializationError.trainerSpecializationNotUnique }
        let trainerSpecialization = TrainerSpecialization(
            id: UUID(),
            trainerId: data.trainerId,
            specializationId: data.specializationId,
            years: data.years
        )
        try await repository.create(trainerSpecialization)

        return trainerSpecialization
    }

    public func update(
        id: UUID, with data: TrainerSpecializationUpdateDTO
    ) async throws -> TrainerSpecialization? {
        guard
            let trainerSpecialization =
                try await repository.find(id: id)
        else {
            throw TrainerSpecializationError.trainerSpecializationNotFound
        }
        var trainerChanged = false
        var specializationChanged = false
        if let trainer = data.trainerId {
            trainerSpecialization.trainerId = trainer
            trainerChanged = true
        }
        if let specialization = data.specializationId {
            trainerSpecialization.specializationId = specialization
            specializationChanged = true
        }
        if trainerChanged || specializationChanged {
            let tSpecializations =
                try await repository.find(
                    trainerId: trainerSpecialization.trainerId
                )
            if tSpecializations.contains(where: {
                $0.id != trainerSpecialization.id
                    && $0.specializationId == trainerSpecialization.specializationId
            }) {
                throw TrainerSpecializationError.trainerSpecializationNotUnique
            }
        }
        if let years = data.years {
            trainerSpecialization.years = years
        }
        try await repository.update(trainerSpecialization)
        
        return trainerSpecialization
    }

    public func find(id: UUID) async throws -> TrainerSpecialization? {
        try await repository.find(id: id)
    }

    public func find(trainerId: UUID) async throws -> [TrainerSpecialization] {
        try await repository.find(
            trainerId: trainerId
        )
    }

    public func find(specializationId: UUID) async throws -> [TrainerSpecialization] {
        try await repository.find(
            specializationId: specializationId
        )
    }

    public func findAll() async throws -> [TrainerSpecialization] {
        try await repository.findAll()
    }

    public func delete(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
