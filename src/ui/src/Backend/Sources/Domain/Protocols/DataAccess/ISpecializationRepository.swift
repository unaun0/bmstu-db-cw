//
//  ISpecializationRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public protocol ISpecializationRepository: Sendable {
    func create(_ specialization: Specialization) async throws
    func update(_ specialization: Specialization) async throws
    func delete(id: UUID) async throws
    func find(id: UUID) async throws -> Specialization?
    func find(name: String) async throws -> Specialization?
    func findAll() async throws -> [Specialization]
}
