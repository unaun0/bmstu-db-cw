//
//  SpecializationCreateValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Vapor
import Domain

public struct SpecializationCreateValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            let json = try request.content.decode([String: String].self)
            guard
                let name = json["name"],
                SpecializationValidator.validate(name: name)
            else { throw SpecializationError.invalidName }
            return try await next.respond(to: request)
        } catch { throw error }
    }
}
