//
//  ValidationRegex.swift
//  Backend
//
//  Created by Цховребова Яна on 29.03.2025.
//

import Foundation

public enum ValidationRegex {
    public enum Email {
        public static let regex: String = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
    }

    public enum PhoneNumber {
        public static let regex: String = "^\\+[0-9]{10,15}$"
    }

    public enum Name {
        public static let regex: String = #"^[a-zA-Zа-яА-ЯёЁ]+(-[a-zA-Zа-яА-ЯёЁ]+)?$"#
    }

    public enum Gender {
        public static let regex: String = "^(мужской|женский)$"
    }

    public enum Password {
        public static let regex: String = #"^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W).{8,}$"#
    }

    public enum Transaction {
        public static let regex: String = "^[A-Za-z0-9]{4,256}$"
    }

    public enum DateFormat {
        public static let format: String = "yyyy-MM-dd HH:mm:ss"
    }

    public enum TimeFormat {
        public static let format: String = "HH:mm:ss"
    }
}

public func isValidRegex(_ value: String, regex: String) -> Bool {
    let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
    return predicate.evaluate(with: value)
}
