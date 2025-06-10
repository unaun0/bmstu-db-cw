//
//  TrainerSpecializationRepositoryTests.swift
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

final class TrainerSpecializationRepositoryTests: XCTestCase {
    var app: Application!
    var db: Database!
    var userRepository: UserRepository!
    var trainerRepository: TrainerRepository!
    var specializationRepository: SpecializationRepository!
    var repository: TrainerSpecializationRepository!

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
        trainerRepository = TrainerRepository(db: db)
        specializationRepository = SpecializationRepository(db: db)
        repository = TrainerSpecializationRepository(db: db)
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testCreateFindUpdateDeleteTrainerSpecialization() async throws {
        // Создание зависимостей
        let user = User(
            email: "update-test@example.com",
            phoneNumber: "+79991234567",
            password: "InitialPass123!",
            firstName: "Алексей",
            lastName: "Смирнов",
            birthDate: Calendar.current.date(byAdding: .year, value: -20, to: Date())!,
            gender: .male,
            role: .client
        )
        try await userRepository.create(user)

        let trainer = Trainer(
            userId: user.id,
            description: "Test Trainer"
        )
        try await trainerRepository.create(trainer)

        let specialization = Specialization(name: "Test")
        try await specializationRepository.create(specialization)

        let trainerSpec = TrainerSpecialization(
            id: UUID(),
            trainerId: trainer.id,
            specializationId: specialization.id,
            years: 3
        )
        try await repository.create(trainerSpec)

        let foundById = try await repository.find(id: trainerSpec.id)
        XCTAssertEqual(foundById?.years, 3)

        // Обновление
        let updated = TrainerSpecialization(
            id: trainerSpec.id,
            trainerId: trainer.id,
            specializationId: specialization.id,
            years: 5
        )
        try await repository.update(updated)

        let updatedFetched = try await repository.find(id: trainerSpec.id)
        XCTAssertEqual(updatedFetched?.years, 5)

        // Удаление
        try await repository.delete(id: trainerSpec.id)

        let afterDelete = try await repository.find(id: trainerSpec.id)
        XCTAssertNil(afterDelete)

        // Очистка зависимостей
        try await trainerRepository.delete(id: trainer.id)
        try await specializationRepository.delete(id: specialization.id)
        try await userRepository.delete(id: user.id)
    }

    func testUpdateNonexistentTrainerSpecialization() async throws {
        let ghost = TrainerSpecialization(
            id: UUID(),
            trainerId: UUID(),
            specializationId: UUID(),
            years: 1
        )
        do {
            try await repository.update(ghost)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(error as? TrainerSpecializationError, .trainerSpecializationNotFound)
        }
    }

    func testDeleteNonexistentTrainerSpecialization() async throws {
        let id = UUID()
        do {
            try await repository.delete(id: id)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(error as? TrainerSpecializationError, .trainerSpecializationNotFound)
        }
    }
}
