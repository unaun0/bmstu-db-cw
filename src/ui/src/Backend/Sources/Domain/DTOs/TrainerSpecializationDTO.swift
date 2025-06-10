//
//  TrainerSpecializationDTO.swift
//  Backend
//
//  Created by Цховребова Яна on 26.03.2025.
//

import Vapor

public struct TrainerSpecializationDTO: Content {
    public let id: UUID
    public let trainerId: UUID
    public let specializationId: UUID
    public let years: Int

    public init(
        id: UUID,
        trainerId: UUID,
        specializationId: UUID,
        years: Int
    ) {
        self.id = id
        self.trainerId = trainerId
        self.specializationId = specializationId
        self.years = years
    }
}

// MARK: - Init from Model

extension TrainerSpecializationDTO {
    public init(from trainerSpecialization: TrainerSpecialization) {
        self.id = trainerSpecialization.id
        self.trainerId = trainerSpecialization.trainerId
        self.specializationId = trainerSpecialization.specializationId
        self.years = trainerSpecialization.years
    }
}

// MARK: - Equatable

extension TrainerSpecializationDTO: Equatable {
    public static func == (
        lhs: TrainerSpecializationDTO,
        rhs: TrainerSpecializationDTO
    ) -> Bool {
        return lhs.id == rhs.id
            && lhs.trainerId == rhs.trainerId
            && lhs.specializationId == rhs.specializationId
            && lhs.years == rhs.years
    }
}

// MARK: - Update

public struct TrainerSpecializationUpdateDTO: Content {
    public let trainerId: UUID?
    public let specializationId: UUID?
    public let years: Int?
}

// MARK: - Create

public struct TrainerSpecializationCreateDTO: Content {
    public let trainerId: UUID
    public let specializationId: UUID
    public let years: Int
}
