//
//  SpecializationUserController.swift
//  Backend
//
//  Created by Цховребова Яна on 10.05.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class SpecializationUserController: RouteCollection {
    private let service: ISpecializationService
    private let jwtMiddleware: JWTMiddleware
    private let specNameMiddleware: SpecializationFindByNameValidationMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    
    public init(
        service: ISpecializationService,
        jwtMiddleware: JWTMiddleware,
        specNameMiddleware: SpecializationFindByNameValidationMiddleware,
        uuidMiddleware: UUIDValidationMiddleware
    ) {
        self.service = service
        self.jwtMiddleware = jwtMiddleware
        self.specNameMiddleware = specNameMiddleware
        self.uuidMiddleware = uuidMiddleware
    }
    
    public func boot(routes: RoutesBuilder) throws {
        let specializationRoutes = routes.grouped(
            "user", "specializations"
        ).grouped(jwtMiddleware)
        
        specializationRoutes.get(
            "all",
            use: getAllSpecializations
        ).openAPI(
            tags: .init(name: "User - Specialization"),
            summary: "Получить все специализацииа.",
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
            tags: .init(name: "User - Specialization"),
            summary: "Получить специализацию по ID.",
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
            tags: .init(name: "User - Specialization"),
            summary: "Получить специализацию по названию.",
            description: "Возвращает специализацию по имени.",
            response: .type(SpecializationDTO.self),
            auth: .bearer()
        )
    }
}

// MARK: - Routes Realization

extension SpecializationUserController {
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
}

extension SpecializationUserController: @unchecked Sendable {}

