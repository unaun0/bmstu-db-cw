//
//  UserTrainerReviewController.swift
//  Backend
//
//  Created by Цховребова Яна on 26.05.2025.
//

import Domain
import Vapor
import VaporToOpenAPI

public final class UserTrainerReviewController: RouteCollection {
    private let trainerReviewService: ITrainerReviewService
    private let jwtMiddleware: JWTMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    private let createValidationMiddleware:
        TrainerReviewCreateValidationMiddleware
    private let updateValidationMiddleware: TrainerReviewValidationMiddleware

    public init(
        trainerReviewService: ITrainerReviewService,
        jwtMiddleware: JWTMiddleware,
        uuidMiddleware: UUIDValidationMiddleware,
        createValidationMiddleware: TrainerReviewCreateValidationMiddleware,
        updateValidationMiddleware: TrainerReviewValidationMiddleware
    ) {
        self.trainerReviewService = trainerReviewService
        self.jwtMiddleware = jwtMiddleware
        self.uuidMiddleware = uuidMiddleware
        self.createValidationMiddleware = createValidationMiddleware
        self.updateValidationMiddleware = updateValidationMiddleware
    }

    public func boot(routes: RoutesBuilder) throws {
        let reviewsRoutes =
            routes
            .grouped("user", "trainer-reviews")
            .grouped(jwtMiddleware)
        reviewsRoutes.get(
            "my",
            use: getMyReviews
        ).openAPI(
            tags: .init(name: "User - TrainerReview"),
            summary: "Получить отзывы текущего пользователя",
            description:
                "Возвращает все отзывы, которые оставил текущий пользователь.",
            response: .type([TrainerReviewDTO].self),
            auth: .bearer()
        )
        reviewsRoutes.get(
            "trainer",
            ":trainer-id",
            use: getReviewsByTrainer
        ).openAPI(
            tags: .init(name: "User - TrainerReview"),
            summary: "Получить отзывы по тренеру",
            description: "Возвращает все отзывы для указанного тренера.",
            response: .type([TrainerReviewDTO].self),
            auth: .bearer()
        )
        reviewsRoutes.grouped(createValidationMiddleware).post(
            use: createReview
        ).openAPI(
            tags: .init(name: "User - TrainerReview"),
            summary: "Создать отзыв о тренере",
            description: "Создает новый отзыв текущего пользователя.",
            body: .type(TrainerReviewCreateDTO.self),
            response: .type(TrainerReviewDTO.self),
            auth: .bearer()
        )
        reviewsRoutes.grouped(
            uuidMiddleware,
            updateValidationMiddleware
        ).put(
            ":id", use: updateReview
        ).openAPI(
            tags: .init(name: "User - TrainerReview"),
            summary: "Обновить отзыв",
            description:
                "Обновляет отзыв текущего пользователя по идентификатору.",
            body: .type(TrainerReviewUpdateDTO.self),
            response: .type(TrainerReviewDTO.self),
            auth: .bearer()
        )
        reviewsRoutes.grouped(uuidMiddleware).delete(
            ":id", use: deleteReview
        ).openAPI(
            tags: .init(name: "User - TrainerReview"),
            summary: "Удалить отзыв",
            description:
                "Удаляет отзыв текущего пользователя по идентификатору.",
            response: .type(HTTPStatus.self),
            auth: .bearer()
        )
    }
}

extension UserTrainerReviewController {
    @Sendable
    func getMyReviews(req: Request) async throws -> Response {
        let userId = try req.auth.require(User.self).id
        let reviews = try await trainerReviewService.find(userId: userId)
        let dtos = reviews.map(TrainerReviewDTO.init(from:))
        return try await dtos.encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func getReviewsByTrainer(req: Request) async throws -> Response {
        let trainerId = try req.parameters.require("trainer-id", as: UUID.self)
        let reviews = try await trainerReviewService.find(trainerId: trainerId)
        let dtos = reviews.map(TrainerReviewDTO.init(from:))
        return try await dtos.encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func createReview(req: Request) async throws -> Response {
        let user = try req.auth.require(User.self)
        var dto = try req.content.decode(TrainerReviewCreateDTO.self)
        if (dto.userId != user.id) {
            throw Abort(
                .forbidden,
                reason: "You are not allowed to сreate this review"
            )
        }
        let review = try await trainerReviewService.create(dto)
        return try await TrainerReviewDTO(from: review).encodeResponse(
            status: .created, for: req)
    }

    @Sendable
    func updateReview(req: Request) async throws -> Response {
        let user = try req.auth.require(User.self)
        let reviewId = try req.parameters.require("id", as: UUID.self)
        let updateDTO = try req.content.decode(TrainerReviewUpdateDTO.self)
        guard
            let existingReview = try await trainerReviewService.find(
                id: reviewId
            )
        else {
            throw Abort(.notFound, reason: "Review not found")
        }
        guard existingReview.userId == user.id else {
            throw Abort(
                .forbidden,
                reason: "You are not allowed to update this review"
            )
        }

        let updatedReview = try await trainerReviewService.update(
            id: reviewId, with: updateDTO)
        return try await TrainerReviewDTO(from: updatedReview).encodeResponse(
            status: .ok, for: req)
    }

    @Sendable
    func deleteReview(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let reviewId = try req.parameters.require("id", as: UUID.self)

        guard
            let existingReview = try await trainerReviewService.find(
                id: reviewId)
        else {
            throw Abort(.notFound, reason: "Review not found")
        }
        guard existingReview.userId == user.id else {
            throw Abort(
                .forbidden, 
                reason: "You are not allowed to delete this review"
            )
        }

        try await trainerReviewService.delete(id: reviewId)
        return .noContent
    }
}

extension UserTrainerReviewController: @unchecked Sendable {}
