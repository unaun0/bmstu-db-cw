//
//  TrainerReviewService.swift
//  Backend
//
//  Created by Цховребова Яна on 26.05.2025.
//

import Vapor

public final class TrainerReviewService {
    private let repository: ITrainerReviewRepository

    public init(repository: ITrainerReviewRepository) {
        self.repository = repository
    }
}

// MARK: - ITrainerReviewService

extension TrainerReviewService: ITrainerReviewService {
    public func create(_ data: TrainerReviewCreateDTO) async throws -> TrainerReview {
        let review = TrainerReview(
            id: UUID(),
            userId: data.userId,
            trainerId: data.trainerId,
            rating: data.rating,
            comment: data.comment,
            date: Date()
        )
        try await repository.create(review)
        return review
    }

    public func update(id: UUID, with data: TrainerReviewUpdateDTO) async throws -> TrainerReview {
        guard var review = try await repository.find(id: id) else {
            throw TrainerReviewError.reviewNotFound
        }

        if let rating = data.rating {
            review.rating = rating
        }

        if let comment = data.comment {
            review.comment = comment
        }

        if let date = data.date {
            review.date = date
        }

        try await repository.update(review)
        return review
    }

    public func delete(id: UUID) async throws {
        try await repository.delete(id: id)
    }

    public func find(id: UUID) async throws -> TrainerReview? {
        try await repository.find(id: id)
    }

    public func find(trainerId: UUID) async throws -> [TrainerReview] {
        try await repository.find(trainerId: trainerId)
    }

    public func find(userId: UUID) async throws -> [TrainerReview] {
        try await repository.find(userId: userId)
    }

    public func findAll() async throws -> [TrainerReview] {
        try await repository.findAll()
    }
}
