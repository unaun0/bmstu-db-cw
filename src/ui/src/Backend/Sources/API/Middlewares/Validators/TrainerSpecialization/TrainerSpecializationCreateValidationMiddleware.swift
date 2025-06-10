//
//  TrainerSpecializationCreateValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Vapor
import Domain

public struct TrainerSpecializationCreateValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            let trainerIdString = try request.content.get(
                String.self,
                at: "trainerId"
            )
            guard UUID(uuidString: trainerIdString) != nil else {
                throw TrainerSpecializationError.invalidTrainer
            }
            let specializationIdString = try request.content.get(
                String.self,
                at: "specializationId"
            )
            guard
                UUID(uuidString: specializationIdString) != nil
            else {
                throw TrainerSpecializationError.invalidSpecialization
            }
            let years = try request.content.get(Int.self, at: "years")
            guard TrainerSpecializationValidator.validate(years: years) else {
                throw TrainerSpecializationError.invalidYears
            }
            return try await next.respond(to: request)
        } catch {
            throw error
        }
    }
}
