//
//  IPaymentRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public protocol IPaymentRepository: Sendable {
    func create(_ payment: Payment) async throws
    func update(_ payment: Payment) async throws
    func delete(id: UUID) async throws
    func find(id: UUID) async throws -> Payment?
    func find(transactionId: String) async throws -> Payment?
    func find(userId: UUID) async throws -> [Payment]
    func find(membershipId: UUID) async throws -> [Payment]
    func findAll() async throws -> [Payment]
}
