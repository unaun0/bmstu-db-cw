//
//  TrainerSpecializationAdminController.swift
//  Backend
//
//  Created by Цховребова Яна on 26.03.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class TrainerSpecializationAdminController: RouteCollection {
    private let service: ITrainerSpecializationService
    private let jwtMiddleware: JWTMiddleware
    private let adminMiddleware: AdminRoleMiddleware
    private let createMiddleware:
    TrainerSpecializationCreateValidationMiddleware
    private let validationMiddleware: TrainerSpecializationValidationMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    
    public init(
        service: ITrainerSpecializationService,
        jwtMiddleware: JWTMiddleware,
        adminMiddleware: AdminRoleMiddleware,
        createMiddleware: TrainerSpecializationCreateValidationMiddleware,
        validationMiddleware: TrainerSpecializationValidationMiddleware,
        uuidMiddleware: UUIDValidationMiddleware
    ) {
        self.service = service
        self.adminMiddleware = adminMiddleware
        self.jwtMiddleware = jwtMiddleware
        self.createMiddleware = createMiddleware
        self.validationMiddleware = validationMiddleware
        self.uuidMiddleware = uuidMiddleware
    }
    
    public func boot(routes: RoutesBuilder) throws {
        let trainerSpecializationRoutes = routes.grouped(
            "admin", "trainer-specializations"
        ).grouped(
            jwtMiddleware
        ).grouped(
            adminMiddleware
        )
        
        trainerSpecializationRoutes.get(
            "all", use: getAllTrainerSpecializations
        )
        .openAPI(
            tags: .init(name: "Admin - TrainerSpecialization"),
            summary: "Получить все специализации тренеров для администратора",
            description: "Возвращает список всех связей тренер-специализация. Требует прав администратора.",
            response: .type([TrainerSpecializationDTO].self),
            auth: .bearer()
        )
        
        trainerSpecializationRoutes.grouped(uuidMiddleware).get(
            ":id", use: getTrainerSpecializationById
        )
        .openAPI(
            tags: .init(name: "Admin - TrainerSpecialization"),
            summary: "Получить специализацию тренера по ID для администратора",
            description: "Возвращает связь тренер-специализация по её UUID. Требует прав администратора.",
            response: .type(TrainerSpecializationDTO.self),
            auth: .bearer()
        )
        trainerSpecializationRoutes.grouped(uuidMiddleware).get(
            "trainer", ":trainer-id", use: getTrainerSpecializationByTrainerId
        )
        .openAPI(
            tags: .init(name: "Admin - TrainerSpecialization"),
            summary: "Получить специализации по ID тренера для администратора",
            description:
                "Возвращает все специализации, связанные с конкретным тренером. Требует прав администратора.",
            response: .type([TrainerSpecializationDTO].self),
            auth: .bearer()
        )
        trainerSpecializationRoutes.grouped(uuidMiddleware).get(
            "specialization", ":specialization-id",
            use: getTrainerSpecializationBySpecializationId
        )
        .openAPI(
            tags: .init(name: "Admin - TrainerSpecialization"),
            summary: "Получить тренеров по ID специализации для администратора",
            description:
                "Возвращает всех тренеров, имеющих указанную специализацию. Требует прав администратора.",
            response: .type([TrainerSpecializationDTO].self),
            auth: .bearer()
        )
        trainerSpecializationRoutes.grouped(createMiddleware).post(
            use: createTrainerSpecialization
        )
        .openAPI(
            tags: .init(name: "Admin - TrainerSpecialization"),
            summary: "Создать связь тренера и специализации для администратора",
            description: "Создаёт новую связь между тренером и специализацией. Требует прав администратора.",
            body: .type(TrainerSpecializationCreateDTO.self),
            response: .type(TrainerSpecializationDTO.self),
            auth: .bearer()
        )
        
        trainerSpecializationRoutes.grouped(uuidMiddleware).grouped(
            validationMiddleware
        ).put(":id", use: updateTrainerSpecializationById)
            .openAPI(
                tags: .init(name: "Admin - TrainerSpecialization"),
                summary: "Обновить связь тренера и специализации по ID для администратора",
                description:
                    "Обновляет существующую связь между тренером и специализацией по UUID. Требует прав администратора.",
                body: .type(TrainerSpecializationUpdateDTO.self),
                response: .type(TrainerSpecializationDTO.self),
                auth: .bearer()
            )
        
        trainerSpecializationRoutes.grouped(uuidMiddleware).delete(
            ":id", use: deleteTrainerSpecializationById
        )
        .openAPI(
            tags: .init(name: "Admin - TrainerSpecialization"),
            summary: "Удалить связь тренера и специализации по ID для администратора",
            description:
                "Удаляет существующую связь между тренером и специализацией по UUID. Требует прав администратора.",
            response: .type(HTTPStatus.self),
            auth: .bearer()
        )
    }
    
}

// MARK: - Routes Realization

extension TrainerSpecializationAdminController {
    @Sendable
    func getAllTrainerSpecializations(
        req: Request
    ) async throws -> [TrainerSpecializationDTO] {
        return try await service.findAll().map {
            TrainerSpecializationDTO(from: $0)
        }
    }

    @Sendable
    func createTrainerSpecialization(req: Request) async throws -> Response {
        guard
            let ts = try await service.create(
                try req.content.decode(
                    TrainerSpecializationCreateDTO.self
                )
            )
        else { throw TrainerSpecializationError.invalidCreation }
        return try await TrainerSpecializationDTO(
            from: ts
        ).encodeResponse(for: req)
    }

    @Sendable
    func updateTrainerSpecializationById(req: Request)
        async throws -> Response
    {
        guard
            let ts = try await service.update(
                id: try req.parameters.require(
                    "id",
                    as: UUID.self
                ),
                with: try req.content.decode(
                    TrainerSpecializationUpdateDTO.self
                )
            )
        else { throw TrainerSpecializationError.invalidUpdate }
        return try await TrainerSpecializationDTO(
            from: ts
        ).encodeResponse(for: req)
    }

    @Sendable
    func deleteTrainerSpecializationById(
        req: Request
    ) async throws -> HTTPStatus {
        try await service.delete(
            id: try req.parameters.require(
                "id",
                as: UUID.self
            )
        )
        return .noContent
    }

    @Sendable
    func getTrainerSpecializationById(
        req: Request
    ) async throws -> Response {
        guard
            let ts = try await service.find(
                id: try req.parameters.require(
                    "id",
                    as: UUID.self
                )
            )
        else { throw TrainerSpecializationError.trainerSpecializationNotFound }
        return try await TrainerSpecializationDTO(
            from: ts
        ).encodeResponse(for: req)
    }

    @Sendable
    func getTrainerSpecializationByTrainerId(
        req: Request
    ) async throws -> Response {
        return try await service.find(
            trainerId: try req.parameters.require(
                "trainer-id",
                as: UUID.self
            )
        ).map {
            TrainerSpecializationDTO(from: $0)
        }.encodeResponse(for: req)
    }

    @Sendable
    func getTrainerSpecializationBySpecializationId(req: Request)
        async throws -> Response
    {
        return try await service.find(
            specializationId: try req.parameters.require(
                "specialization-id",
                as: UUID.self
            )
        ).map {
            TrainerSpecializationDTO(from: $0)
        }.encodeResponse(for: req)
    }
}

extension TrainerSpecializationAdminController: @unchecked Sendable {}
