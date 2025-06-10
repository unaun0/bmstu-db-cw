//
//  TrainingRepository.swift
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

final class TrainingRepositoryTests: XCTestCase {
    var app: Application!
    var db: Database!
    var userRepository: UserRepository!
    var trainerRepository: TrainerRepository!
    var specializationRepository: SpecializationRepository!
    var trainingRoomRepository: TrainingRoomRepository!
    var repository: TrainingRepository!

    var userId: UUID!
    var trainerId: UUID!
    var specializationId: UUID!
    var roomId: UUID!

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
        trainingRoomRepository = TrainingRoomRepository(db: db)
        repository = TrainingRepository(db: db)

        let user = User(
            email: "trainer@example.com",
            phoneNumber: "+79998887766",
            password: "TrainerPass123!",
            firstName: "Елена",
            lastName: "Кузнецова",
            birthDate: Calendar.current.date(
                byAdding: .year,
                value: -30,
                to: Date()
            )!,
            gender: .female,
            role: .trainer
        )
        try await userRepository.create(user)
        userId = user.id

        let trainer = Trainer(userId: userId, description: "Trainer")
        try await trainerRepository.create(trainer)
        trainerId = trainer.id

        let specialization = Specialization(name: "Йога")
        try await specializationRepository.create(specialization)
        specializationId = specialization.id

        let room = TrainingRoom(name: "Зал A", capacity: 15)
        try await trainingRoomRepository.create(room)
        roomId = room.id
    }

    override func tearDown() async throws {
        try await trainingRoomRepository.delete(id: roomId)
        try await specializationRepository.delete(id: specializationId)
        try await trainerRepository.delete(id: trainerId)
        try await userRepository.delete(id: userId)
        try await app.asyncShutdown()
    }

    func testCreateAndFindTraining() async throws {
        let training = Training(
            date: Date(),
            specializationId: specializationId,
            roomId: roomId,
            trainerId: trainerId
        )
        try await repository.create(training)

        let found = try await repository.find(id: training.id)
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.id, training.id)
        
        try await repository.delete(id: training.id)
    }

    func testUpdateTraining() async throws {
        let oldDate = Date()
        let newDate = Calendar.current.date(byAdding: .day, value: 1, to: oldDate)!

        let training = Training(
            date: oldDate,
            specializationId: specializationId,
            roomId: roomId,
            trainerId: trainerId
        )
        try await repository.create(training)

        let updated = Training(
            id: training.id,
            date: newDate,
            specializationId: specializationId,
            roomId: roomId,
            trainerId: trainerId
        )
        try await repository.update(updated)
        
        try await repository.delete(id: training.id)
    }

    func testFindByTrainerId() async throws {
        let training = Training(
            date: Date(),
            specializationId: specializationId,
            roomId: roomId,
            trainerId: trainerId
        )
        try await repository.create(training)

        let found = try await repository.find(trainerId: trainerId)
        XCTAssertTrue(found.contains { $0.id == training.id })
        
        try await repository.delete(id: training.id)
    }

    func testFindBySpecializationId() async throws {
        let training = Training(
            date: Date(),
            specializationId: specializationId,
            roomId: roomId,
            trainerId: trainerId
        )
        try await repository.create(training)

        let found = try await repository.find(specializationId: specializationId)
        XCTAssertTrue(found.contains { $0.id == training.id })
        
        try await repository.delete(id: training.id)
    }

    func testFindByRoomId() async throws {
        let training = Training(
            date: Date(),
            specializationId: specializationId,
            roomId: roomId,
            trainerId: trainerId
        )
        try await repository.create(training)

        let found = try await repository.find(trainingRoomId: roomId)
        XCTAssertTrue(found.contains { $0.id == training.id })
        
        try await repository.delete(id: training.id)
    }
}
