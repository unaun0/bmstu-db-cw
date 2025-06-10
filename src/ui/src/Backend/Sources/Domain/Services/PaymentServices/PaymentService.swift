//
//  PaymentService.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Fluent
import Vapor

public final class PaymentService: IPaymentService {
    private let repository: IPaymentRepository

    public init(repository: IPaymentRepository) {
        self.repository = repository
    }

    public func create(_ data: PaymentCreateDTO) async throws -> Payment? {
        if try await repository.find(
            transactionId: data.transactionId
        ) != nil {
            throw PaymentError.transactionIDNotUnique
        }
        let payment = Payment(
            id: UUID(),
            transactionId: data.transactionId,
            userId: data.userId,
            membershipId: data.membershipId,
            membershipTypeId: data.membershipTypeId,
            status: data.status,
            gateway: data.gateway,
            method: data.method,
            date: data.date.toDate(
                format: ValidationRegex.DateFormat.format
            ) ?? Date()
        )
        try await repository.create(payment)
        return payment
    }

    public func update(id: UUID, with data: PaymentUpdateDTO) async throws -> Payment? {
        guard
            let payment = try await repository.find(id: id)
        else {
            throw PaymentError.paymentNotFound
        }
        if let transaction = data.transactionId {
            if try await repository.find(
                transactionId: transaction
            ) != nil {
                throw PaymentError.transactionIDNotUnique
            }
            payment.transactionId = transaction
        }
        if let userId = data.userId {
            payment.userId = userId
        }
        if let membershipId = data.membershipId {
            payment.membershipId = membershipId
        }
        if let status = data.status {
            payment.status = status
        }
        if let gateway = data.gateway {
            payment.gateway = gateway
        }
        if let method = data.method {
            payment.method = method
        }
        if let date = data.date {
            payment.date = date.toDate(
                format: ValidationRegex.DateFormat.format
            ) ?? Date()
        }
        if let membershipTypeId = data.membershipTypeId {
            payment.membershipTypeId = membershipTypeId
        }
        try await repository.update(payment)
        
        return payment
    }

    public func find(id: UUID) async throws -> Payment? {
        try await repository.find(id: id)
    }

    public func find(transactionId: String) async throws -> Payment? {
        try await repository.find(transactionId: transactionId)
    }

    public func find(userId: UUID) async throws -> [Payment] {
        try await repository.find(userId: userId)
    }
    
    public func find(membershipId: UUID) async throws -> [Payment] {
        try await repository.find(membershipId: membershipId
        )
    }

    public func findAll() async throws -> [Payment] {
        return try await repository.findAll()
    }

    public func delete(id: UUID) async throws {
        guard (try await repository.find(id: id)) != nil else {
            throw PaymentError.paymentNotFound
        }
        try await repository.delete(id: id)
    }
}
