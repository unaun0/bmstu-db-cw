//
//  TrainerReviewRepositor.swift
//  Backend
//
//  Created by Цховребова Яна on 26.05.2025.
//

import Fluent
import Vapor
import Domain

public final class TrainerReviewRepository {
    private let db: Database

    public init(db: Database) {
        self.db = db
    }
}

// MARK: - ITrainerReviewRepository

extension TrainerReviewRepository: ITrainerReviewRepository {
    
    public func create(_ review: TrainerReview) async throws {
        try await TrainerReviewDBDTO(from: review).create(on: db)
    }

    public func update(_ review: TrainerReview) async throws {
        guard
            let existing = try await TrainerReviewDBDTO.find(review.id, on: db)
        else {
            throw TrainerReviewError.reviewNotFound
        }

        existing.userId = review.userId
        existing.trainerId = review.trainerId
        existing.rating = review.rating
        existing.comment = review.comment
        existing.date = review.date

        try await existing.update(on: db)
    }

    public func delete(id: UUID) async throws {
        guard
            let entity = try await TrainerReviewDBDTO.find(id, on: db)
        else {
            throw TrainerReviewError.reviewNotFound
        }

        try await entity.delete(on: db)
    }

    public func find(id: UUID) async throws -> TrainerReview? {
        try await TrainerReviewDBDTO.find(id, on: db)?.toTrainerReview()
    }

    public func find(trainerId: UUID) async throws -> [TrainerReview] {
        try await TrainerReviewDBDTO.query(on: db)
            .filter(\.$trainerId == trainerId)
            .all()
            .compactMap { $0.toTrainerReview() }
    }

    public func find(userId: UUID) async throws -> [TrainerReview] {
        try await TrainerReviewDBDTO.query(on: db)
            .filter(\.$userId == userId)
            .all()
            .compactMap { $0.toTrainerReview() }
    }

    public func findAll() async throws -> [TrainerReview] {
        try await TrainerReviewDBDTO.query(on: db)
            .all()
            .compactMap { $0.toTrainerReview() }
    }
}
