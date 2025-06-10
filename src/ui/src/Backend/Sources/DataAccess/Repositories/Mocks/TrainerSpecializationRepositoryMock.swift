//
//  TrainerSpecializationRepositoryMock.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Foundation
import Domain

public actor TrainerSpecializationRepositoryMock {
    private var trainerSpecializations: [TrainerSpecialization] = []
}

// MARK: - TrainerSpecializationRepositoryMock

extension TrainerSpecializationRepositoryMock: ITrainerSpecializationRepository {
    public func create(_ trainerSpecialization: TrainerSpecialization) async throws {
        trainerSpecializations.append(trainerSpecialization)
    }

    public func update(
        _ trainerSpecialization: TrainerSpecialization
    ) async throws {
        guard
            let index = trainerSpecializations.firstIndex(
                where: {
                    $0.id == trainerSpecialization.id
                }
            )
        else { return }

        trainerSpecializations[index] = trainerSpecialization
    }

    public func delete(id: UUID) async throws {
        if let index = trainerSpecializations.firstIndex(
            where: {
                $0.id == id
            }
        ) {
            trainerSpecializations.remove(at: index)
        }
    }

    public func find(id: UUID) async throws -> TrainerSpecialization? {
        trainerSpecializations.first { $0.id == id }
    }

    public func find(trainerId: UUID) async throws -> [TrainerSpecialization] {
        trainerSpecializations.filter { $0.trainerId == trainerId }
    }

    public func find(specializationId: UUID) async throws -> [TrainerSpecialization] {
        trainerSpecializations.filter {
            $0.specializationId == specializationId
        }
    }

    public func findAll() async throws -> [TrainerSpecialization] {
        trainerSpecializations
    }
}
