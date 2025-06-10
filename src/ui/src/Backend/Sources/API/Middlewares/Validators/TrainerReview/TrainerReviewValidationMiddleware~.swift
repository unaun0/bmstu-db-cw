//
//  TrainerReviewValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 26.05.2025.
//

import Domain
import Vapor

public struct TrainerReviewValidationMiddleware: AsyncMiddleware {
    public init() {}

    public func respond(to request: Request, chainingTo next: AsyncResponder)
        async throws -> Response
    {
        do {
            if let userId = try request.content.get(String?.self, at: "userId"),
                userId.isEmpty || UUID(uuidString: userId) == nil
            {
                throw TrainerReviewError.invalidUserId
            }

            if let trainerId = try request.content.get(String?.self, at: "trainerId"),
                trainerId.isEmpty || UUID(uuidString: trainerId) == nil
            {
                throw TrainerReviewError.invalidTrainerId
            }

            if let rating = try request.content.get(Int?.self, at: "rating") {
                if !TrainerReviewValidator.validate(rating: rating) {
                    throw TrainerReviewError.invalidRating
                }
            }

            if let comment = try request.content.get(String?.self, at: "comment"),
                !TrainerReviewValidator.validate(comment: comment)
            {
                throw TrainerReviewError.invalidComment
            }

            return try await next.respond(to: request)
        } catch {
            throw error
        }
    }
}
