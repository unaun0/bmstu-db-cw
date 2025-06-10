//
//  TrainerRepository.swift
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

final class TrainerRepositoryTests: XCTestCase {
    var app: Application!
    var db: Database!
    var userRepository: UserRepository!
    var repository: TrainerRepository!

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
        repository = TrainerRepository(db: db)
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testCreateFindUpdateDeleteTrainer() async throws {
        let user = User(
            email: "test-client@example.com",
            phoneNumber: "+1111111111",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: Calendar.current.date(byAdding: .year, value: -18, to: Date())!,
            gender: UserGender.male,
            role: UserRoleName.client
        )
        try await userRepository.create(user)

        let trainer = Trainer(
            id: UUID(),
            userId: user.id,
            description: "Experienced coach"
        )
        try await repository.create(trainer)

        let found = try await repository.find(id: trainer.id)
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.description, "Experienced coach")

        let updatedTrainer = trainer
        updatedTrainer.description = "Updated"
        try await repository.update(updatedTrainer)

        let updated = try await repository.find(id: trainer.id)
        XCTAssertEqual(updated?.description, "Updated")

        try await repository.delete(id: trainer.id)
        let deleted = try await repository.find(id: trainer.id)
        XCTAssertNil(deleted)

        try await userRepository.delete(id: user.id)
    }

    func testCreateWithDuplicateUserIdFails() async throws {
        let user = User(
            email: "test-client@example.com",
            phoneNumber: "+1111111111",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: Calendar.current.date(byAdding: .year, value: -18, to: Date())!,
            gender: UserGender.male,
            role: UserRoleName.client
        )
        try await userRepository.create(user)

        let trainer1 = Trainer(
            id: UUID(),
            userId: user.id,
            description: "First"
        )
        let trainer2 = Trainer(
            id: UUID(),
            userId: user.id,
            description: "Second"
        )

        try await repository.create(trainer1)

        do {
            try await repository.create(trainer2)
            XCTFail("Expected UNIQUE constraint violation on userId")
        } catch {
            // Ожидаемая ошибка
        }

        try await repository.delete(id: trainer1.id)
        try await userRepository.delete(id: user.id)
    }

    func testUpdateNonexistentTrainerThrows() async throws {
        let ghost = Trainer(
            userId: UUID(),
            description: "Ghost"
        )
        do {
            try await repository.update(ghost)
            XCTFail("Expected TrainerError.trainerNotFound")
        } catch {
            XCTAssertEqual(error as? TrainerError, .trainerNotFound)
        }
    }

    func testFindAllTrainers() async throws {
        let user1 = User(
            email: "test-client@example.com",
            phoneNumber: "+1111111111",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: Calendar.current.date(byAdding: .year, value: -18, to: Date())!,
            gender: UserGender.male,
            role: UserRoleName.trainer
        )
        let user2 = User(
            email: "test-client2@example.com",
            phoneNumber: "+11111111110",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: Calendar.current.date(byAdding: .year, value: -18, to: Date())!,
            gender: UserGender.male,
            role: UserRoleName.trainer
        )
        try await userRepository.create(user1)
        try await userRepository.create(user2)

        let trainer1 = Trainer(
            id: UUID(),
            userId: user1.id,
            description: "Desc1"
        )
        let trainer2 = Trainer(
            id: UUID(),
            userId: user2.id,
            description: "Desc2"
        )
        try await repository.create(trainer1)
        try await repository.create(trainer2)

        let all = try await repository.findAll()
        let ids = all.map { $0.id }
        XCTAssertTrue(ids.contains(trainer1.id))
        XCTAssertTrue(ids.contains(trainer2.id))

        try await repository.delete(id: trainer1.id)
        try await repository.delete(id: trainer2.id)
        try await userRepository.delete(id: user1.id)
        try await userRepository.delete(id: user2.id)
    }

    func testCascadeDeleteUserDeletesTrainer() async throws {
        let user = User(
            email: "test-client@example.com",
            phoneNumber: "+1111111111",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: Calendar.current.date(byAdding: .year, value: -18, to: Date())!,
            gender: UserGender.male,
            role: UserRoleName.trainer
        )
        try await userRepository.create(user)

        let trainer = Trainer(
            userId: user.id,
            description: "Cascade"
        )
        try await repository.create(trainer)

        try await userRepository.delete(id: user.id)

        let deletedTrainer = try await repository.find(id: trainer.id)
        XCTAssertNil(deletedTrainer)
    }
}
