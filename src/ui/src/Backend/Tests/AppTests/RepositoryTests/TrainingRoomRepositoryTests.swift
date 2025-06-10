//
//  TrainingRoomRepositoryTests.swift
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

final class TrainingRoomRepositoryTests: XCTestCase {
    var app: Application!
    var db: Database!
    var repository: TrainingRoomRepository!

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
        repository = TrainingRoomRepository(db: db)
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testCreateFindUpdateDeleteTrainingRoom() async throws {
        let room = TrainingRoom(
            id: UUID(),
            name: "Room A",
            capacity: 20
        )

        // Create
        try await repository.create(room)

        // Find by id
        let foundById = try await repository.find(id: room.id)
        XCTAssertNotNil(foundById)
        XCTAssertEqual(foundById?.name, "Room A")

        // Find by name
        let foundByName = try await repository.find(name: "Room A")
        XCTAssertNotNil(foundByName)
        XCTAssertEqual(foundByName?.capacity, 20)

        // Update
        room.name = "Room A Updated"
        room.capacity = 30
        try await repository.update(room)

        let updated = try await repository.find(id: room.id)
        XCTAssertEqual(updated?.name, "Room A Updated")
        XCTAssertEqual(updated?.capacity, 30)

        // Delete
        try await repository.delete(id: room.id)
        let afterDelete = try await repository.find(id: room.id)
        XCTAssertNil(afterDelete)
    }

    func testCreateDuplicateNameFails() async throws {
        let room1 = TrainingRoom(id: UUID(), name: "Unique Room", capacity: 10)
        let room2 = TrainingRoom(id: UUID(), name: "Unique Room", capacity: 15)

        try await repository.create(room1)

        do {
            try await repository.create(room2)
            XCTFail("Expected unique constraint violation")
        } catch {
            print("Caught expected duplicate name error: \(error)")
        }

        try await repository.delete(id: room1.id)
    }

    func testUpdateNonexistentThrows() async throws {
        let fakeRoom = TrainingRoom(id: UUID(), name: "Ghost Room", capacity: 10)

        do {
            try await repository.update(fakeRoom)
            XCTFail("Expected error for updating nonexistent room")
        } catch TrainingRoomError.trainingRoomNotFound {
            // Expected
        }
    }

    func testDeleteNonexistentThrows() async throws {
        do {
            try await repository.delete(id: UUID())
            XCTFail("Expected error for deleting nonexistent room")
        } catch TrainingRoomError.trainingRoomNotFound {
            // Expected
        }
    }

    func testFindByCapacity() async throws {
        let room1 = TrainingRoom(id: UUID(), name: "Small Room", capacity: 5)
        let room2 = TrainingRoom(id: UUID(), name: "Medium Room", capacity: 10)

        try await repository.create(room1)
        try await repository.create(room2)

        let result = try await repository.find(capacity: 10)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Medium Room")

        try await repository.delete(id: room1.id)
        try await repository.delete(id: room2.id)
    }

    func testFindAll() async throws {
        let room1 = TrainingRoom(id: UUID(), name: "Alpha", capacity: 10)
        let room2 = TrainingRoom(id: UUID(), name: "Beta", capacity: 15)

        try await repository.create(room1)
        try await repository.create(room2)

        let allRooms = try await repository.findAll()
        let names = allRooms.map { $0.name }

        XCTAssertTrue(names.contains("Alpha"))
        XCTAssertTrue(names.contains("Beta"))

        try await repository.delete(id: room1.id)
        try await repository.delete(id: room2.id)
    }
}
