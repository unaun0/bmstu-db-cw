//
//  PaymentAdminController.swift
//  Backend
//
//  Created by Цховребова Яна on 26.03.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class PaymentAdminController: RouteCollection {
    private let service: IPaymentService
    private let jwtMiddleware: JWTMiddleware
    private let adminMiddleware: AdminRoleMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    private let createMiddleware: PaymentCreateValidationMiddleware
    private let updateMiddleware: PaymentValidationMiddleware

    public init(
        service: IPaymentService,
        jwtMiddleware: JWTMiddleware,
        adminMiddleware: AdminRoleMiddleware,
        uuidMiddleware: UUIDValidationMiddleware,
        createMiddleware: PaymentCreateValidationMiddleware,
        updateMiddleware: PaymentValidationMiddleware
    ) {
        self.service = service
        self.jwtMiddleware = jwtMiddleware
        self.adminMiddleware = adminMiddleware
        self.uuidMiddleware = uuidMiddleware
        self.createMiddleware = createMiddleware
        self.updateMiddleware = updateMiddleware
    }

    public func boot(routes: RoutesBuilder) throws {
        let routes = routes
            .grouped("admin", "payments")
            .grouped(jwtMiddleware, adminMiddleware)

        routes.get(
            "all",
            use: getAllPayments
        ).openAPI(
            tags: .init(name: "Admin - Payment"),
            summary: "Получить все платежи для администратора",
            description: "Возвращает список всех платежей. Требует прав администратора.",
            response: .type([PaymentDTO].self),
            auth: .bearer()
        )
        routes.grouped(
            uuidMiddleware
        ).get(
            ":id",
            use: getById
        ).openAPI(
            tags: .init(name: "Admin - Payment"),
            summary: "Получить платеж по ID для администратора",
            description: "Возвращает платеж по его UUID. Требует прав администратора.",
            response: .type(PaymentDTO.self),
            auth: .bearer()
        )
        routes.grouped(
            uuidMiddleware
        ).delete(
            ":id",
            use: deleteById
        ).openAPI(
            tags: .init(name: "Admin - Payment"),
            summary: "Удалить платеж по ID для администратора",
            description: "Удаляет платеж по его UUID. Требует прав администратора.",
            response: .type(HTTPStatus.self),
            auth: .bearer()
        )
        routes.grouped(
            uuidMiddleware
        ).get(
            "user",
            ":user-id",
            use: getByUserId
        ).openAPI(
            tags: .init(name: "Admin - Payment"),
            summary: "Получить платежи по ID пользователя.",
            description: "Возвращает платежи по UUID пользователя. Требует прав администратора.",
            response: .type([PaymentDTO].self),
            auth: .bearer()
        )
        routes.grouped(
            uuidMiddleware
        ).get(
            "membership",
            ":membership-id",
            use: getByMembershipId
        )
        .openAPI(
            tags: .init(name: "Admin - Payment"),
            summary: "Получить платежи по ID абонемента.",
            description: "Возвращает платежи по UUID абонемента. Требует прав администратора.",
            response: .type([PaymentDTO].self),
            auth: .bearer()
        )
        routes.grouped(
            uuidMiddleware
        ).get(
            "transaction",
            ":transaction",
            use: getByTransaction
        )
        .openAPI(
            tags: .init(name: "Admin - Payment"),
            summary: "Получить платеж по транзакции.",
            description: "Возвращает платеж по транзакции. Требует прав администратора.",
            response: .type([PaymentDTO].self),
            auth: .bearer()
        )
        routes.grouped(
            createMiddleware
        ).post(
            use: createPayment
        ).openAPI(
            tags: .init(name: "Admin - Payment"),
            summary: "Создать новый платеж.",
            body: .type(PaymentCreateDTO.self),
            response: .type(PaymentDTO.self),
            auth: .bearer()
        )
        routes.grouped(
            uuidMiddleware, updateMiddleware
        ).put(
            ":id",
            use: updatePayment
        ).openAPI(
            tags: .init(name: "Admin - Payment"),
            summary: "Обновить платеж по ID.",
            body: .type(PaymentUpdateDTO.self),
            response: .type(PaymentDTO.self),
            auth: .bearer()
        )
    }
}

// MARK: - Handler Methods

extension PaymentAdminController {
    @Sendable
    func getAllPayments(req: Request) async throws -> Response {
        try await service.findAll().map {
            PaymentDTO(from: $0)
        }.encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func getById(req: Request) async throws -> Response {
        guard let payment = try await service.find(
            id: try req.parameters.require(
                    "id",
                    as: UUID.self
                )
        ) else { throw PaymentError.paymentNotFound }
        return try await PaymentDTO(
            from: payment
        ).encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func deleteById(req: Request) async throws -> HTTPStatus {       try await service.delete(
            id: try req.parameters.require(
                "id",
                as: UUID.self
            )
        )
        return .noContent
    }

    @Sendable
    func getByUserId(req: Request) async throws -> Response {
        try await service.find(
            userId: try req.parameters.require(
                "user-id",
                as: UUID.self
            )
        ).map {
            PaymentDTO(from: $0)
        }.encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func getByMembershipId(req: Request) async throws -> Response {
        try await service.find(
            membershipId: req.parameters.require(
                "membership-id",
                as: UUID.self
            )
        ).map {
            PaymentDTO(from: $0)
        }.encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func getByTransaction(req: Request) async throws -> Response {
        guard let result = try await service.find(
            transactionId: try req.parameters.require(
                "transaction"
            )
        ) else { throw PaymentError.paymentNotFound }
        return try await PaymentDTO(
            from: result
        ).encodeResponse(for: req)
    }
    @Sendable
    func createPayment(req: Request) async throws -> Response {
        print("ASDASD")
        guard let payment = try await service.create(
            try req.content.decode(
                PaymentCreateDTO.self
            )
        ) else { throw PaymentError.invalidCreation }
        return try await PaymentDTO(
            from: payment
        ).encodeResponse(status: .created, for: req)
    }

    @Sendable
    func updatePayment(req: Request) async throws -> Response {
        guard let payment = try await service.update(
            id: try req.parameters.require(
                "id",
                as: UUID.self
            ),
            with: try req.content.decode(
                PaymentUpdateDTO.self
            )
        ) else {
            throw PaymentError.invalidUpdate
        }
        return try await PaymentDTO(from: payment).encodeResponse(for: req)
    }

}

extension PaymentAdminController: @unchecked Sendable {}
