//
//  ITrainerAttendanceService.swift
//  Backend
//
//  Created by Цховребова Яна on 12.05.2025.
//

import Vapor

public final class TrainerAttendanceService: ITrainerAttendanceService {
    private let attendanceService: IAttendanceService
    private let trainingService: ITrainingService
    private let trainerService: ITrainerService

    public init(
        attendanceService: IAttendanceService,
        trainingService: ITrainingService,
        trainerService: ITrainerService
    ) {
        self.attendanceService = attendanceService
        self.trainingService = trainingService
        self.trainerService = trainerService
    }

    public func getAttendances(trainingId: UUID, userId: UUID) async throws -> [Attendance] {
        let trainer = try await getTrainer(by: userId)

        guard let training = try await trainingService.find(id: trainingId),
              training.trainerId == trainer.id else {
            throw AttendanceError.invalidTrainingId
        }

        return try await attendanceService.find(trainingId: trainingId)
    }

    public func updateStatus(attendanceId: UUID, userId: UUID, status: AttendanceStatus) async throws -> Attendance {
        let trainer = try await getTrainer(by: userId)
        guard let attendance = try await attendanceService.find(id: attendanceId) else {
            throw AttendanceError.attendanceNotFound
        }
        guard let training = try await trainingService.find(id: attendance.trainingId),
              training.trainerId == trainer.id else {
            throw AttendanceError.invalidTrainingId
        }

        let updateDTO = AttendanceUpdateDTO(
            membershipId: nil,
            trainingId: nil,
            status: status
        )

        guard let updated = try await attendanceService.update(id: attendanceId, with: updateDTO) else {
            throw AttendanceError.invalidUpdate
        }

        return updated
    }

    private func getTrainer(by userId: UUID) async throws -> Trainer {
        guard let trainer = try await trainerService.find(userId: userId) else {
            throw TrainerError.trainerNotFound
        }
        return trainer
    }
}

