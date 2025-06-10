//
//  TrainerSpecializationServiceTests.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Fluent
import Vapor
import XCTest

@testable import App
@testable import Domain
@testable import DataAccess

final class TrainerSpecializationServiceTests: XCTestCase {
    var trainerSpecializationService: ITrainerSpecializationService!
    var trainerSpecializationRepositoryMock: ITrainerSpecializationRepository!

    override func setUp() {
        super.setUp()
        trainerSpecializationRepositoryMock =
            TrainerSpecializationRepositoryMock()
        trainerSpecializationService = TrainerSpecializationService(
            repository: trainerSpecializationRepositoryMock
        )
    }

    override func tearDown() {
        trainerSpecializationRepositoryMock = nil
        trainerSpecializationService = nil
        super.tearDown()
    }

    // MARK: - Тесты на создание специализации тренера

    func testCreateTrainerSpecialization_Success() async throws {
        let tsDTO = TrainerSpecializationCreateDTO(
            trainerId: UUID(),
            specializationId: UUID(),
            years: 3
        )
        let ts = try await trainerSpecializationService.create(tsDTO)
        let fts = try await trainerSpecializationRepositoryMock.find(
            id: ts!.id
        )
        XCTAssertEqual(fts, ts)
    }

    func testCreateTrainerSpecialization_TrainerSpecializationNotUnique()
        async throws
    {
        let tsDTO = TrainerSpecializationCreateDTO(
            trainerId: UUID(),
            specializationId: UUID(),
            years: 3
        )
        _ = try await trainerSpecializationService.create(tsDTO)
        do {
            _ = try await trainerSpecializationService.create(tsDTO)
            XCTFail()
        } catch TrainerSpecializationError.trainerSpecializationNotUnique {
        } catch {
            XCTFail()
        }
    }

    // MARK: - Тесты на обновление специализации тренера

    func testUpdateTrainerSpecialization_Success() async throws {
        let tsDTO = TrainerSpecializationCreateDTO(
            trainerId: UUID(),
            specializationId: UUID(),
            years: 3
        )
        let ts = try await trainerSpecializationService.create(tsDTO)
        let utsDTO = TrainerSpecializationUpdateDTO(
            trainerId: UUID(),
            specializationId: UUID(),
            years: 10
        )
        let uts = try await trainerSpecializationService.update(
            id: ts!.id,
            with: utsDTO
        )
        XCTAssertNotNil(uts)
        XCTAssertEqual(ts, uts)
    }

    func testUpdateTrainerSpecialization_TrainerSpecializationNotUnique()
        async throws
    {
        let tsDTO = TrainerSpecializationCreateDTO(
            trainerId: UUID(),
            specializationId: UUID(),
            years: 3
        )
        let ts = try await trainerSpecializationService.create(tsDTO)
        let tsDTO2 = TrainerSpecializationCreateDTO(
            trainerId: tsDTO.trainerId,
            specializationId: UUID(),
            years: 3
        )
        _ = try await trainerSpecializationService.create(tsDTO2)
        let utsDTO = TrainerSpecializationUpdateDTO(
            trainerId: nil,
            specializationId: tsDTO2.specializationId,
            years: 10
        )
        do {
            _ = try await trainerSpecializationService.update(
                id: ts!.id,
                with: utsDTO
            )
            XCTFail()
        } catch TrainerSpecializationError.trainerSpecializationNotUnique {
        } catch {
            XCTFail()
        }
    }

    // MARK: - Тесты на удаление специализации тренера
    func testDeleteTrainerSpecialization_Success() async throws {
        let tsDTO = TrainerSpecializationCreateDTO(
            trainerId: UUID(),
            specializationId: UUID(),
            years: 3
        )
        let ts = try await trainerSpecializationService.create(tsDTO)
        try await trainerSpecializationService.delete(id: ts!.id)
        let fts = try await trainerSpecializationRepositoryMock.find(
            id: ts!.id
        )
        XCTAssertNil(fts)
    }

    // MARK: - Тесты на поиск специализаций тренера

    func testFindTrainerSpecializationByTrainerID_Success() async throws {
        let tsDTO = TrainerSpecializationCreateDTO(
            trainerId: UUID(),
            specializationId: UUID(),
            years: 3
        )
        let ts = try await trainerSpecializationService.create(tsDTO)
        let ftsByID = try await trainerSpecializationService.find(id: ts!.id)
        XCTAssertNotNil(ftsByID)
        let ftsByTrainerID = try await trainerSpecializationService.find(
            trainerId: tsDTO.trainerId
        )
        XCTAssertEqual(ftsByTrainerID.count, 1)
        let ftsBySpecID = try await trainerSpecializationService.find(
            specializationId: tsDTO.specializationId
        )
        XCTAssertEqual(ftsBySpecID.count, 1)
    }
}
