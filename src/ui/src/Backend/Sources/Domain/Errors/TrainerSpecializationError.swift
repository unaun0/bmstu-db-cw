//
//  TrainerSpecializationError.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public enum TrainerSpecializationError: Error {
    case trainerSpecializationNotFound
    case trainerSpecializationNotUnique
    case invalidYears
    case invalidTrainer
    case invalidSpecialization
    case trainerNotFound
    case specializationNotFound
    case invalidCreation
    case invalidUpdate
}

extension TrainerSpecializationError: AbortError {
    public var status: HTTPStatus {
        switch self {
        case .trainerSpecializationNotFound:
            return .notFound
        case .trainerNotFound:
            return .notFound
        case .specializationNotFound:
            return .notFound
        case .invalidYears:
            return .badRequest
        case .invalidTrainer:
            return .badRequest
        case .invalidSpecialization:
            return .badRequest
        case .trainerSpecializationNotUnique:
            return .conflict
        case .invalidCreation:
            return .badRequest
        case .invalidUpdate:
            return .badRequest
        }
    }

    public var reason: String {
        switch self {
        case .trainerSpecializationNotUnique:
            return "Cпециализация уже есть у тренера"
        case .trainerSpecializationNotFound:
            return "Специализация тренера не найдена."
        case .invalidYears:
            return "Количество лет должно быть больше или равно 0."
        case .trainerNotFound:
            return "Тренер не найден."
        case .specializationNotFound:
            return "Специализация не найдена."
        case .invalidTrainer:
            return "Неверный идентификатор тренера."
        case .invalidSpecialization:
            return "Неверный идентификатор специализации."
        case .invalidCreation:
            return "Ошибка при создании специализации тренера."
        case .invalidUpdate:
            return "Ошибка при обновлении специализации тренера."
        }
    }
}
