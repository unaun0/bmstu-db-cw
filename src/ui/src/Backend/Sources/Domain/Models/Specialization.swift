//
//  Specialization.swift
//  Backend
//
//  Created by Цховребова Яна on 12.03.2025.
//

import Vapor

// MARK: - Specialization

public final class Specialization: BaseModel {
    public var id: UUID
    public var name: String

    public init(
        id: UUID = UUID(),
        name: String
    ) {
        self.id = id
        self.name = name
    }
}

// MARK: - Specialization Equatable

extension Specialization: Equatable {
    public static func == (lhs: Specialization, rhs: Specialization) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
    }
}

// MARK: - Specialization Sendable

extension Specialization: @unchecked Sendable {}
