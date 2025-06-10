//
//  PaymentDTO.swift
//  Backend
//
//  Created by Цховребова Яна on 27.03.2025.
//

import Vapor

public struct PaymentDTO: Content {
    public let id: UUID
    public let transactionId: String
    public let membershipId: UUID?
    public let membershipTypeId: UUID
    public let userId: UUID
    public let status: PaymentStatus
    public let gateway: PaymentGateway
    public let method: PaymentMethod
    public let date: String

    public init(
        id: UUID,
        transactionId: String,
        membershipId: UUID? = nil,
        membershipTypeId: UUID,
        userId: UUID,
        status: PaymentStatus,
        gateway: PaymentGateway,
        method: PaymentMethod,
        date: String
    ) {
        self.id = id
        self.transactionId = transactionId
        self.membershipId = membershipId
        self.membershipTypeId = membershipTypeId
        self.userId = userId
        self.status = status
        self.gateway = gateway
        self.method = method
        self.date = date
    }
}

// MARK: - Init from Model

extension PaymentDTO {
    public init(from payment: Payment) {
        self.id = payment.id
        self.userId = payment.userId
        self.transactionId = payment.transactionId
        self.membershipTypeId = payment.membershipTypeId
        self.membershipId = payment.membershipId
        self.status = payment.status
        self.gateway = payment.gateway
        self.method = payment.method
        self.date = payment.date.toString(
            format: ValidationRegex.DateFormat.format
        )
    }
}

// MARK: - Equatable

extension PaymentDTO: Equatable {
    public static func == (
        lhs: PaymentDTO,
        rhs: PaymentDTO
    ) -> Bool {
        return lhs.id == rhs.id
            && lhs.userId == rhs.userId
            && lhs.transactionId == rhs.transactionId
            && lhs.membershipId == rhs.membershipId
            && lhs.membershipTypeId == rhs.membershipTypeId
            && lhs.status == rhs.status
            && lhs.gateway == rhs.gateway
            && lhs.method == rhs.method
            && lhs.date == rhs.date
    }
}

// MARK: - Update

public struct PaymentUpdateDTO: Content {
    public let transactionId: String?
    public let membershipId: UUID?
    public let membershipTypeId: UUID?
    public let userId: UUID?
    public let status: PaymentStatus?
    public let gateway: PaymentGateway?
    public let method: PaymentMethod?
    public let date: String?
}

// MARK: - Create

public struct PaymentCreateDTO: Content {
    public let transactionId: String
    public let membershipId: UUID?
    public let membershipTypeId: UUID
    public let userId: UUID
    public let status: PaymentStatus
    public let gateway: PaymentGateway
    public let method: PaymentMethod
    public let date: String
}

public struct PaymentStatusDTO: Content {
    public let status: String
}
