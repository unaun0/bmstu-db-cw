//
//  PaymentEntity.swift
//  Backend
//
//  Created by Цховребова Яна on 18.04.2025.
//

import Fluent
import Vapor
import Domain

public final class PaymentMongoDBDTO: Model {
    public static let schema = "Payment"

    @ID(custom: "_id")
    public var id: UUID?

    @Field(key: "transaction_id")
    public var transactionId: String
    
    @Field(key: "user_id")
    public var userId: UUID
    
    @Field(key: "membership_id")
    public var membershipId: UUID?
    
    @Field(key: "membership_type_id")
    public var membershipTypeId: UUID

    @Field(key: "status")
    public var status: String

    @Field(key: "gateway")
    public var gateway: String

    @Field(key: "method")
    public var method: String

    @Field(key: "date")
    public var date: Date
    
    public init() {}
}

// MARK: - Convenience Initializator

extension PaymentMongoDBDTO {
    public convenience init(
        id: UUID? = nil,
        transactionId: String,
        userId: UUID,
        membershipId: UUID? = nil,
        membershipTypeId: UUID,
        status: String,
        gateway: String,
        method: String,
        date: Date
    ) {
        self.init()
        
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

// MARK: - Sendable

extension PaymentMongoDBDTO: @unchecked Sendable {}

// MARK: - Content

extension PaymentMongoDBDTO: Content {}

// MARK: - From / To Model

extension PaymentMongoDBDTO {
    public convenience init(from payment: Payment) {
        self.init()
        self.id = payment.id
        self.transactionId = payment.transactionId
        self.userId = payment.userId
        self.membershipId = payment.membershipId
        self.membershipTypeId = payment.membershipTypeId
        self.status = payment.status.rawValue
        self.gateway = payment.gateway.rawValue
        self.method = payment.method.rawValue
        self.date = payment.date
    }

    public func toPayment() -> Payment? {
        guard
            let id = self.id,
            let status = PaymentStatus(rawValue: self.status),
            let gateway = PaymentGateway(rawValue: self.gateway),
            let method = PaymentMethod(rawValue: self.method)
        else { return nil }

        return Payment(
            id: id,
            transactionId: transactionId,
            userId: userId,
            membershipId: membershipId,
            membershipTypeId: membershipTypeId,
            status: status,
            gateway: gateway,
            method: method,
            date: date
        )
    }
}
