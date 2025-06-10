//
//  SpecializationValidator.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Foundation

public struct SpecializationValidator {
    public static let maxNameLength = 256

    public static func validate(name: String) -> Bool {
        (!name.isEmpty) && (name.count < maxNameLength)
    }
}
