//
//  SpecializationDTO.swift
//  Backend
//
//  Created by Цховребова Яна on 23.03.2025.
//

import Vapor

public struct SpecializationDTO: Content {
    public let id: UUID
    public let name: String

    public init(
        id: UUID,
        name: String
    ) {
        self.id = id
        self.name = name
    }
}

// MARK: - Init from Model

extension SpecializationDTO {
    public init(from specialization: Specialization) {
        self.id = specialization.id
        self.name = specialization.name
    }
}

// MARK: - Equatable

extension SpecializationDTO: Equatable {
    public static func == (
        lhs: SpecializationDTO,
        rhs: SpecializationDTO
    ) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
    }
}

// MARK: - Update

public struct SpecializationUpdateDTO: Content {
    public let name: String?
}

// MARK: - Create

public struct SpecializationCreateDTO: Content {
    public let name: String
}
