//
//  SpecializationValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Vapor
import Domain

public struct SpecializationValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            let json = try request.content.decode([String: String].self)
            if let name = json["name"] {
                guard
                    SpecializationValidator.validate(name: name)
                else {
                    throw SpecializationError.invalidName
                }
            }
            return try await next.respond(to: request)
        } catch { throw error }
    }
}
