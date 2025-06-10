//
//  PaymentRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 18.04.2025.
//

import Fluent
import Vapor
import Domain

public final class PaymentRepository {
    private let db: Database

    public init(db: Database) {
        self.db = db
    }
}

// MARK: - IPaymentRepository

extension PaymentRepository: IPaymentRepository {
    public func create(_ payment: Payment) async throws {
        try await PaymentDBDTO(from: payment).create(on: db)
    }

    public func update(_ payment: Payment) async throws {
        guard
            let existing = try await PaymentDBDTO.find(
                payment.id,
                on: db
            )
        else {
            throw PaymentError.paymentNotFound
        }

        existing.transactionId = payment.transactionId
        existing.membershipId = payment.membershipId
        existing.status = payment.status.rawValue
        existing.gateway = payment.gateway.rawValue
        existing.method = payment.method.rawValue
        existing.date = payment.date

        try await existing.update(on: db)
    }

    public func find(id: UUID) async throws -> Payment? {
        try await PaymentDBDTO.find(
            id,
            on: db
        )?.toPayment()
    }
    
    public func find(userId: UUID) async throws -> [Payment] {
        try await PaymentDBDTO.query(
            on: db
        ).filter(
            \.$userId  == userId
        ).all().compactMap { $0.toPayment() }
    }

    public func find(membershipId: UUID) async throws -> [Payment] {
        try await PaymentDBDTO.query(
            on: db
        ).filter(
            \.$membershipId  == membershipId
        ).all().compactMap { $0.toPayment() }
    }

    public func find(transactionId: String) async throws -> Payment? {
        try await PaymentDBDTO.query(
            on: db
        ).filter(
            \.$transactionId == transactionId
        ).first()?.toPayment()
    }

    public func findAll() async throws -> [Payment] {
        try await PaymentDBDTO.query(
            on: db
        ).all().compactMap { $0.toPayment() }
    }

    public func delete(id: UUID) async throws {
        guard
            let payment = try await PaymentDBDTO.find(
                id,
                on: db
            )
        else {
            throw PaymentError.paymentNotFound
        }
        try await payment.delete(on: db)
    }
}
