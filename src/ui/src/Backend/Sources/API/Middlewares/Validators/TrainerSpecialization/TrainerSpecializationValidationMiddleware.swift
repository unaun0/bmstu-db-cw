//
//  TrainerSpecializationValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Vapor
import Domain

public struct TrainerSpecializationValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            if let trainerId = try? request.content.get(
                String.self, at: "trainerId"
            ),
                !trainerId.isEmpty,
                UUID(uuidString: trainerId) == nil
            {
                throw TrainerSpecializationError.invalidTrainer
            }

            if let specializationId = try? request.content.get(
                String.self, at: "specializationId"),
                !specializationId.isEmpty,
                UUID(uuidString: specializationId) == nil
            {
                throw TrainerSpecializationError.invalidSpecialization
            }
            if let years = try? request.content.get(
                Int.self, at: "years"
            ), !TrainerSpecializationValidator.validate(
                years: years
            ) {
                throw TrainerSpecializationError.invalidYears
            }

            return try await next.respond(to: request)
        } catch { throw error }
    }
}
