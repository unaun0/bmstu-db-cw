//
//  IRedisRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 10.03.2025.
//

import Foundation
import Vapor

public protocol IRedisRepository {
    func set<T: Codable & Sendable>(
        key: String,
        value: T,
        expiration: TimeInterval?
    ) async throws

    func get<T: Codable & Sendable>(
        key: String,
        as type: T.Type
    ) async throws -> T?

    func delete(key: String) async throws
    func flushAll() async throws
}

extension TimeInterval {
    static func seconds(_ value: Int) -> TimeInterval {
        return TimeInterval(value)
    }
}
