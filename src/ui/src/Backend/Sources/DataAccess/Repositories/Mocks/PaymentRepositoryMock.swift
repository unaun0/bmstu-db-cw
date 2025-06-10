//
//  PaymentRepositoryMock.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Foundation
import Domain

public actor PaymentRepositoryMock {
    private var payments: [Payment] = []
}

// MARK: - IPaymentRepository

extension PaymentRepositoryMock: IPaymentRepository {
    public func create(_ payment: Payment) async throws {
        payments.append(payment)
    }

    public func update(_ payment: Payment) async throws {
        guard
            let index = payments.firstIndex(
                where: {
                    $0.id == payment.id
                }
            )
        else { return }

        payments[index] = payment
    }

    public func delete(id: UUID) async throws {
        guard
            let index = payments.firstIndex(
                where: {
                    $0.id == id
                }
            )
        else {
            throw PaymentError.paymentNotFound
        }

        payments.remove(at: index)
    }

    public func find(id: UUID) async throws -> Payment? {
        payments.first(where: { $0.id == id })
    }

    public func find(membershipId : UUID) async throws -> [Payment] {
        payments.filter { $0.membershipId  == membershipId }
    }
    
    public func find(userId : UUID) async throws -> [Payment] {
        payments.filter { $0.userId  == userId }
    }

    public func find(transactionId: String) async throws -> Payment? {
        payments.first(where: { $0.transactionId == transactionId })
    }

    public func findAll() async throws -> [Payment] {
        return payments
    }
}
