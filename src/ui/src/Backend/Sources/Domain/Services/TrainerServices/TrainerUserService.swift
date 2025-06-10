//
//  TrainerUserService.swift
//  Backend
//
//  Created by Цховребова Яна on 10.05.2025.
//

import Vapor

public final class TrainerUserService {
    private let tService: ITrainerService
    private let uService: IUserService
    
    public init(
        trainerService: ITrainerService,
        userService: IUserService
    ) {
        self.tService = trainerService
        self.uService = userService
    }
}

// MARK: - ITrainerUserService

extension TrainerUserService: ITrainerUserService {
    public func findTrainer(byID id: UUID) async throws -> (Trainer?, User?) {
        let trainer = try await tService.find(id: id)
        var user: User? = nil
        if let userId = trainer?.userId {
            user = try await uService.find(id: userId)
        }
        return (trainer, user)
    }
    
    public func findTrainer(byUserID userID: UUID) async throws -> (Trainer?, User?) {
        let trainer = try await tService.find(userId: userID)
        var user: User? = nil
        if trainer != nil {
            user = try await uService.find(id: userID)
        }
        return (trainer, user)
    }
}

public final class TrainerSelfService {
    private let tService: ITrainerService
    private let tsService: ITrainerSpecializationService
    
    public init(
        trainerService: ITrainerService,
        trainerSpecializationService: ITrainerSpecializationService
    ) {
        self.tService = trainerService
        self.tsService = trainerSpecializationService
    }
}

// MARK: - ITrainerSelfService

extension TrainerSelfService: ITrainerSelfService {
    public func getProfile(userId: UUID) async throws -> Trainer? {
        try await tService.find(userId: userId)
    }
    
    public func getProfileSpecializations(
        userId: UUID
    ) async throws -> [TrainerSpecialization] {
        guard let trainer = try await self.getProfile(userId: userId) else {
            throw TrainerError.trainerNotFound
        }
        return try await tsService.find(trainerId: trainer.id)
    }
}
