//
//  SpecializationAdminController.swift
//  Backend
//
//  Created by Цховребова Яна on 23.03.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class SpecializationAdminController: RouteCollection {
    private let service: ISpecializationService
    private let jwtMiddleware: JWTMiddleware
    private let adminMiddleware: AdminRoleMiddleware
    private let specCreateMiddleware: SpecializationCreateValidationMiddleware
    private let specMiddleware: SpecializationValidationMiddleware
    private let specNameMiddleware: SpecializationFindByNameValidationMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    
    public init(
        service: ISpecializationService,
        jwtMiddleware: JWTMiddleware,
        adminMiddleware: AdminRoleMiddleware,
        specCreateMiddleware: SpecializationCreateValidationMiddleware,
        specMiddleware: SpecializationValidationMiddleware,
        specNameMiddleware: SpecializationFindByNameValidationMiddleware,
        uuidMiddleware: UUIDValidationMiddleware
    ) {
        self.service = service
        self.jwtMiddleware = jwtMiddleware
        self.adminMiddleware = adminMiddleware
        self.specCreateMiddleware = specCreateMiddleware
        self.specMiddleware = specMiddleware
        self.specNameMiddleware = specNameMiddleware
        self.uuidMiddleware = uuidMiddleware
    }
    
    public func boot(routes: RoutesBuilder) throws {
        let specializationRoutes = routes.grouped(
            "admin", "specializations"
        ).grouped(
            jwtMiddleware
        ).grouped(adminMiddleware)
        
        specializationRoutes.get(
            "all",
            use: getAllSpecializations
        ).openAPI(
            tags: .init(name: "Admin - Specialization"),
            summary: "Получить все специализации для администратора.",
            description: "Возвращает список всех доступных специализаций.",
            response: .type([SpecializationDTO].self),
            auth: .bearer()
        )
        specializationRoutes.grouped(
            uuidMiddleware
        ).get(
            ":id",
            use: getSpecializationById
        ).openAPI(
            tags: .init(name: "Admin - Specialization"),
            summary: "Получить специализацию по ID для администратора.",
            description: "Возвращает специализацию по её уникальному идентификатору.",
            response: .type(SpecializationDTO.self),
            auth: .bearer()
        )
        specializationRoutes.grouped(
            specNameMiddleware
        ).get(
            "name",
            ":name",
            use: getSpecializationByName
        ).openAPI(
            tags: .init(name: "Admin - Specialization"),
            summary: "Получить специализацию по названию для администратора.",
            description: "Возвращает специализацию по имени.",
            response: .type(SpecializationDTO.self),
            auth: .bearer()
        )
        specializationRoutes.grouped(
            specCreateMiddleware
        ).post(
            use: createSpecialization
        ).openAPI(
            tags: .init(name: "Admin - Specialization"),
            summary: "Создать новую специализацию для администратора.",
            description: "Доступно только для администраторов. Создаёт новую специализацию.",
            body: .type(SpecializationCreateDTO.self),
            response: .type(SpecializationDTO.self),
            auth: .bearer()
        )
        specializationRoutes.grouped(
            uuidMiddleware
        ).grouped(
            specMiddleware
        ).put(
            ":id",
            use: updateSpecializationById
        ).openAPI(
            tags: .init(name: "Admin - Specialization"),
            summary: "Обновить специализацию для администратора.",
            description: "Обновляет данные специализации по её ID. Только для администраторов.",
            body: .type(SpecializationUpdateDTO.self),
            response: .type(SpecializationDTO.self),
            auth: .bearer()
        )
        specializationRoutes.grouped(
            uuidMiddleware
        ).delete(
            ":id",
            use: deleteSpecializationById
        ).openAPI(
            tags: .init(name: "Admin - Specialization"),
            summary: "Удалить специализацию для администратора.",
            description: "Удаляет специализацию по ID. Только для администраторов.",
            response: .type(HTTPStatus.self),
            auth: .bearer()
        )
    }
}

// MARK: - Routes Realization

extension SpecializationAdminController {
    @Sendable
    func getAllSpecializations(req: Request) async throws -> Response {
        return try await service.findAll().map {
            SpecializationDTO(from: $0)
        }.encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func getSpecializationById(req: Request) async throws -> Response {
        guard let specialization = try await service.find(
            id: try req.parameters.require(
                "id",
                as: UUID.self
            )
        ) else { throw SpecializationError.specializationNotFound }
        return try await SpecializationDTO(
            from: specialization
        ).encodeResponse(for: req)
    }

    @Sendable
    func getSpecializationByName(req: Request) async throws -> Response {
        guard let specialization = try await service.find(
            name: try req.parameters.require(
                "name",
                as: String.self
            )
        ) else { throw SpecializationError.specializationNotFound }
        return try await SpecializationDTO(
            from: specialization
        ).encodeResponse(for: req)
    }

    @Sendable
    func createSpecialization(req: Request) async throws -> Response {
        guard let spec = try await service.create(
            try req.content.decode(
                SpecializationCreateDTO.self
            )
        ) else {
            throw SpecializationError.invalidCreation
        }
        return try await SpecializationDTO(
            from: spec
        ).encodeResponse(for: req)
    }

    @Sendable
    func updateSpecializationById(req: Request) async throws -> Response {
        guard let spec = try await service.update(
            id: req.parameters.require(
                "id",
                as: UUID.self
            ),
            with: try req.content.decode(
                SpecializationUpdateDTO.self
            )
        ) else { throw SpecializationError.invalidUpdate }
        return try await SpecializationDTO(
            from: spec
        ).encodeResponse(for: req)
    }

    @Sendable
    func deleteSpecializationById(req: Request) async throws -> HTTPStatus {
        try await service.delete(
            id: try req.parameters.require(
                "id",
                as: UUID.self
            )
        )
        return .noContent
    }
}

extension SpecializationAdminController: @unchecked Sendable {}

