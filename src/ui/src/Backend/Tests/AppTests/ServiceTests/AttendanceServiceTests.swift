//
//  AttendanceServiceTests.swift
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

final class AttendanceServiceTests: XCTestCase {
    var attendanceService: IAttendanceService!
    var attendanceRepositoryMock: AttendanceRepositoryMock!
    
    override func setUp() {
        super.setUp()
        attendanceRepositoryMock = AttendanceRepositoryMock()
        attendanceService = AttendanceService(
            repository: attendanceRepositoryMock
        )
    }
    override func tearDown() {
        attendanceRepositoryMock = nil
        attendanceService = nil
        super.tearDown()
    }
    
     // MARK: - Тесты на создание
     
    func testCreateAttendance_Success() async throws {
        let atDTO = AttendanceCreateDTO(
            membershipId: UUID(),
            trainingId: UUID(),
            status: AttendanceStatus(rawValue: "ожидает")!
        )
        let at = try await attendanceService.create(atDTO)
        let fat = try await attendanceRepositoryMock.find(id: at!.id)
        XCTAssertNotNil(fat)
    }
    
     // MARK: - Тесты на обновление
     
    func testUpdateAttendance_Success() async throws {
        let atDTO = AttendanceCreateDTO(
            membershipId: UUID(),
            trainingId: UUID(),
            status: AttendanceStatus(rawValue: "ожидает")!
        )
        let at = try await attendanceService.create(atDTO)
        let uatDTO = AttendanceUpdateDTO(
            membershipId: UUID(),
            trainingId: UUID(),
            status: nil
        )
        let uat = try await attendanceService.update(id: at!.id, with: uatDTO)
        XCTAssertNotNil(uat)
    }

     // MARK: - Тесты на поиск
     
    func testFindAttendance_Success() async throws {
        let atDTO = AttendanceCreateDTO(
            membershipId: UUID(),
            trainingId: UUID(),
            status: AttendanceStatus(rawValue: "ожидает")!
        )
        let at = try await attendanceService.create(atDTO)
        let fat = try await attendanceService.find(id: at!.id)
        XCTAssertNotNil(fat)
    }

     // MARK: - Тесты на удаление
     
    func testDeleteAttendance_Success() async throws {
        let atDTO = AttendanceCreateDTO(
            membershipId: UUID(),
            trainingId: UUID(),
            status: AttendanceStatus(rawValue: "ожидает")!
        )
        let at = try await attendanceService.create(atDTO)
        try await attendanceService.delete(id: at!.id)
        let fat = try await attendanceRepositoryMock.find(
            id: at!.id
        )
        XCTAssertNil(fat)
    }
}
