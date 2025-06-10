//  TrainerSpecializationValidator.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.

import Foundation

public struct TrainerSpecializationValidator {
    public static func validate(years: Int) -> Bool {
        years >= 0
    }
}

