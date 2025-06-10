import Fluent
import Vapor
import XCTest

@testable import App
@testable import Domain
@testable import DataAccess

final class TrainingRoomServiceTests: XCTestCase {
    var trainingRoomService: ITrainingRoomService!
    var trainingRoomRepositoryMock: ITrainingRoomRepository!

    override func setUp() {
        super.setUp()
        trainingRoomRepositoryMock = TrainingRoomRepositoryMock()
        trainingRoomService = TrainingRoomService(
            repository: trainingRoomRepositoryMock
        )
    }

    override func tearDown() {
        trainingRoomRepositoryMock = nil
        trainingRoomService = nil
        super.tearDown()
    }

    // MARK: - Тесты на создание зала

    func testCreateTrainingRoom_Success() async throws {
        let roomDTO = TrainingRoomCreateDTO(
            name: "Зал 1",
            capacity: 20
        )
        let room = try await trainingRoomService.create(roomDTO)
        let createdRoom = try await trainingRoomRepositoryMock.find(
            id: room!.id
        )

        XCTAssertNotNil(createdRoom)
        XCTAssertEqual(createdRoom, room)
    }

    func testCreateTrainingRoom_NameAlreadyExists() async throws {
        let roomDTO = TrainingRoomCreateDTO(
            name: "Зал 1",
            capacity: 20
        )
        _ = try await trainingRoomService.create(roomDTO)
        do {
            _ = try await trainingRoomService.create(roomDTO)
            XCTFail()
        } catch TrainingRoomError.nameAlreadyExists {
        } catch {
            XCTFail()
        }
    }

    // MARK: - Тесты на обновление зала

    func testUpdateTrainingRoom_Success() async throws {
        let roomDTO = TrainingRoomCreateDTO(
            name: "Зал 1",
            capacity: 20
        )
        let room = try await trainingRoomService.create(roomDTO)
        let updRoomDTO = TrainingRoomUpdateDTO(
            name: "Зал 2",
            capacity: nil
        )
        let updRoom = try await trainingRoomService.update(
            id: room!.id,
            with: updRoomDTO
        )
        XCTAssertNotNil(updRoom)
        XCTAssertEqual(updRoom!.id, room!.id)
        XCTAssertEqual(updRoom!.name, "Зал 2")
        XCTAssertEqual(updRoom!.capacity, room!.capacity)
    }

    func testUpdateTrainingRoom_NameAlreadyExists() async throws {
        let roomDTO = TrainingRoomCreateDTO(
            name: "Зал 1",
            capacity: 20
        )
        let room = try await trainingRoomService.create(roomDTO)
        let updRoomDTO = TrainingRoomUpdateDTO(
            name: "Зал 1",
            capacity: nil
        )
        do {
            _ = try await trainingRoomService.update(
                id: room!.id,
                with: updRoomDTO
            )
            XCTFail()
        } catch TrainingRoomError.nameAlreadyExists {
        } catch {
            XCTFail()
        }
    }

    // MARK: - Тесты на удаление зала

    func testDeleteTrainingRoom_Success() async throws {
        let roomDTO = TrainingRoomCreateDTO(
            name: "Зал 1",
            capacity: 20
        )
        let room = try await trainingRoomService.create(roomDTO)
        try await trainingRoomService.delete(id: room!.id)
        let deletedRoom = try await trainingRoomRepositoryMock.find(
            id: room!.id
        )
        XCTAssertNil(deletedRoom)
    }
}
