//
//  TrainerAttendanceController.swift
//  Backend
//
//  Created by Цховребова Яна on 12.05.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class TrainerAttendanceController: RouteCollection {
    private let attendanceService: ITrainerAttendanceService
    private let jwtMiddleware: JWTMiddleware
    private let trainerMiddleware: AdminOrTrainerRoleMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    private let statusMiddleware: AttendanceValidationMiddleware

    public init(
        attendanceService: ITrainerAttendanceService,
        jwtMiddleware: JWTMiddleware,
        trainerMiddleware: AdminOrTrainerRoleMiddleware,
        uuidMiddleware: UUIDValidationMiddleware,
        statusMiddleware: AttendanceValidationMiddleware
    ) {
        self.attendanceService = attendanceService
        self.jwtMiddleware = jwtMiddleware
        self.trainerMiddleware = trainerMiddleware
        self.uuidMiddleware = uuidMiddleware
        self.statusMiddleware = statusMiddleware
    }

    public func boot(routes: RoutesBuilder) throws {
        let attendanceRoutes = routes
            .grouped("trainer", "attendances")
            .grouped(jwtMiddleware)
            .grouped(trainerMiddleware)

        attendanceRoutes.grouped(uuidMiddleware).get(
            ":training-id",
            use: getAttendances
        ).openAPI(
            tags: .init(name: "Trainer - Attendance"),
            summary: "Получить список посещений по тренировке",
            description: "Доступно только тренеру. Возвращает посещения по конкретной тренировке.",
            response: .type([AttendanceDTO].self),
            auth: .bearer()
        )

        attendanceRoutes.grouped(
            uuidMiddleware,
            statusMiddleware
        ).put(
            ":attendance-id",
            use: updateAttendanceStatus
        ).openAPI(
            tags: .init(name: "Trainer - Attendance"),
            summary: "Обновить статус посещения",
            description: "Тренер может обновить статус посещения.",
            body: .type(AttendanceUpdateStatusDTO.self),
            response: .type(AttendanceDTO.self),
            auth: .bearer()
        )
    }

    @Sendable
    func getAttendances(req: Request) async throws -> Response {
        let userId = try req.auth.require(User.self).id
        let trainingId = try req.parameters.require("training-шd", as: UUID.self)
        let attendances = try await attendanceService.getAttendances(
            trainingId: trainingId,
            userId: userId
        )
        return try await attendances.map(AttendanceDTO.init(from:)).encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func updateAttendanceStatus(req: Request) async throws -> Response {
        let userId = try req.auth.require(User.self).id
        let attendanceId = try req.parameters.require("attendance-id", as: UUID.self)
        let dto = try req.content.decode(AttendanceUpdateStatusDTO.self)
        let updated = try await attendanceService.updateStatus(
            attendanceId: attendanceId,
            userId: userId,
            status: dto.status
        )
        return try await AttendanceDTO(from: updated).encodeResponse(status: .ok, for: req)
    }
}

extension TrainerAttendanceController: @unchecked Sendable {}
