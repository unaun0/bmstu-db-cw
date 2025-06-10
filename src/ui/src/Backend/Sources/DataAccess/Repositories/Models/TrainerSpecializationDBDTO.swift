//
//  TrainerSpecializationEntity.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Fluent
import Vapor
import Domain

public final class TrainerSpecializationDBDTO: Model {
    public static let schema = "TrainerSpecialization"

    @ID(custom: "id")
    public var id: UUID?

    @Field(key: "trainer_id")
    public var trainerId: UUID

    @Field(key: "specialization_id")
    public var specializationId: UUID

    @Field(key: "years")
    public var years: Int

    public init() {}
}

// MARK: - Convenience Initializator

extension TrainerSpecializationDBDTO {
    public convenience init(
        id: UUID? = nil,
        trainerId: UUID,
        specializationId: UUID,
        years: Int
    ) {
        self.init()
        
        self.id = id
        self.trainerId = trainerId
        self.specializationId = specializationId
        self.years = years
    }
}

// MARK: - Sendable

extension TrainerSpecializationDBDTO: @unchecked Sendable {}

// MARK: - Content

extension TrainerSpecializationDBDTO: Content {}

// MARK: - From / To Model

extension TrainerSpecializationDBDTO {
    public convenience init(
        from trainerSpec: TrainerSpecialization
    ) {
        self.init()
        
        self.id = trainerSpec.id
        self.trainerId = trainerSpec.trainerId
        self.specializationId = trainerSpec.specializationId
        self.years = trainerSpec.years
    }

    public func toTrainerSpecialization() -> TrainerSpecialization? {
        guard let id = self.id else { return nil }
        
        return TrainerSpecialization(
            id: id,
            trainerId: trainerId,
            specializationId: specializationId,
            years: years
        )
    }
}
