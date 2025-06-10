//
//  TrainerReviewCreateValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 26.05.2025.
//

import Domain
import Vapor

public struct TrainerReviewCreateValidationMiddleware: AsyncMiddleware {
    public init() {}

    public func respond(to request: Request, chainingTo next: AsyncResponder)
        async throws -> Response
    {
        do {

            guard
                let userId = try request.content.get(String?.self, at: "userId"),
                !userId.isEmpty,
                UUID(uuidString: userId) != nil
            else {
                throw TrainerReviewError.invalidUserId
            }

            guard
                let trainerId = try request.content.get(String?.self, at: "trainerId"),
                !trainerId.isEmpty,
                UUID(uuidString: trainerId) != nil
            else {
                throw TrainerReviewError.invalidTrainerId
            }

            guard
                let rating = try request.content.get(Int?.self, at: "rating"),
                TrainerReviewValidator.validate(rating: rating)
            else {
                throw TrainerReviewError.invalidRating
            }

            guard
                let comment = try request.content.get(String?.self, at: "comment"),
                TrainerReviewValidator.validate(comment: comment)
            else {
                throw TrainerReviewError.invalidComment
            }

            return try await next.respond(to: request)
        } catch {
            throw error
        }
    }
}
