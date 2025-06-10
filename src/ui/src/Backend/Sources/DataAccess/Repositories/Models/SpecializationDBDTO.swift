//
//  SpecializationEntity.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Fluent
import Vapor
import Domain

public final class SpecializationDBDTO: Model {
    public static let schema = "Specialization"

    @ID(custom: "id")
    public var id: UUID?

    @Field(key: "name")
    public var name: String

    public init() {}
}

// MARK: - Convenience Initializator

extension SpecializationDBDTO {
    public convenience init(
        id: UUID? = nil,
        name: String
    ) {
        self.init()
        
        self.id = id
        self.name = name
    }
}

// MARK: - Sendable

extension SpecializationDBDTO: @unchecked Sendable {}

// MARK: - Content

extension SpecializationDBDTO: Content {}

// MARK: - From / To Model

extension SpecializationDBDTO {
    public convenience init(from specialization: Specialization) {
        self.init()
        
        self.id = specialization.id
        self.name = specialization.name
    }

    public func toSpecialization() -> Specialization? {
        guard let id = self.id else { return nil }

        return Specialization(
            id: id,
            name: name
        )
    }
}
