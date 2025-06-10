//
//  TrainerReviewError.swift
//  Backend
//
//  Created by Цховребова Яна on 26.05.2025.
//

import Vapor

public enum TrainerReviewError: Error {
    case reviewNotFound
    case invalidRating
    case invalidComment
    case invalidUserId
    case invalidTrainerId
    case duplicateReview
    case invalidCreation
    case invalidUpdate
}

extension TrainerReviewError: AbortError {
    public var status: HTTPStatus {
        switch self {
        case .reviewNotFound:
            return .notFound
        case .invalidRating, .invalidUserId, .invalidTrainerId:
            return .badRequest
        case .duplicateReview:
            return .conflict
        case .invalidCreation, .invalidUpdate, .invalidComment:
            return .badRequest
        }
    }

    public var reason: String {
        switch self {
        case .reviewNotFound:
            return "Отзыв не найден."
        case .invalidRating:
            return "Недопустимая оценка. Рейтинг должен быть в допустимом диапазоне."
        case .invalidUserId:
            return "Неверный идентификатор пользователя."
        case .invalidTrainerId:
            return "Неверный идентификатор тренера."
        case .duplicateReview:
            return "Пользователь уже оставил отзыв для этого тренера."
        case .invalidCreation:
            return "Ошибка при создании отзыва."
        case .invalidUpdate:
            return "Ошибка при обновлении отзыва."
        case .invalidComment:
            return "Неверный комментарий."
        }
    }
}
