//
//  TrainerServiceTests.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Vapor
import XCTest

@testable import App
@testable import Domain
@testable import DataAccess

final class TrainerServiceTests: XCTestCase {
    var trainerService: ITrainerService!
    var trainerRepositoryMock: ITrainerRepository!

    override func setUp() {
        super.setUp()
        trainerRepositoryMock = TrainerRepositoryMock()
        trainerService = TrainerService(
            repository: trainerRepositoryMock
        )
    }

    override func tearDown() {
        trainerRepositoryMock = nil
        trainerService = nil
        super.tearDown()
    }
    // MARK: - Тесты на создание тренера

    func testCreateTrainer_Success() async throws {
        let trainerDTO = TrainerCreateDTO(
            userId: UUID(),
            description: "Опытный тренер"
        )
        let trainer = try await trainerService.create(trainerDTO)
        let createdTrainer = try await trainerRepositoryMock.find(
            id: trainer!.id
        )
        XCTAssertNotNil(createdTrainer)
    }

    func testCreateTrainer_UserAlreadyHasTrainer() async throws {
        let trainerDTO = TrainerCreateDTO(
            userId: UUID(),
            description: "Опытный тренер"
        )
        _ = try await trainerService.create(trainerDTO)
        do {
            _ = try await trainerService.create(trainerDTO)
            XCTFail()
        } catch TrainerError.userAlreadyHasTrainer {
        } catch {
            XCTFail()
        }
    }

    // MARK: - Тесты на обновление тренера

    func testUpdateTrainer_Success() async throws {
        let trainerDTO = TrainerCreateDTO(
            userId: UUID(),
            description: "Опытный тренер"
        )
        let trainer = try await trainerService.create(trainerDTO)
        let updTrainerDTO = TrainerUpdateDTO(
            userId: nil,
            description: "Начинающий тренер"
        )
        let updTrainer = try await trainerService.update(
            id: trainer!.id, with: updTrainerDTO)

        XCTAssertNotNil(updTrainer)
        XCTAssertEqual(updTrainer!.description, updTrainerDTO.description)
    }

    // MARK: - Тесты на удаление тренера

    func testDeleteTrainer_Success() async throws {
        let trainerDTO = TrainerCreateDTO(
            userId: UUID(),
            description: "Опытный тренер"
        )
        let trainer = try await trainerService.create(trainerDTO)
        try await trainerService.delete(id: trainer!.id)
        let ft = try await trainerRepositoryMock.find(
            id: trainer!.id
        )
        XCTAssertNil(ft)
    }
}
