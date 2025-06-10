//
//  ITrainerReviewService.swift
//  Backend
//
//  Created by Цховребова Яна on 26.05.2025.
//

import Foundation

public protocol ITrainerReviewService {
    func create(_ data: TrainerReviewCreateDTO) async throws -> TrainerReview
    func update(id: UUID, with data: TrainerReviewUpdateDTO) async throws -> TrainerReview
    func delete(id: UUID) async throws
    func find(id: UUID) async throws -> TrainerReview?
    func find(trainerId: UUID) async throws -> [TrainerReview]
    func find(userId: UUID) async throws -> [TrainerReview]
    func findAll() async throws -> [TrainerReview]
}
