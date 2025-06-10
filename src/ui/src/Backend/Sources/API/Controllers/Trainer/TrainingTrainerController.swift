//
//  Training.swift
//  Backend
//
//  Created by Цховребова Яна on 10.05.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class TrainingTrainerController: RouteCollection {
    private let trainingService: ITrainingTrainerService
    private let jwtMiddleware: JWTMiddleware
    private let trainerMiddleware: AdminOrTrainerRoleMiddleware
    private let createMiddleware: TrainingCreateValidationMiddleware
    private let updateMiddleware: TrainingValidationMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    
    public init(
        trainingService: ITrainingTrainerService,
        jwtMiddleware: JWTMiddleware,
        trainerMiddleware: AdminOrTrainerRoleMiddleware,
        createMiddleware: TrainingCreateValidationMiddleware,
        updateMiddleware: TrainingValidationMiddleware,
        uuidMiddleware: UUIDValidationMiddleware
    ) {
        self.trainingService = trainingService
        self.jwtMiddleware = jwtMiddleware
        self.trainerMiddleware = trainerMiddleware
        self.createMiddleware = createMiddleware
        self.updateMiddleware = updateMiddleware
        self.uuidMiddleware = uuidMiddleware
    }
    
    public func boot(routes: RoutesBuilder) throws {
        let trainingRoutes = routes.grouped(
            "trainer", "trainings"
        ).grouped(
            jwtMiddleware
        ).grouped(
            trainerMiddleware
        )
        trainingRoutes.get(
            "all",
            use: getAllTrainings
        ).openAPI(
            tags: .init(name: "Trainer - Training"),
            summary: "Получить список всех тренировок для тренера",
            description:
                "Возвращает все тренировки тренера. Требует прав тренера.",
            response: .type([TrainingInfoDTO].self),
            auth: .bearer()
        )
        trainingRoutes.get(
            "current",
            use: getAllCurrentTrainings
        ).openAPI(
            tags: .init(name: "Trainer - Training"),
            summary: "Получить список всех доступных тренировок для тренера",
            description:
                "Возвращает все доступные тренировки тренера. Требует прав тренера.",
            response: .type([TrainingInfoDTO].self),
            auth: .bearer()
        )
        trainingRoutes.grouped(
            createMiddleware
        ).post(
            use: createTraining
        ).openAPI(
            tags: .init(name: "Trainer - Training"),
            summary: "Создать новую тренировку для тренера",
            description:
                "Создает новую тренировку. Требует прав тренера.",
            body: .type(TrainingCreateDTO.self),
            response: .type(TrainingDTO.self),
            auth: .bearer()
        )
        trainingRoutes.grouped(
            uuidMiddleware
        ).delete(
            ":id",
            use: deleteTrainingById
        ).openAPI(
            tags: .init(name: "Trainer - Training"),
            summary: "Удалить тренировку по ID для тренера",
            description:
                "Удаляет тренировку по ее UUID. Требует прав тренера.",
            response: .type([TrainingDTO].self),
            auth: .bearer()
        )
        trainingRoutes.grouped(
            uuidMiddleware
        ).grouped(
            updateMiddleware
        ).put(
            ":id",
            use: updateTrainingById
        ).openAPI(
            tags: .init(name: "Trainer - Training"),
            summary: "Обновить тренировку для тренера",
            description:
                "Обновляет данные тренировки. Требует прав тренера.",
            body: .type(TrainingUpdateDTO.self),
            response: .type(TrainingDTO.self),
            auth: .bearer()
        )
        trainingRoutes.get(
            "rooms",
            use: getAllTrainingRooms
        ).openAPI(
            tags: .init(name: "Trainer - Training"),
            summary: "Получить список залов тренировок для тренера",
            description:
                "Возвращает все залы. Требует прав тренера.",
            response: .type([TrainingRoomDTO].self),
            auth: .bearer()
        )
    }
}

// MARK: - Routes Realization

extension TrainingTrainerController {
    @Sendable
    func getAllTrainingRooms(
        req: Request
    ) async throws -> Response {
        try await trainingService.findAllRooms().map {
            TrainingRoomDTO(from: $0)
        }.encodeResponse(status: .ok, for: req)
    }
    
    @Sendable
    func deleteTrainingById(req: Request)
    async throws -> HTTPStatus {
        try await trainingService.delete(
            userId: req.auth.require(User.self).id,
            trainingId: try req.parameters.require(
                "id",
                as: UUID.self
            )
        )
        return .noContent
    }
    
    @Sendable
    func createTraining(req: Request) async throws -> Response {
        guard let training = try await trainingService.create(
            userId: req.auth.require(User.self).id,
            try req.content.decode(
                TrainingCreateDTO.self
            )
        ) else {
            throw TrainingError.invalidCreation
        }
        return try await TrainingDTO(
            from: training
        ).encodeResponse(status: .ok, for: req)
    }
    
    @Sendable
    func updateTrainingById(req: Request)
    async throws -> Response {
        guard let training = try await trainingService.update(
            userId: req.auth.require(User.self).id,
            trainingId: try req.parameters.require(
                "id",
                as: UUID.self
            ),
            with: try req.content.decode(
                TrainingUpdateDTO.self
            )
        ) else {
            throw TrainingError.invalidUpdate
        }
        return try await TrainingDTO(
            from: training
        ).encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func getAllTrainings(
        req: Request
    ) async throws -> Response {
        try await trainingService.findAllTrainings(
            userId: req.auth.require(User.self).id
        ).encodeResponse(status: .ok, for: req)
    }
    
    @Sendable
    func getAllCurrentTrainings(
        req: Request
    ) async throws -> Response {
        try await trainingService.findAvailableTrainings(
            userId: req.auth.require(User.self).id
        ).encodeResponse(status: .ok, for: req)
    }
}

extension TrainingTrainerController: @unchecked Sendable {}
