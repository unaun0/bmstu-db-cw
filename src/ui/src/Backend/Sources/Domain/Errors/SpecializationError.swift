//
//  SpecializationError.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public enum SpecializationError: Error {
    case specializationNotFound
    case invalidName
    case nameAlreadyExists
    case invalidCreation
    case invalidUpdate
}

extension SpecializationError: AbortError {
    public var status: HTTPStatus {
        switch self {
        case .specializationNotFound:
            return .notFound
        case .invalidName:
            return .badRequest
        case .nameAlreadyExists:
            return .conflict
        case .invalidCreation, .invalidUpdate:
            return .badRequest
        }
    }
    
    public var reason: String {
        switch self {
        case .specializationNotFound:
            return "Специализация не найдена."
        case .invalidName:
            return "Неверное имя специализации."
        case .nameAlreadyExists:
            return "Специализация с таким именем уже существует."
        case .invalidCreation:
            return "Ошибка при создании специализации."
        case .invalidUpdate:
            return "Ошибка при обновлении специализации."
            
        }
    }
}
