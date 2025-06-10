//
//  TrainingServiceTests.swift
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

final class TrainingServiceTests: XCTestCase {
    var trainingService: ITrainingService!
    var trainingRepositoryMock: ITrainingRepository!

    override func setUp() {
        super.setUp()
        trainingRepositoryMock = TrainingRepositoryMock()
        trainingService = TrainingService(
            repository: trainingRepositoryMock
        )
    }

    override func tearDown() {
        trainingRepositoryMock = nil
        trainingService = nil
        super.tearDown()
    }

    // MARK: - Тесты на создание тренировки

    func testCreateTraining_Success() async throws {
        let trainingDTO = TrainingCreateDTO(
            date: Date().toString(format: ValidationRegex.DateFormat.format),
            specializationId: UUID(),
            roomId: UUID(),
            trainerId: UUID()
        )
        let training = try await trainingService.create(trainingDTO)
        let foundTraining = try await trainingRepositoryMock.find(
            id: training!.id)
        XCTAssertNotNil(foundTraining)
        XCTAssertEqual(foundTraining, training)
    }

    // MARK: - Тесты на поиск тренировки

    func testFindTraining_Success() async throws {
        let trainingDTO = TrainingCreateDTO(
            date: Date().toString(format: ValidationRegex.DateFormat.format),
            specializationId: UUID(),
            roomId: UUID(),
            trainerId: UUID()
        )
        let training = try await trainingService.create(trainingDTO)

        let foundTraining = try await trainingService.find(id: training!.id)
        XCTAssertNotNil(foundTraining)

        let newTrainingDTO = TrainingCreateDTO(
            date: Date().addingTimeInterval(186400).toString(format: ValidationRegex.DateFormat.format),
            specializationId: UUID(),
            roomId: UUID(),
            trainerId: UUID()
        )
        _ = try await trainingService.create(newTrainingDTO)

        let foundTrainings = try await trainingService.find(
            date: (trainingDTO.date?.toDate(format: ValidationRegex.DateFormat.format)!)!
        )
        XCTAssertEqual(foundTrainings.count, 1)
        XCTAssertEqual(foundTraining, foundTrainings[0])
    }

    // MARK: - Тесты на удаление тренировки

    func testDeleteTraining_Success() async throws {
        let trainingDTO = TrainingCreateDTO(
            date: Date().toString(format: ValidationRegex.DateFormat.format),
            specializationId: UUID(),
            roomId: UUID(),
            trainerId: UUID()
        )
        let training = try await trainingService.create(trainingDTO)
        try await trainingService.delete(id: training!.id)
        let foundTraining = try await trainingRepositoryMock.find(
            id: training!.id)

        XCTAssertNil(foundTraining)
    }
}
