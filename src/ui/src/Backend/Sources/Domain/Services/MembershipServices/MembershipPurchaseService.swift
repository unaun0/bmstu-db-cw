//
//  MembershipPurchaseService.swift
//  Backend
//
//  Created by Цховребова Яна on 11.05.2025.
//

import Vapor

public final class MembershipPurchaseService: IMembershipPurchaseService {
    private let membershipService: IMembershipService
    private let membershipTypeService: IMembershipTypeService
    private let paymentService: IPaymentService

    public init(
        membershipService: IMembershipService,
        membershipTypeService: IMembershipTypeService,
        paymentService: IPaymentService
    ) {
        self.membershipService = membershipService
        self.membershipTypeService = membershipTypeService
        self.paymentService = paymentService
    }

    public func purchase(_ dto: MembershipPurchaseDTO) async throws -> Payment {
        let memberships = try await membershipService.find(userId: dto.userId)
        let now = Date()

        // 1. Проверка на активный абонемент
        if memberships.contains(where: { membership in
            guard let start = membership.startDate, let end = membership.endDate
            else {
                return false
            }
            return start <= now && end >= now
                && membership.availableSessions > 0
        }) {
            throw Abort(
                .conflict, reason: "У пользователя уже есть активный абонемент."
            )
        }

        // 2. Поиск истекшего абонемента нужного типа
        let expiredSameTypeMembership = memberships.first(where: { membership in
            membership.membershipTypeId == dto.membershipTypeId
                && (membership.endDate ?? now) < now
        })

        // 3. Проверка существования типа абонемента
        guard
            (try await membershipTypeService.find(id: dto.membershipTypeId))
                != nil
        else {
            throw Abort(.notFound, reason: "Тип абонемента не найден.")
        }

        // 4. Создание платежа
        let newPayment = PaymentCreateDTO(
            transactionId: UUID().uuidString,
            membershipId: expiredSameTypeMembership?.id,
            membershipTypeId: dto.membershipTypeId,
            userId: dto.userId,
            status: .pending,
            gateway: dto.gateway,
            method: dto.method,
            date: now.toString(format: ValidationRegex.DateFormat.format)
        )

        guard let payment = try await paymentService.create(newPayment) else {
            throw Abort(
                .internalServerError, reason: "Не удалось создать платеж.")
        }

        return payment
    }

    public func completePurchase(paymentId: UUID) async throws -> Membership {
        // 1. Проверка существования и статуса платежа
        guard let payment = try await paymentService.find(id: paymentId) else {
            throw Abort(.notFound, reason: "Платеж не найден.")
        }
        guard payment.status == .pending else {
            throw Abort(.badRequest, reason: "Платеж уже обработан.")
        }

        // 2. Получение типа абонемента
        guard
            let type = try await membershipTypeService.find(
                id: payment.membershipTypeId)
        else {
            throw Abort(.notFound, reason: "Тип абонемента не найден.")
        }

        let now = Date()
        var updatedMembership: Membership?

        if let existingMembershipId = payment.membershipId {
            // 3. Продление существующего абонемента
            guard
                let existingMembership = try await membershipService.find(
                    id: existingMembershipId)
            else {
                throw Abort(.notFound, reason: "Указанный абонемент не найден.")
            }

            let newStart = now
            let newEnd = Calendar.current.date(
                byAdding: .day, value: type.days, to: newStart)

            let updateDTO = MembershipUpdateDTO(
                userId: nil,
                membershipTypeId: nil,
                startDate: newStart.toString(
                    format: ValidationRegex.DateFormat.format),
                endDate: newEnd?.toString(
                    format: ValidationRegex.DateFormat.format),
                availableSessions: (existingMembership.availableSessions)
                    + type.sessions
            )
            updatedMembership = try await membershipService.update(
                id: existingMembership.id,
                with: updateDTO
            )
        } else {
            let createDTO = MembershipCreateDTO(
                userId: payment.userId,
                membershipTypeId: payment.membershipTypeId
            )
            guard let created = try await membershipService.create(createDTO)
            else {
                throw Abort(
                    .internalServerError,
                    reason: "Не удалось создать абонемент.")
            }
            updatedMembership = created
        }
        guard let finalMembership = updatedMembership else {
            throw Abort(
                .internalServerError,
                reason: "Ошибка обработки абонемента."
            )
        }
        _ = try await paymentService.update(
            id: paymentId,
            with: PaymentUpdateDTO(
                transactionId: nil,
                membershipId: finalMembership.id,
                membershipTypeId: nil,
                userId: nil,
                status: nil,
                gateway: nil,
                method: nil,
                date: nil
            )
        )
        return finalMembership
    }
    public func updatePaymentStatus(
        paymentId: UUID,
        newStatus: PaymentStatus
    ) async throws {
        // 1. Поиск платежа
        guard let payment = try await paymentService.find(id: paymentId) else {
            throw Abort(.notFound, reason: "Платеж не найден.")
        }
        guard payment.status == .pending else {
            throw Abort(.badRequest, reason: "Платеж уже обработан.")
        }

        let updateDTO = PaymentUpdateDTO(
            transactionId: payment.transactionId,
            membershipId: payment.membershipId,
            membershipTypeId: payment.membershipTypeId,
            userId: payment.userId,
            status: newStatus,
            gateway: payment.gateway,
            method: payment.method,
            date: payment.date.toString(
                format: ValidationRegex.DateFormat.format
            )
        )
        guard
            let _ = try await paymentService.update(
                id: paymentId,
                with: updateDTO
            )
        else {
            throw Abort(
                .internalServerError,
                reason: "Не удалось обновить статус платежа.")
        }
    }
}
