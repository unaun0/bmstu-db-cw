//
//  PaymentServiceTests.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Fluent
import Vapor
import XCTest

@testable import App
@testable import Domain
@testable import DataAccess

final class PaymentServiceTests: XCTestCase {

    var paymentService: IPaymentService!
    var paymentRepositoryMock: IPaymentRepository!

    override func setUp() {
        super.setUp()
        paymentRepositoryMock = PaymentRepositoryMock()
        paymentService = PaymentService(
            repository: paymentRepositoryMock
        )
    }

    override func tearDown() {
        paymentRepositoryMock = nil
        paymentService = nil
        super.tearDown()
    }

    // MARK: - Тесты на создание

    func testCreatePayment_Success() async throws {
        let paymentDTO = PaymentCreateDTO(
            transactionId: "TXN123456",
            membershipId: UUID(),
            membershipTypeId: UUID(),
            userId: UUID(),
            status: PaymentStatus.pending,
            gateway: PaymentGateway.sber,
            method: PaymentMethod.creditCard,
            date: Date().toString(format: ValidationRegex.DateFormat.format)
        )
        let pm = try await paymentService.create(paymentDTO)
        let fpm = try await paymentRepositoryMock.find(
            id: pm!.id
        )
        XCTAssertNotNil(fpm)
    }

    func testCreatePayment_TransactionIDNotUnique() async throws {
        let paymentDTO = PaymentCreateDTO(
            transactionId: "TXN123456",
            membershipId: UUID(),
            membershipTypeId: UUID(),
            userId: UUID(),
            status: PaymentStatus.pending,
            gateway: PaymentGateway.sber,
            method: PaymentMethod.creditCard,
            date: Date().toString(format: ValidationRegex.DateFormat.format)
        )
        _ = try await paymentService.create(paymentDTO)
        do {
            _ = try await paymentService.create(paymentDTO)
            XCTFail()
        } catch PaymentError.transactionIDNotUnique {
        } catch {
            XCTFail()
        }
    }
}
