//
//  PaymentRepositoryTests.swift
//  Backend
//
//  Created by Цховребова Яна on 04.05.2025.
//

import Fluent
import Vapor
import XCTest
@testable import App
@testable import Domain
@testable import DataAccess

final class PaymentRepositoryTests: XCTestCase {
    var app: Application!
    var db: Database!
    var userRepository: UserRepository!
    var membershipRepository: MembershipRepository!
    var membershipTypeRepository: MembershipTypeRepository!
    var repository: PaymentRepository!
    var membershipType = MembershipType(
        id: UUID(),
        name: "Тест",
        price: 100.0,
        sessions: 1,
        days: 1
    )
    var userId: UUID!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        guard let configPath = Environment.get("CONFIG_PATH") else {
            fatalError("CONFIG_PATH not set in environment.")
        }
        let configData = try Data(
            contentsOf: URL(fileURLWithPath: configPath)
        )
        let appConfig = try JSONDecoder().decode(
            AppConfig.self, from: configData
        )
        app.setAppConfig(appConfig)
        let dbConfig = app.appConfig.databaseConfig(for: app.environment)
        app.databases.use(
            DatabaseConfigurationFactory.postgres(
                configuration: .init(
                    hostname: dbConfig.hostname,
                    port: dbConfig.port,
                    username: dbConfig.username,
                    password: dbConfig.password,
                    database: dbConfig.databaseName,
                    tls: .prefer(try .init(configuration: .clientDefault))
                )
            ), as: .psql
        )
        db = app.db(.psql)

        userRepository = UserRepository(db: db)
        membershipTypeRepository = MembershipTypeRepository(db: db)
        membershipRepository = MembershipRepository(db: db)
        repository = PaymentRepository(db: db)

        // Create user
        let user = User(
            email: "payment-test@example.com",
            phoneNumber: "+79998887766",
            password: "TestPass123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: Calendar.current.date(
                byAdding: .year,
                value: -25, to: Date()
            )!,
            gender: .male,
            role: .client
        )
        try await userRepository.create(user)
        try await membershipTypeRepository.create(membershipType)
        userId = user.id
    }

    override func tearDown() async throws {
        // Clean up
        try await membershipTypeRepository.delete(id: membershipType.id)
        try await userRepository.delete(id: userId)
        try await app.asyncShutdown()
    }

    func testCreateAndFindPayment() async throws {
        // Create payment
        let payment = Payment(
            transactionId: "txn123456\(userId ?? UUID())",
            userId: userId!,
            membershipId: nil,
            membershipTypeId: membershipType.id,
            status: PaymentStatus.pending,
            gateway: PaymentGateway.none,
            method: .creditCard,
            date: Date()
        )
        do {
            try await repository.create(payment)
        } catch {
            XCTFail("create failed: \(String(reflecting: error))")
        }

        let found = try await repository.find(id: payment.id)
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.id, payment.id)
        XCTAssertEqual(found?.status, payment.status)
        
        try await repository.delete(id: payment.id)
    }
}
