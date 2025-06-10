//
//  AttendanceRepositoryMock.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Foundation
import Domain

public actor AttendanceRepositoryMock {
    private var attendances: [Attendance] = []
}

// MARK: - IAttendanceRepository

extension AttendanceRepositoryMock: IAttendanceRepository {
    public func create(_ attendance: Attendance) async throws {
        attendances.append(attendance)
    }

    public func update(_ attendance: Attendance) async throws {
        guard
            let index = attendances.firstIndex(
                where: { $0.id == attendance.id }
            )
        else { return }

        attendances[index] = attendance
    }

    public func find(id: UUID) async throws -> Attendance? {
        attendances.first(
            where: { $0.id == id }
        )
    }

    public func find(trainingId: UUID) async throws -> [Attendance] {
        attendances.filter {
            $0.trainingId == trainingId
        }
    }

    public func find(membershipId: UUID) async throws -> [Attendance] {
        attendances.filter {
            $0.membershipId == membershipId
        }
    }

    public func findAll() async throws -> [Attendance] {
        attendances
    }

    public func delete(id: UUID) async throws {
        guard
            let index = attendances.firstIndex(
                where: { $0.id == id }
            )
        else {
            throw AttendanceError.attendanceNotFound
        }
        attendances.remove(at: index)
    }
}
