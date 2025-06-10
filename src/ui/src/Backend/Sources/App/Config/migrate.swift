//
//  migrate.swift
//  Backend
//
//  Created by Цховребова Яна on 29.05.2025.
//

import Vapor
import Fluent
import DataAccess
import Domain

func migrateAll(app: Application) async throws {
    try await migrateUsers(app: app)
    try await migrateTrainers(app: app)
    try await migrateSpecializations(app: app)
    try await migrateTrainerSpecializations(app: app)
    try await migrateTrainerReviews(app: app)
    try await migrateMembershipTypes(app: app)
    try await migrateMemberships(app: app)
    try await migratePayments(app: app)
    try await migrateTrainings(app: app)
}

// MARK: - Individual Migrations

func migrateUsers(app: Application) async throws {
    let postgres = app.postgres
    let mongo = app.mongo

    let pgModels = try await UserDBDTO.query(on: postgres).all()

    for pg in pgModels {
        guard let domain = pg.toUser() else { continue }
        let mongoModel = UserMongoDBDTO(from: domain)
        try await mongoModel.create(on: mongo)
    }

    app.logger.info("✅ Migrated \(pgModels.count) users")
}

func migrateTrainers(app: Application) async throws {
    let postgres = app.postgres
    let mongo = app.mongo

    let pgModels = try await TrainerDBDTO.query(on: postgres).all()

    for pg in pgModels {
        guard let domain = pg.toTrainer() else { continue }
        let mongoModel = TrainerMongoDBDTO(from: domain)
        try await mongoModel.create(on: mongo)
    }

    app.logger.info("✅ Migrated \(pgModels.count) trainers")
}

func migrateSpecializations(app: Application) async throws {
    let postgres = app.postgres
    let mongo = app.mongo

    let pgModels = try await SpecializationDBDTO.query(on: postgres).all()

    for pg in pgModels {
        guard let domain = pg.toSpecialization() else { continue }
        let mongoModel = SpecializationMongoDBDTO(from: domain)
        try await mongoModel.create(on: mongo)
    }

    app.logger.info("✅ Migrated \(pgModels.count) specializations")
}

func migrateTrainerSpecializations(app: Application) async throws {
    let postgres = app.postgres
    let mongo = app.mongo
    
    let pgModels = try await TrainerSpecializationDBDTO.query(on: postgres).all()

    for pg in pgModels {
        guard let domain = pg.toTrainerSpecialization() else { continue }
        let mongoModel = TrainerSpecializationMongoDBDTO(from: domain)
        try await mongoModel.create(on: mongo)
    }

    app.logger.info("✅ Migrated \(pgModels.count) trainer-specializations")
}

func migrateTrainerReviews(app: Application) async throws {
    let postgres = app.postgres
    let mongo = app.mongo

    let pgModels = try await TrainerReviewDBDTO.query(on: postgres).all()

    for pg in pgModels {
        guard let domain = pg.toTrainerReview() else { continue }
        let mongoModel = TrainerReviewMongoDBDTO(from: domain)
        try await mongoModel.create(on: mongo)
    }

    app.logger.info("✅ Migrated \(pgModels.count) trainer-reviews")
}

func migrateMembershipTypes(app: Application) async throws {
    let postgres = app.postgres
    let mongo = app.mongo

    let pgModels = try await MembershipTypeDBDTO.query(on: postgres).all()

    for pg in pgModels {
        guard let domain = pg.toMembershipType() else { continue }
        let mongoModel = MembershipTypeMongoDBDTO(from: domain)
        try await mongoModel.create(on: mongo)
    }

    app.logger.info("✅ Migrated \(pgModels.count) membership types")
}

func migrateMemberships(app: Application) async throws {
    let postgres = app.postgres
    let mongo = app.mongo
    
    let pgModels = try await MembershipDBDTO.query(on: postgres).all()

    for pg in pgModels {
        guard let domain = pg.toMembership() else { continue }
        let mongoModel = MembershipMongoDBDTO(from: domain)
        try await mongoModel.create(on: mongo)
    }

    app.logger.info("✅ Migrated \(pgModels.count) memberships")
}

func migratePayments(app: Application) async throws {
    let postgres = app.postgres
    let mongo = app.mongo

    let pgModels = try await PaymentDBDTO.query(on: postgres).all()

    for pg in pgModels {
        guard let domain = pg.toPayment() else { continue }
        let mongoModel = PaymentMongoDBDTO(from: domain)
        try await mongoModel.create(on: mongo)
    }

    app.logger.info("✅ Migrated \(pgModels.count) payments")
}

func migrateTrainings(app: Application) async throws {
    let postgres = app.postgres
    let mongo = app.mongo

    let pgModels = try await TrainingDBDTO.query(on: postgres).all()

    for pg in pgModels {
        guard let domain = pg.toTraining() else { continue }
        let mongoModel = TrainingMongoDBDTO(from: domain)
        try await mongoModel.create(on: mongo)
    }

    app.logger.info("✅ Migrated \(pgModels.count) trainings")
}
