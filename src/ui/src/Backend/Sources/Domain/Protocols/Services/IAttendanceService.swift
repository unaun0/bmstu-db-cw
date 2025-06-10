//
//  IAttendanceService.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public protocol IAttendanceService: Sendable {
    func create(_ data: AttendanceCreateDTO) async throws -> Attendance?
    func update(id: UUID, with data: AttendanceUpdateDTO) async throws -> Attendance?
    func find(id: UUID) async throws -> Attendance?
    func find(trainingId: UUID) async throws -> [Attendance]
    func find(membershipId: UUID) async throws -> [Attendance]
    func findAll() async throws -> [Attendance]
    func delete(id: UUID) async throws
}

public protocol ITrainerAttendanceService: Sendable {
    func getAttendances(trainingId: UUID, userId: UUID) async throws -> [Attendance]
    func updateStatus(attendanceId: UUID, userId: UUID, status: AttendanceStatus) async throws -> Attendance
}

public protocol IUserAttendanceService: Sendable {
    func getMyAttendances(userId: UUID) async throws -> [Attendance]
    func cancelAttendance(attendanceId: UUID, userId: UUID) async throws
    func signUp(trainingId: UUID, membershipId: UUID, userId: UUID) async throws -> Attendance?
}
