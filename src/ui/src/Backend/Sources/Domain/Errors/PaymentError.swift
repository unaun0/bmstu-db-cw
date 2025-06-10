//
//  PaymentError.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public enum PaymentError: AbortError {
    case paymentNotFound
    case orderNotFound
    case invalidTransactionId
    case invalidStatus
    case invalidMethod
    case invalidGateway
    case invalidDate
    case invalidMembershipId
    case transactionIDNotUnique
    case orderAlreadyPaid
    case invalidUpdate
    case invalidCreation
    case invalidUserId

    public var status: HTTPStatus {
        switch self {
        case .invalidTransactionId:
            return .badRequest
        case .invalidStatus:
            return .badRequest
        case .invalidMethod:
            return .badRequest
        case .invalidGateway:
            return .badRequest
        case .invalidDate:
            return .badRequest
        case .invalidMembershipId:
            return .badRequest
        case .transactionIDNotUnique:
            return .conflict
        case .orderAlreadyPaid:
            return .conflict
        case .orderNotFound:
            return .notFound
        case .paymentNotFound:
            return .notFound
        case .invalidUpdate,
                .invalidCreation,
                .invalidUserId:
            return .badRequest
        }
    }

    public var reason: String {
        switch self {
        case .invalidGateway:
            return "Неверный платежный шлюз."
        case .invalidDate:
            return "Неверная дата."
        case .paymentNotFound:
            return "Платеж не найден."
        case .orderNotFound:
            return "Заказ для этого платежа не найден."
        case .invalidTransactionId:
            return "Неверный идентификатор транзакции."
        case .invalidStatus:
            return "Неверный статус платежа."
        case .invalidUserId:
            return "Неверный идентификатор пользователя."
        case .invalidMethod:
            return "Неверный метод платежа."
        case .transactionIDNotUnique:
            return "Идентификатор транзакции должен быть уникальным."
        case .orderAlreadyPaid:
            return "Заказ уже оплачен."
        case .invalidMembershipId:
            return "Неверный идентификатор абонемента."
        case .invalidUpdate, .invalidCreation:
            return "Ошибка при создании / обновлении платежа."
        }
    }
}
