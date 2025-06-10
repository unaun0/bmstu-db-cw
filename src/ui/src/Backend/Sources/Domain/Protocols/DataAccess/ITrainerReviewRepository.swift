//
//  ITrainerReviewRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 26.05.2025.
//

import Foundation

public protocol ITrainerReviewRepository {
    func create(_ review: TrainerReview) async throws
    func update(_ review: TrainerReview) async throws
    func delete(id: UUID) async throws
    func find(id: UUID) async throws -> TrainerReview?
    func find(trainerId: UUID) async throws -> [TrainerReview]
    func find(userId: UUID) async throws -> [TrainerReview]
    func findAll() async throws -> [TrainerReview]
}
