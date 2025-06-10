//
//  ISpecializationService.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public protocol ISpecializationService: Sendable {
    func create(_ data: SpecializationCreateDTO) async throws -> Specialization?
    func update(id: UUID, with data: SpecializationUpdateDTO) async throws -> Specialization?
    func find(id: UUID) async throws -> Specialization?
    func find(name: String) async throws -> Specialization?
    func findAll() async throws -> [Specialization]
    func delete(id: UUID) async throws
}
