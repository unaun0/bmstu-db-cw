//
//  TrainingEntity.swift
//  Backend
//
//  Created by Цховребова Яна on 15.04.2025.
//

import Fluent
import Vapor
import Domain

public final class TrainingMongoDBDTO: Model {
    public static let schema = "Training"

    @ID(custom: "_id")
    public var id: UUID?

    @Field(key: "date")
    public var date: Date

    @Field(key: "specialization_id")
    public var specializationId: UUID

    @Field(key: "room_id")
    public var roomId: UUID

    @Field(key: "trainer_id")
    public var trainerId: UUID

    public init() {}
}

// MARK: - Convenience Initializator

public extension TrainingMongoDBDTO {
    public convenience init(
        id: UUID? = nil,
        date: Date,
        specializationId: UUID,
        roomId: UUID,
        trainerId: UUID
    ) {
        self.init()
        
        self.id = id
        self.date = date
        self.specializationId = specializationId
        self.roomId = roomId
        self.trainerId = trainerId
    }
}

// MARK: - Sendable

extension TrainingMongoDBDTO: @unchecked Sendable {}

// MARK: - Content

extension TrainingMongoDBDTO: Content {}

// MARK: - From / To Model

extension TrainingMongoDBDTO {
    public convenience init(from training: Training) {
        self.init()
        
        self.id = training.id
        self.date = training.date
        self.specializationId = training.specializationId
        self.roomId = training.roomId
        self.trainerId = training.trainerId
    }

    public func toTraining() -> Training? {
        guard let id = self.id else { return nil }

        return Training(
            id: id,
            date: date,
            specializationId: specializationId,
            roomId: roomId,
            trainerId: trainerId
        )
    }
}
