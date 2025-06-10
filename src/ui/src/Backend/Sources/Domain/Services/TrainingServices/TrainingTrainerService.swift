//
//  TrainingTrainerService.swift
//  Backend
//
//  Created by Цховребова Яна on 11.05.2025.
//

import Fluent
import Vapor

public final class TrainingTrainerService {
    private let tService: ITrainingService
    private let sService: ISpecializationService
    private let rService: ITrainingRoomService
    private let trService: ITrainerService
    private let uService: IUserService

    public init(
        trainingService: ITrainingService,
        specService: ISpecializationService,
        roomService: ITrainingRoomService,
        trainerService: ITrainerService,
        userService: IUserService
    ) {
        self.tService = trainingService
        self.sService = specService
        self.rService = roomService
        self.trService = trainerService
        self.uService = userService
    }
}

// MARK: - ITrainingTrainerService

extension TrainingTrainerService: ITrainingTrainerService {
    public func findAllRooms() async throws -> [TrainingRoom] {
        try await rService.findAll()
    }
    
    public func create(userId: UUID, _ data: TrainingCreateDTO) async throws -> Training? {
        guard let trainer = try await trService.find(
            userId: userId
        ) else {
            throw TrainingError.invalidTrainer
        }
        guard data.trainerId == trainer.id else {
            throw TrainingError.invalidTrainer
        }
        return try await tService.create(data)
    }

    public func update(
        userId: UUID,
        trainingId: UUID,
        with data: TrainingUpdateDTO
    ) async throws -> Training? {
        guard let trainer = try await trService.find(
            userId: userId
        ) else {
            throw TrainingError.invalidTrainer
        }
        guard data.trainerId == trainer.id else {
            throw TrainingError.invalidTrainer
        }
        guard let training = try await tService.find(id: trainingId) else {
            throw TrainingError.trainingNotFound
        }
        guard training.trainerId == trainer.id else {
            throw TrainingError.invalidTrainer
        }
        guard training.date > Date() else {
            throw TrainingError.invalidData
        }
        return try await tService.update(id: trainingId, with: data)
    }

    public func delete(userId: UUID, trainingId: UUID) async throws {
        guard let trainer = try await trService.find(
            userId: userId
        ) else {
            throw TrainingError.invalidTrainer
        }
        guard let training = try await tService.find(id: trainingId) else {
            throw TrainingError.trainingNotFound
        }
        guard training.trainerId == trainer.id else {
            throw TrainingError.invalidTrainer
        }
        guard training.date > Date() else {
            throw TrainingError.invalidData
        }
        try await tService.delete(id: trainingId)
    }

    public func findAllTrainings(userId: UUID) async throws -> [TrainingInfoDTO] {
        guard let trainer = try await trService.find(
            userId: userId
        ) else {
            throw TrainingError.invalidTrainer
        }
        let allTrainings = try await tService.find(trainerId: trainer.id)
        var result: [TrainingInfoDTO] = []
        for training in allTrainings {
            async let trainer = trainer
            async let specialization = try sService.find(
                id: training.specializationId
            )
            async let room = try rService.find(id: training.roomId)

            guard
                let u = try await uService.find(id: userId),
                let s = try await specialization,
                let r = try await room
            else {
                throw TrainingError.trainingNotFound
            }

            let trainerDTO = await TrainerInfoDTO(
                id: trainer.id,
                userId: u.id,
                description: trainer.description,
                firstName: u.firstName,
                lastName: u.lastName
            )
            let specializationDTO = SpecializationDTO(
                id: s.id,
                name: s.name
            )
            let roomDTO = TrainingRoomDTO(
                id: r.id,
                name: r.name,
                capacity: r.capacity
            )
            let trainingDTO = TrainingInfoDTO(
                id: training.id,
                date: training.date,
                trainer: trainerDTO,
                specialization: specializationDTO,
                room: roomDTO
            )
            result.append(trainingDTO)
        }
        return result
    }

    public func findAvailableTrainings(userId: UUID) async throws
        -> [TrainingInfoDTO]
    {
        guard let trainer = try await trService.find(
            userId: userId
        ) else {
            throw TrainingError.invalidTrainer
        }
        let allTrainings = try await tService.find(trainerId: trainer.id)
        let now = Date()
        let futureTrainings = allTrainings.filter { $0.date > now }
        var result: [TrainingInfoDTO] = []
        for training in futureTrainings {
            async let specialization = try sService.find(
                id: training.specializationId
            )
            async let room = try rService.find(id: training.roomId)

            guard
                let u = try await uService.find(id: userId),
                let s = try await specialization,
                let r = try await room
            else {
                throw TrainingError.trainingNotFound
            }

            let trainerDTO = TrainerInfoDTO(
                id: trainer .id,
                userId: u.id,
                description: trainer.description,
                firstName: u.firstName,
                lastName: u.lastName
            )
            let specializationDTO = SpecializationDTO(
                id: s.id,
                name: s.name
            )
            let roomDTO = TrainingRoomDTO(
                id: r.id,
                name: r.name,
                capacity: r.capacity
            )
            let trainingDTO = TrainingInfoDTO(
                id: training.id,
                date: training.date,
                trainer: trainerDTO,
                specialization: specializationDTO,
                room: roomDTO
            )
            result.append(trainingDTO)
        }
        return result
    }
}
