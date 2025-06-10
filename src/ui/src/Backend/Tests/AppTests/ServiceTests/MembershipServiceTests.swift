////
////  MembershipServiceTests.swift
////  Backend
////
////  Created by Цховребова Яна on 19.03.2025.
////
//
//import Fluent
//import Vapor
//import XCTest
//
//@testable import App
//
//final class MembershipServiceTests: XCTestCase {
//    var membershipService: IMembershipService!
//    var membershipRepositoryMock: IMembershipRepository!
//
//    override func setUp() {
//        super.setUp()
//        membershipRepositoryMock = MembershipRepositoryMock()
//        membershipService = MembershipService(
//            repository: membershipRepositoryMock,
//            membershipRepository: MembershipRepository as! IMembershipRepository
//        )
//    }
//
//    override func tearDown() {
//        membershipRepositoryMock = nil
//        membershipService = nil
//        super.tearDown()
//    }
//    
//     // MARK: - Тесты на создание
//    
//    func testCreateMembership_Success() async throws {
//        let mpDTO = MembershipCreateDTO(
//            userID: UUID(),
//            membershipTypeID: UUID(),
//            orderID: UUID(),
//            startDate: Date(),
//            endDate: Date().addingTimeInterval(86400),
//            availableSessions: 10
//        )
//        let mp = try await membershipService.create(mpDTO)
//        let fmp = try await membershipRepositoryMock.find(
//            id: mp!.id!
//        )
//        XCTAssertNotNil(fmp)
//    }
//    
//     // MARK: - Тесты на обновление
//     
//    func testUpdateMembership_Success() async throws {
//        let mpDTO = MembershipCreateDTO(
//            userID: UUID(),
//            membershipTypeID: UUID(),
//            orderID: UUID(),
//            startDate: Date(),
//            endDate: Date().addingTimeInterval(86400),
//            availableSessions: 10
//        )
//        let mp = try await membershipService.create(mpDTO)
//        let umpDTO = MembershipUpdateDTO(
//            userID: UUID(),
//            membershipTypeID: UUID(),
//            orderID: UUID(),
//            startDate: Date(),
//            endDate: Date().addingTimeInterval(86500),
//            availableSessions: 15
//        )
//        let ump = try await membershipService.update(
//            id: mp!.id!, with: umpDTO
//        )
//        XCTAssertNotNil(ump)
//    }
//
//     // MARK: - Тесты на поиск
//     
//    func testFindMembership_ById() async throws {
//        let mpDTO = MembershipCreateDTO(
//            userID: UUID(),
//            membershipTypeID: UUID(),
//            orderID: UUID(),
//            startDate: Date(),
//            endDate: Date().addingTimeInterval(86400),
//            availableSessions: 10
//        )
//        let mp = try await membershipService.create(mpDTO)
//        let fmp = try await membershipService.find(id: mp!.id!)
//        XCTAssertNotNil(fmp)
//    }
//
//     // MARK: - Тесты на удаление
//     
//    func testDeleteMembership_Success() async throws {
//        let mpDTO = MembershipCreateDTO(
//            userID: UUID(),
//            membershipTypeID: UUID(),
//            orderID: UUID(),
//            startDate: Date(),
//            endDate: Date().addingTimeInterval(86400),
//            availableSessions: 10
//        )
//        let mp = try await membershipService.create(mpDTO)
//        try await membershipService.delete(id: mp!.id!)
//        let fmp = try await membershipRepositoryMock.find(id: mp!.id!)
//        XCTAssertNil(fmp)
//    }
//}
