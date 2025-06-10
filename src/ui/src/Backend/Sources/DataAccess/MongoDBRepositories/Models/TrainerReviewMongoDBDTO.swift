//
//  TrainerReviewMongoDBDTO.swift
//  Backend
//
//  Created by Цховребова Яна on 26.05.2025.
//

import Fluent
import Vapor
import Domain

public final class TrainerReviewMongoDBDTO: Model {
    public static let schema = "TrainerReview"

    @ID(custom: "_id")
    public var id: UUID?

    @Field(key: "user_id")
    public var userId: UUID
    
    @Field(key: "trainer_id")
    public var trainerId: UUID
    
    @Field(key: "rating")
    public var rating: Int

    @Field(key: "comment")
    public var comment: String

    @Field(key: "date")
    public var date: Date
    
    public init() {}
}

// MARK: - Convenience Initializer

extension TrainerReviewMongoDBDTO {
    public convenience init(
        id: UUID? = nil,
        userId: UUID,
        trainerId: UUID,
        rating: Int,
        comment: String,
        date: Date
    ) {
        self.init()

        self.id = id
        self.userId = userId
        self.trainerId = trainerId
        self.rating = rating
        self.comment = comment
        self.date = date
    }
}

// MARK: - Sendable

extension TrainerReviewMongoDBDTO: @unchecked Sendable {}

// MARK: - Content

extension TrainerReviewMongoDBDTO: Content {}

// MARK: - From / To Model

extension TrainerReviewMongoDBDTO {
    public convenience init(from review: TrainerReview) {
        self.init()

        self.id = review.id
        self.userId = review.userId
        self.trainerId = review.trainerId
        self.rating = review.rating
        self.comment = review.comment
        self.date = review.date
    }

    public func toTrainerReview() -> TrainerReview? {
        guard let id = self.id else { return nil }

        return TrainerReview(
            id: id,
            userId: userId,
            trainerId: trainerId,
            rating: rating,
            comment: comment,
            date: date
        )
    }
}
