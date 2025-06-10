//
//  MembershipPurchaseValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 11.05.2025.
//

import Vapor
import Domain

public struct MembershipPurchaseValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            // Декодирование данных запроса
            let json = try request.content.decode([String: String].self)
            
            // Проверка userId
            guard let userIdString = json["userId"], UUID(uuidString: userIdString) != nil
            else {
                throw MembershipError.invalidUserId
            }
            
            // Проверка membershipTypeId
            guard let membershipTypeIdString = json["membershipTypeId"],
                    UUID(uuidString: membershipTypeIdString) != nil
            else {
                throw MembershipError.invalidMembershipTypeId
            }
            
            // Проверка gateway
            guard let gatewayString = json["gateway"], let _ = PaymentGateway(rawValue: gatewayString) else {
                throw PaymentError.invalidGateway
            }

            // Проверка method
            guard let methodString = json["method"], let _ = PaymentMethod(rawValue: methodString) else {
                throw PaymentError.invalidMethod
            }
            
            return try await next.respond(to: request)
        } catch {
            throw error
        }
    }
}
