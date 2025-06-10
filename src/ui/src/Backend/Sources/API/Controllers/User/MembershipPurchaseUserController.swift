//
//  MembershipPurchaseUserController.swift
//  Backend
//
//  Created by Цховребова Яна on 11.05.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class MembershipPurchaseUserController: RouteCollection {
    private let service: IMembershipPurchaseService
    private let jwtMiddleware: JWTMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    private let validationMiddleware: MembershipPurchaseValidationMiddleware

    public init(
        service: IMembershipPurchaseService,
        jwtMiddleware: JWTMiddleware,
        uuidMiddleware: UUIDValidationMiddleware,
        validationMiddleware: MembershipPurchaseValidationMiddleware
    ) {
        self.service = service
        self.jwtMiddleware = jwtMiddleware
        self.uuidMiddleware = uuidMiddleware
        self.validationMiddleware = validationMiddleware
    }

    public func boot(routes: RoutesBuilder) throws {
        let purchaseRoutes = routes.grouped(
            "user", "memberships", "purchase"
        ).grouped(jwtMiddleware)

        purchaseRoutes.grouped(validationMiddleware).post(
            use: purchaseMembership
        ).openAPI(
            tags: .init(name: "User - Membership Purchase"),
            summary: "Создание платежа для покупки абонемента",
            description:
                "Создаёт новый платеж для покупки абонемента, если нет активного.",
            body: .type(MembershipPurchaseDTO.self),
            response: .type(Payment.self),
            auth: .bearer()
        )
        purchaseRoutes.grouped(uuidMiddleware).post(
            "complete", ":id",
            use: completePurchase
        ).openAPI(
            tags: .init(name: "User - Membership Purchase"),
            summary: "Завершение покупки абонемента",
            description:
                "Завершает покупку абонемента по ID платежа. Если указан старый абонемент, продлевает его.",
            response: .type(Membership.self),
            auth: .bearer()
        )
        purchaseRoutes.put(
            "status",
            ":payment-id",
            use: updatePaymentStatus
        ).openAPI(
            tags: .init(name: "User - Membership Purchase"),
            summary: "Обновить статус платежа.",
            body: .type(PaymentStatusDTO.self),
            response: .type(HTTPStatus.self),
            auth: .bearer()
        )
    }
}

// MARK: - Routes Realization

extension MembershipPurchaseUserController {
    @Sendable
    func purchaseMembership(req: Request) async throws -> Response {
        let dto = try req.content.decode(MembershipPurchaseDTO.self)
        let currentUser = try req.auth.require(User.self)
        guard dto.userId == currentUser.id else {
            throw Abort(
                .forbidden,
                reason: "Невозможно выполнить покупку для другого пользователя."
            )
        }
        let payment = try await service.purchase(dto)
        return try await PaymentDTO(
            from: payment
        ).encodeResponse(for: req)
    }

    @Sendable
    func completePurchase(req: Request) async throws -> Response {
        let id = try req.parameters.require("id", as: UUID.self)
        let membership = try await service.completePurchase(paymentId: id)
        return try await MembershipDTO(
            from: membership
        ).encodeResponse(for: req)
    }

    @Sendable
    func updatePaymentStatus(req: Request) async throws -> HTTPStatus {
        let paymentId = try req.parameters.require("payment-id", as: UUID.self)
        let newStatusString = try req.content.decode([String: String].self)
        guard
            let newStatus = PaymentStatus(
                rawValue: newStatusString["status"] ?? "")
        else {
            throw Abort(.badRequest, reason: "Некорректный статус.")
        }
        try await service.updatePaymentStatus(
            paymentId: paymentId,
            newStatus: newStatus
        )
        return .ok
    }
}

extension MembershipPurchaseUserController: @unchecked Sendable {}


