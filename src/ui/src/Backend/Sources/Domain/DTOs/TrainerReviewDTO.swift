//
//  TrainerReviewDTO.swift
//  Backend
//
//  Created by Цховребова Яна on 26.05.2025.
//

import Vapor
import Foundation

public struct TrainerReviewDTO: Content {
    public let id: UUID
    public let userId: UUID
    public let trainerId: UUID
    public let rating: Int
    public let comment: String
    public let date: Date

    public init(
        id: UUID,
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

// MARK: - Init from Model

extension TrainerReviewDTO {
    public init(from review: TrainerReview) {
        self.id = review.id
        self.userId = review.userId
        self.trainerId = review.trainerId
        self.rating = review.rating
        self.comment = review.comment
        self.date = review.date
    }
}

// MARK: - Equatable

extension TrainerReviewDTO: Equatable {
    public static func == (
        lhs: TrainerReviewDTO,
        rhs: TrainerReviewDTO
    ) -> Bool {
        return lhs.id == rhs.id &&
               lhs.userId == rhs.userId &&
               lhs.trainerId == rhs.trainerId &&
               lhs.rating == rhs.rating &&
               lhs.comment == rhs.comment &&
               lhs.date == rhs.date
    }
}

// MARK: - Create

public struct TrainerReviewCreateDTO: Codable {
    public let userId: UUID
    public let trainerId: UUID
    public let rating: Int
    public let comment: String

    public init(
        userId: UUID,
        trainerId: UUID,
        rating: Int,
        comment: String
    ) {
        self.userId = userId
        self.trainerId = trainerId
        self.rating = rating
        self.comment = comment
    }
}

// MARK: - Update

public struct TrainerReviewUpdateDTO: Codable {
    public let rating: Int?
    public let comment: String?
    public let date: Date?

    public init(
        rating: Int? = nil,
        comment: String? = nil,
        date: Date? = nil
    ) {
        self.rating = rating
        self.comment = comment
        self.date = date
    }
}
