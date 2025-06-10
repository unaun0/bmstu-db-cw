//
//  TrainingRoomRepositoryMock.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Foundation
import Domain

public actor TrainingRoomRepositoryMock {
    private var rooms: [TrainingRoom] = []
}

// MARK: - ITrainingRoomRepository

extension TrainingRoomRepositoryMock: ITrainingRoomRepository {
    public func create(_ room: TrainingRoom) async throws {
        rooms.append(room)
    }

    public func update(_ room: TrainingRoom) async throws {
        guard
            let index = rooms.firstIndex(
                where: {
                    $0.id == room.id
                }
            )
        else { return }

        rooms[index] = room
    }

    public func find(id: UUID) async throws -> TrainingRoom? {
        rooms.first(where: { $0.id == id })
    }

    public func find(name: String) async throws -> TrainingRoom? {
        rooms.first(where: { $0.name == name })
    }

    public func find(capacity: Int) async throws -> [TrainingRoom] {
        rooms.filter { $0.capacity == capacity }
    }

    public func findAll() async throws -> [TrainingRoom] {
        rooms
    }

    public func delete(id: UUID) async throws {
        guard
            let index = rooms.firstIndex(
                where: {
                    $0.id == id
                }
            )
        else {
            throw TrainingRoomError.trainingRoomNotFound
        }
        rooms.remove(at: index)
    }
}
