//
//  TrainerReview.swift
//  Backend
//
//  Created by Цховребова Яна on 26.05.2025.
//

import Vapor

// MARK: - TrainerReview

public final class TrainerReview: BaseModel {
    public var id: UUID
    public var userId: UUID
    public var trainerId: UUID
    public var rating: Int
    public var comment: String
    public var date: Date

    public init(
        id: UUID = UUID(),
        userId: UUID,
        trainerId: UUID,
        rating: Int,
        comment: String,
        date: Date
    ) {
        self.id = id
        self.userId = userId
        self.trainerId = trainerId
        self.rating = rating
        self.comment = comment
        self.date = date
    }
}

// MARK: - TrainerReview Equatable

extension TrainerReview: Equatable {
    public static func == (lhs: TrainerReview, rhs: TrainerReview) -> Bool {
        return lhs.id == rhs.id &&
            lhs.userId == rhs.userId &&
            lhs.trainerId == rhs.trainerId &&
            lhs.rating == rhs.rating &&
            lhs.comment == rhs.comment &&
            lhs.date == rhs.date
    }
}

// MARK: - TrainerReview Sendable

extension TrainerReview: @unchecked Sendable {}
