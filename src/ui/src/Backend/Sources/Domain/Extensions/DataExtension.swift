//
//  DataExtension.swift
//  Backend
//
//  Created by Цховребова Яна on 29.03.2025.
//

import Foundation

extension Date {
    public func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        return formatter.string(from: self)
    }
}
