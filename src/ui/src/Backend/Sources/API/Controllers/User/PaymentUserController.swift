//
//  PaymentAdminController.swift
//  Backend
//
//  Created by Цховребова Яна on 26.03.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class PaymentUserController: RouteCollection {
    private let service: IPaymentService
    private let jwtMiddleware: JWTMiddleware

    public init(
        service: IPaymentService,
        jwtMiddleware: JWTMiddleware
    ) {
        self.service = service
        self.jwtMiddleware = jwtMiddleware
    }

    public func boot(routes: RoutesBuilder) throws {
        let routes = routes
            .grouped("user", "payments")
            .grouped(jwtMiddleware)
        routes.get(
            "all",
            use: getAllPayments
        ).openAPI(
            tags: .init(name: "User - Payment"),
            summary: "Получить все платежи пользователя",
            description: "Возвращает список всех платежей пользователя.",
            response: .type([PaymentDTO].self),
            auth: .bearer()
        )
    }
}

// MARK: - Handler Methods

extension PaymentUserController {
    @Sendable
    func getAllPayments(req: Request) async throws -> Response {
        try await service.find(
            userId: req.auth.require(User.self).id
        ).map {
            PaymentDTO(from: $0)
        }.encodeResponse(status: .ok, for: req)
    }
}

extension PaymentUserController: @unchecked Sendable {}
