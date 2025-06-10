//
//  IPaymentService.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public protocol IPaymentService: Sendable {
    func create(_ data: PaymentCreateDTO) async throws -> Payment?
    func update(id: UUID, with data: PaymentUpdateDTO) async throws -> Payment?
    func find(id: UUID) async throws -> Payment?
    func find(transactionId: String) async throws -> Payment?
    func find(userId: UUID) async throws -> [Payment]
    func find(membershipId: UUID) async throws -> [Payment]
    func findAll() async throws -> [Payment]
    func delete(id: UUID) async throws
}
