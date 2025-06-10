//
//  MembershipTypeRepositoryTests.swift
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

final class MembershipTypeRepositoryTests: XCTestCase {
    var app: Application!
    var db: Database!
    var repository: MembershipTypeRepository!

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
        repository = MembershipTypeRepository(db: db)
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testCreateFindUpdateDeleteMembershipType() async throws {
        let membershipType = MembershipType(
            id: UUID(),
            name: "Standard",
            price: 100.0,
            sessions: 10,
            days: 30
        )

        // Create
        try await repository.create(membershipType)

        // Find by id
        let fetchedById = try await repository.find(id: membershipType.id)
        XCTAssertNotNil(fetchedById)
        XCTAssertEqual(fetchedById?.name, "Standard")

        // Find by name
        let fetchedByName = try await repository.find(name: "Standard")
        XCTAssertNotNil(fetchedByName)
        XCTAssertEqual(fetchedByName?.id, membershipType.id)

        // Update
        membershipType.name = "Updated Standard"
        membershipType.price = 150.0
        membershipType.sessions = 15
        membershipType.days = 60
        try await repository.update(membershipType)

        let updated = try await repository.find(id: membershipType.id)
        XCTAssertEqual(updated?.name, "Updated Standard")
        XCTAssertEqual(updated?.price, 150.0)

        // Delete
        try await repository.delete(id: membershipType.id)
        let afterDelete = try await repository.find(id: membershipType.id)
        XCTAssertNil(afterDelete)
    }

    func testCreateDuplicateNameFails() async throws {
        let name = "UniqueName"
        let first = MembershipType(
            id: UUID(),
            name: name,
            price: 200.0,
            sessions: 10,
            days: 30
        )
        let second = MembershipType(
            id: UUID(),
            name: name,
            price: 250.0,
            sessions: 12,
            days: 40
        )

        try await repository.create(first)

        do {
            try await repository.create(second)
            XCTFail("Expected unique constraint violation on name")
        } catch {
            // Expecting a Postgres unique constraint error
            print("Caught expected error: \(error)")
        }
        try await repository.delete(id: first.id)
    }

    func testUpdateNonexistentThrows() async throws {
        let fake = MembershipType(
            id: UUID(),
            name: "Ghost",
            price: 99.0,
            sessions: 5,
            days: 10
        )

        do {
            try await repository.update(fake)
            XCTFail("Expected error for non-existing update")
        } catch MembershipTypeError.membershipTypeNotFound {
            // Expected
        }
    }

    func testDeleteNonexistentThrows() async throws {
        do {
            try await repository.delete(id: UUID())
            XCTFail("Expected error for non-existing delete")
        } catch MembershipTypeError.membershipTypeNotFound {
            // Expected
        }
    }
}
