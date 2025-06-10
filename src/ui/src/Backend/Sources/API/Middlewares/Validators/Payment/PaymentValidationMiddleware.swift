//
//  PaymentValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 18.04.2025.
//

import Vapor
import Domain

public struct PaymentValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            let json = try request.content.decode([String: String].self)
            if let transactionId = json["transactionId"] {
                guard
                    PaymentValidator.validate(transactionId: transactionId)
                else { throw PaymentError.invalidTransactionId }
            }
            if let userId = json["userId"] {
                guard
                    UUID(uuidString: userId) != nil
                else { throw PaymentError.invalidUserId }
            }
            if let membershipId = json["membershipId"] {
                guard
                    UUID(uuidString: membershipId) != nil
                else { throw PaymentError.invalidMembershipId }
            }
            if let membershipTId = json["membershipTypeId"] {
                guard
                    UUID(uuidString: membershipTId) != nil
                else { throw PaymentError.invalidMembershipId }
            }
            if let status = json["status"] {
                guard
                    PaymentValidator.validate(status: status)
                else { throw PaymentError.invalidStatus }
            }
            if let gateway = json["gateway"] {
                guard
                    PaymentValidator.validate(gateway: gateway)
                else { throw PaymentError.invalidGateway }
            }
            if let method = json["method"] {
                guard
                    PaymentValidator.validate(method: method)
                else { throw PaymentError.invalidMethod }
            }
            if let dateString = json["date"] {
                guard
                    let date = dateString.toDate(
                        format: ValidationRegex.DateFormat.format
                    ),
                    PaymentValidator.validate(date: date)
                else { throw PaymentError.invalidMethod }
            }
            return try await next.respond(to: request)
        } catch { throw error }
    }
}
