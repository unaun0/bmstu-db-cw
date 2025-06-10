//
//  PaymentValidator.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Foundation

public struct PaymentValidator {
    public static func validate(transactionId: String) -> Bool {
        isValidRegex(
            transactionId,
            regex: ValidationRegex.Transaction.regex
        )
    }
    
    public static func validate(gateway: String) -> Bool {
        PaymentGateway(rawValue: gateway) != nil
    }
    
    public static func validate(status: String) -> Bool {
        PaymentStatus(rawValue: status) != nil
    }
    
    public static func validate(method: String) -> Bool {
        PaymentMethod(rawValue: method) != nil
    }
    
    public static func validate(date: Date) -> Bool {
        date >= Calendar.current.startOfDay(for: Date())
    }
}
