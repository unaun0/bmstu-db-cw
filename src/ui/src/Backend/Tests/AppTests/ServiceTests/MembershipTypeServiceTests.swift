//
//  MembershipTypeServiceTests.swift
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

final class MembershipTypeServiceTests: XCTestCase {
    var membershipTypeService: IMembershipTypeService!
    var membershipTypeRepositoryMock: IMembershipTypeRepository!

    override func setUp() {
        super.setUp()
        membershipTypeRepositoryMock = MembershipTypeRepositoryMock()
        membershipTypeService = MembershipTypeService(
            repository: membershipTypeRepositoryMock
        )
    }

    override func tearDown() {
        membershipTypeRepositoryMock = nil
        membershipTypeService = nil
        super.tearDown()
    }

    // MARK: - Тесты на создание типа абонемента

    func testCreateMembershipType_Success() async throws {
        let mtDTO = MembershipTypeCreateDTO(
            name: "Стандартный абонемент",
            price: 1000.0,
            sessions: 10,
            days: 30
        )
        let mt = try await membershipTypeService.create(mtDTO)
        let fmt = try await membershipTypeRepositoryMock.find(id: mt!.id)
        XCTAssertNotNil(fmt)
    }

    // MARK: - Тесты на обновление типа абонемента

    func testUpdateMembershipType_Success() async throws {
        let mtDTO = MembershipTypeCreateDTO(
            name: "Стандартный абонемент",
            price: 1000.0,
            sessions: 10,
            days: 30
        )
        let mt = try await membershipTypeService.create(mtDTO)

        let umtDTO = MembershipTypeUpdateDTO(
            name: "Премиум абонемент",
            price: 2000.0,
            sessions: 20,
            days: 60
        )
        let umt = try await membershipTypeService.update(
            id: mt!.id,
            with: umtDTO
        )
        XCTAssertNotNil(umt)
    }

    // MARK: - Тесты на удаление типа абонемента

    func testDeleteMembershipType_Success() async throws {
        let mtDTO = MembershipTypeCreateDTO(
            name: "Стандартный абонемент",
            price: 1000.0,
            sessions: 10,
            days: 30
        )
        let mt = try await membershipTypeService.create(mtDTO)
        try await membershipTypeService.delete(id: mt!.id)
        let fmt = try await membershipTypeRepositoryMock.find(
            id: mt!.id
        )
        XCTAssertNil(fmt)
    }

    // MARK: - Тесты на поиск типа абонемента
    func testFindMembershipTypeById_Success() async throws {
        let mtDTO = MembershipTypeCreateDTO(
            name: "Стандартный абонемент",
            price: 1000.0,
            sessions: 10,
            days: 30
        )
        let mt = try await membershipTypeService.create(mtDTO)

        let fmtID = try await membershipTypeService.find(
            id: mt!.id
        )
        XCTAssertNotNil(fmtID)
    }
}
