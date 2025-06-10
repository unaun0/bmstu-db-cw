//
//  PaymentCreateValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 18.04.2025.
//

import Vapor
import Domain

public struct PaymentCreateValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            let json = try request.content.decode([String: String].self)
            guard
                let transactionId = json["transactionId"],
                PaymentValidator.validate(transactionId: transactionId)
            else { throw PaymentError.invalidTransactionId }
            guard
                let mtId = json["membershipTypeId"],
                UUID(uuidString: mtId) != nil
            else { throw PaymentError.invalidMembershipId }
            if let membershipId = json["membershipId"] {
                guard UUID(uuidString: membershipId) != nil
                else { throw PaymentError.invalidMembershipId }
            }
            guard
                let userId = json["userId"],
                UUID(uuidString: userId) != nil
            else { throw PaymentError.invalidUserId }
            guard
                let status = json["status"],
                PaymentValidator.validate(status: status)
            else { throw PaymentError.invalidStatus}
            guard
                let gateway = json["gateway"],
                PaymentValidator.validate(gateway: gateway)
            else { throw PaymentError.invalidGateway }
            guard
                let method = json["method"],
                PaymentValidator.validate(method: method)
            else { throw PaymentError.invalidMethod }
            guard
                let dateString = json["date"],
                let date = dateString.toDate(format: ValidationRegex.DateFormat.format
                ),
                PaymentValidator.validate(date: date)
            else { throw PaymentError.invalidDate }
            return try await next.respond(to: request)
        } catch { throw error }
    }
}
