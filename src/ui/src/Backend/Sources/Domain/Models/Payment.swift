//
//  Payment.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

// MARK: - PaymentStatus

public enum PaymentStatus: String {
    case pending = "ожидает"
    case paid = "оплачен"
    case canceled = "отменен"
}

// MARK: - PaymentStatus CaseIterable

extension PaymentStatus: CaseIterable {}

// MARK: - PaymentStatus Content

extension PaymentStatus: Content {}

// MARK: - PaymentMethod

public enum PaymentMethod: String {
    case cash = "наличные"
    case creditCard = "банковская карта"
    case bankTransfer = "банковский перевод"
}

// MARK: - PaymentMethod CaseIterable

extension PaymentMethod: CaseIterable {}

// MARK: - PaymentStatus Content

extension PaymentMethod: Content {}

// MARK: - PaymentGateway

public enum PaymentGateway: String {
    case none = "None"
    case paypal = "PayPal"
    case yandex = "Yandex"
    case sber = "Sber"
}

// MARK: - PaymentGateway CaseIterable

extension PaymentGateway: CaseIterable {}

// MARK: - PaymentGateway Content

extension PaymentGateway: Content {}

// MARK: - Payment

public final class Payment: BaseModel {
    public var id: UUID
    public var transactionId: String
    public var userId: UUID
    public var membershipId: UUID?
    public var membershipTypeId: UUID
    public var status: PaymentStatus
    public var gateway: PaymentGateway
    public var method: PaymentMethod
    public var date: Date

    public init(
        id: UUID = UUID(),
        transactionId: String,
        userId: UUID,
        membershipId: UUID? = nil,
        membershipTypeId: UUID,
        status: PaymentStatus,
        gateway: PaymentGateway,
        method: PaymentMethod,
        date: Date
    ) {
        self.id = id
        self.transactionId = transactionId
        self.userId = userId
        self.membershipId = membershipId
        self.membershipTypeId = membershipTypeId
        self.status = status
        self.gateway = gateway
        self.method = method
        self.date = date
    }
}

// MARK: - Payment Equatable

extension Payment: Equatable {
    public static func == (lhs: Payment, rhs: Payment) -> Bool {
        return lhs.id == rhs.id
            && lhs.transactionId == rhs.transactionId
            && lhs.userId == rhs.userId
            && lhs.membershipId == rhs.membershipId
            && lhs.membershipTypeId == rhs.membershipTypeId
            && lhs.status == rhs.status
            && lhs.gateway == rhs.gateway
            && lhs.method == rhs.method
            && Calendar.current.isDate(
                lhs.date,
                inSameDayAs: rhs.date
            )
    }
}

// MARK: - Payment Sendable

extension Payment: @unchecked Sendable {}
