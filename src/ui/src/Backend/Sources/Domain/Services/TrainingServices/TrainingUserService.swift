//
//  TrainingUserService.swift
//  Backend
//
//  Created by Цховребова Яна on 10.05.2025.
//

import Fluent
import Vapor

public final class TrainingUserService {
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

// MARK: - ITrainingUserService

extension TrainingUserService: ITrainingUserService {
    public func findAvailableTrainings() async throws -> [TrainingInfoDTO] {
        let allTrainings = try await tService.findAll()
        let now = Date()
        let futureTrainings = allTrainings.filter { $0.date > now }

        var result: [TrainingInfoDTO] = []

        for training in futureTrainings {
            async let trainer = try trService.find(id: training.trainerId)
            async let specialization = try sService.find(
                id: training.specializationId
            )
            async let room = try rService.find(id: training.roomId)
            
            guard
                let t = try await trainer,
                let u = try await uService.find(id: t.userId),
                let s = try await specialization,
                let r = try await room
            else {
                throw TrainingError.trainingNotFound
            }

            let trainerDTO = TrainerInfoDTO(
                id: t.id,
                userId: u.id,
                description: t.description,
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
