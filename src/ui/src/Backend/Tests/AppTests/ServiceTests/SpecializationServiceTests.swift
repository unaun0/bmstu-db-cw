//
//  SpecializationServiceTests.swift
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

final class SpecializationServiceTests: XCTestCase {
    var specializationService: ISpecializationService!
    var specializationRepositoryMock: ISpecializationRepository!

    override func setUp() {
        super.setUp()
        specializationRepositoryMock = SpecializationRepositoryMock()
        specializationService = SpecializationService(
            repository: specializationRepositoryMock
        )
    }

    override func tearDown() {
        specializationRepositoryMock = nil
        specializationService = nil
        super.tearDown()
    }

    // MARK: - Тесты на создание специализации

    func testCreateSpecialization_Success() async throws {
        let specDTO = SpecializationCreateDTO(
            name: "Фитнес"
        )
        let spec = try await specializationService.create(specDTO)
        let fspec = try await specializationRepositoryMock.find(
            id: spec!.id
        )
        XCTAssertNotNil(fspec)
        XCTAssertEqual(fspec!.name, specDTO.name)
    }

    func testCreateSpecialization_NameAlreadyExists() async throws {
        let specDTO = SpecializationCreateDTO(
            name: "Фитнес"
        )
        _ = try await specializationService.create(specDTO)
        do {
            _ = try await specializationService.create(specDTO)
            XCTFail()
        } catch SpecializationError.nameAlreadyExists {
        } catch {
            XCTFail()
        }
    }

    // MARK: - Тесты на обновление специализации

    func testUpdateSpecialization_Success() async throws {
        let specDTO = SpecializationCreateDTO(
            name: "Фитнес"
        )
        let spec = try await specializationService.create(specDTO)
        let updSpecDTO = SpecializationUpdateDTO(
            name: "Йога"
        )
        let result = try await specializationService.update(
            id: spec!.id,
            with: updSpecDTO
        )
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.name, updSpecDTO.name)
    }

    func testUpdateSpecialization_NameAlreadyExists() async throws {
        let specDTO = SpecializationCreateDTO(
            name: "Фитнес"
        )
        let spec = try await specializationService.create(specDTO)
        let updSpecDTO = SpecializationUpdateDTO(
            name: "Фитнес"
        )
        do {
            _ = try await specializationService.update(
                id: spec!.id,
                with: updSpecDTO
            )
            XCTFail()
        } catch SpecializationError.nameAlreadyExists {
        } catch {
            XCTFail()
        }
    }

    // MARK: - Тесты на удаление специализации

    func testDeleteSpecialization_Success() async throws {
        let specDTO = SpecializationCreateDTO(
            name: "Фитнес"
        )
        let spec = try await specializationService.create(specDTO)
        try await specializationService.delete(id: spec!.id)
        let fspec = try await specializationRepositoryMock.find(
            id: spec!.id
        )
        XCTAssertNil(fspec)
    }

    // MARK: - Тесты на поиск специализации

    func testFindSpecialization_Success() async throws {
        let specDTO = SpecializationCreateDTO(
            name: "Фитнес"
        )
        let spec = try await specializationService.create(specDTO)

        let fspecID = try await specializationService.find(
            id: spec!.id
        )
        XCTAssertNotNil(fspecID)

        let fspecName = try await specializationService.find(
            name: "Фитнес"
        )
        XCTAssertNotNil(fspecName)

        let fspecAll = try await specializationService.findAll()
        XCTAssertEqual(fspecAll.count, 1)
    }

}
