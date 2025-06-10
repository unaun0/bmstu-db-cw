//
//  SpecializationRepositoryTests.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Fluent
import Vapor
import XCTest
@testable import App
@testable import Domain
@testable import DataAccess

final class SpecializationRepositoryTests: XCTestCase {
    var app: Application!
    var db: Database!
    var specRepository: SpecializationRepository!

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
        specRepository = SpecializationRepository(db: db)
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testCreateFindUpdateDeleteSpecialization() async throws {
        // Создание
        let specialization = Specialization(
            id: UUID(),
            name: "Йога"
        )
        try await specRepository.create(specialization)

        // Поиск по ID
        let foundById = try await specRepository.find(id: specialization.id)
        XCTAssertNotNil(foundById)
        XCTAssertEqual(foundById?.name, specialization.name)

        // Поиск по имени
        let foundByName = try await specRepository.find(name: specialization.name)
        XCTAssertNotNil(foundByName)
        XCTAssertEqual(foundByName?.id, specialization.id)

        // Обновление
        specialization.name = "Пилатес"
        try await specRepository.update(specialization)
        let updated = try await specRepository.find(id: specialization.id)
        XCTAssertEqual(updated?.name, "Пилатес")

        // Удаление
        try await specRepository.delete(id: specialization.id)
        let afterDelete = try await specRepository.find(id: specialization.id)
        XCTAssertNil(afterDelete)
    }

    func testFindAllSpecializations() async throws {
        let specialization1 = Specialization(id: UUID(), name: "Кардио")
        let specialization2 = Specialization(id: UUID(), name: "Силовые")

        try await specRepository.create(specialization1)
        try await specRepository.create(specialization2)

        let all = try await specRepository.findAll()
        XCTAssertTrue(all.contains(where: { $0.id == specialization1.id }))
        XCTAssertTrue(all.contains(where: { $0.id == specialization2.id }))

        // Clean up
        try await specRepository.delete(id: specialization1.id)
        try await specRepository.delete(id: specialization2.id)
    }
    
    func testCreateSpecializationWithDuplicateName() async throws {
        let specialization = Specialization(id: UUID(), name: "Танцы")
        try await specRepository.create(specialization)

        let duplicate = Specialization(id: UUID(), name: "Танцы")
        do {
            try await specRepository.create(duplicate)
            XCTFail("Создание дубликата должно завершиться с ошибкой")
        } catch {
            // Ожидаемая ошибка: нарушение уникальности
        }
        try await specRepository.delete(id: specialization.id)
    }

    func testUpdateNonExistentSpecialization() async throws {
        let nonExistent = Specialization(id: UUID(), name: "Несуществующая")
        do {
            try await specRepository.update(nonExistent)
            XCTFail("Обновление несуществующей специализации должно завершиться с ошибкой")
        } catch let error as SpecializationError {
            XCTAssertEqual(error, .specializationNotFound)
        }
    }

    func testDeleteNonExistentSpecialization() async throws {
        let randomID = UUID()
        do {
            try await specRepository.delete(id: randomID)
            XCTFail("Удаление несуществующей специализации должно завершиться с ошибкой")
        } catch let error as SpecializationError {
            XCTAssertEqual(error, .specializationNotFound)
        }
    }

    func testCreateSpecializationWithLongName() async throws {
        let longName = String(repeating: "A", count: 130)
        let specialization = Specialization(id: UUID(), name: longName)

        do {
            try await specRepository.create(specialization)
            XCTFail("Создание специализации с длинным именем должно завершиться с ошибкой")
        } catch {
            // Ожидаемое поведение — ошибка из-за ограничения длины
        }
    }
}
