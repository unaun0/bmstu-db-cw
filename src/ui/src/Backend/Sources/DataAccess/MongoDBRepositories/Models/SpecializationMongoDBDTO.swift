//
//  SpecializationMongoDBDTO.swift
//  Backend
//
//  Created by Цховребова Яна on 29.05.2025.
//

import Fluent
import Vapor
import Domain

public final class SpecializationMongoDBDTO: Model {
    public static let schema = "Specialization"

    @ID(custom: "_id")
    public var id: UUID?

    @Field(key: "name")
    public var name: String

    public init() {}
}

// MARK: - Convenience Initializator

extension SpecializationMongoDBDTO {
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

extension SpecializationMongoDBDTO: @unchecked Sendable {}

// MARK: - Content

extension SpecializationMongoDBDTO: Content {}

// MARK: - From / To Model

extension SpecializationMongoDBDTO {
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
