//
//  TrainerSpecialization.swift
//  Backend
//
//  Created by Цховребова Яна on 12.03.2025.
//

import Vapor

// MARK: - TrainerSpecialization

public final class TrainerSpecialization: BaseModel {
    public var id: UUID
    public var trainerId: UUID
    public var specializationId: UUID
    public var years: Int

    public init(
        id: UUID = UUID(),
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

// MARK: - TrainerSpecialization Equatable

extension TrainerSpecialization: Equatable {
    public static func == (lhs: TrainerSpecialization, rhs: TrainerSpecialization)
        -> Bool
    {
        return lhs.id == rhs.id
            && lhs.trainerId == rhs.trainerId
            && lhs.specializationId == rhs.specializationId
            && lhs.years == rhs.years
    }
}

// MARK: - TrainerSpecialization Sendable

extension TrainerSpecialization: @unchecked Sendable {}
