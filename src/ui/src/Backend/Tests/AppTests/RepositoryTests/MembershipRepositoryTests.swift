//
//  MembershipRepositoryTests.swift
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

final class MembershipRepositoryTests: XCTestCase {
    var app: Application!
    var db: Database!
    var userRepository: UserRepository!
    var membershipTypeRepository: MembershipTypeRepository!
    var repository: MembershipRepository!

    var userId: UUID!
    var membershipTypeId: UUID!

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
        repository = MembershipRepository(db: db)

        let user = User(
            email: "update-test@example.com",
            phoneNumber: "+79991234567",
            password: "InitialPass123!",
            firstName: "Алексей",
            lastName: "Смирнов",
            birthDate: Calendar.current.date(
                byAdding: .year, value: -20, to: Date())!,
            gender: .male,
            role: .client
        )
        try await userRepository.create(user)
        userId = user.id

        let type = MembershipType(
            name: "Standard",
            price: 1000,
            sessions: 10,
            days: 30
        )
        try await membershipTypeRepository.create(type)
        membershipTypeId = type.id
    }

    override func tearDown() async throws {
        try await userRepository.delete(id: userId)
        try await membershipTypeRepository.delete(id: membershipTypeId)

        try await app.asyncShutdown()
    }

    func testCreateFindAndDeleteMembership() async throws {
        let membership = Membership(
            userId: userId,
            membershipTypeId: membershipTypeId,
            startDate: Date(),
            endDate: Calendar.current.date(
                byAdding: .day,
                value: 30,
                to: Date()
            ),
            availableSessions: 10
        )

        try await repository.create(membership)
        let found = try await repository.find(id: membership.id)
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.userId, userId)

        try await repository.delete(id: membership.id)
        let deleted = try await repository.find(id: membership.id)
        XCTAssertNil(deleted)
    }

    func testUpdateMembership() async throws {
        let membership = Membership(
            userId: userId,
            membershipTypeId: membershipTypeId,
            startDate: Date(),
            endDate: Calendar.current.date(
                byAdding: .day,
                value: 30,
                to: Date()
            ),
            availableSessions: 5
        )

        try await repository.create(membership)

        membership.availableSessions = 20
        try await repository.update(membership)

        let updated = try await repository.find(id: membership.id)
        XCTAssertEqual(updated?.availableSessions, 20)

        try await repository.delete(id: membership.id)
    }

    func testFindAllMemberships() async throws {
        let membership = Membership(
            userId: userId,
            membershipTypeId: membershipTypeId,
            startDate: Date(),
            endDate: Calendar.current.date(
                byAdding: .day, value: 30, to: Date()),
            availableSessions: 3
        )

        try await repository.create(membership)

        let all = try await repository.findAll()
        XCTAssertTrue(all.contains { $0.id == membership.id })

        try await repository.delete(id: membership.id)
    }

    func testUpdateThrowsOnMissingMembership() async throws {
        let ghost = Membership(
            id: UUID(),
            userId: userId,
            membershipTypeId: membershipTypeId,
            startDate: Date(),
            endDate: Calendar.current.date(
                byAdding: .day, value: 10, to: Date()),
            availableSessions: 1
        )

        do {
            try await repository.update(ghost)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(error as? MembershipError, .membershipNotFound)
        }
    }

    func testDeleteThrowsOnMissingMembership() async throws {
        let id = UUID()

        do {
            try await repository.delete(id: id)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(error as? MembershipError, .membershipNotFound)
        }
    }
}
