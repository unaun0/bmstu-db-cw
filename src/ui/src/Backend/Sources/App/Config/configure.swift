import API
import DataAccess
@preconcurrency import Domain
import Fluent
import FluentPostgresDriver
import FluentMongoDriver
import NIOSSL
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // files from /Public folder
    let dbConfig = app.appConfig.databaseConfig(for: app.environment)

    app.middleware.use(
        FileMiddleware(
            publicDirectory: app.directory.publicDirectory
        )
    )
    let usePostgres = true
    
    app.databases.use(
        DatabaseConfigurationFactory.postgres(
            configuration: .init(
                hostname: dbConfig.hostname,
                port: dbConfig.port,
                username: dbConfig.username,
                password: dbConfig.password,
                database: dbConfig.databaseName,
                tls: .prefer(try .init(configuration: .clientDefault)))
        ), as: .psql
    )
    
// app.databases.use(try .mongo(connectionString: "mongodb://localhost:27017/fitapp"), as: .mongo)
// app.databases.default(to: .mongo)
//  Миграции для MongoDB
//    do {
//        try await migrateAll(app: app)
//        app.logger.info("Data migration completed.")
//    } catch {
//        app.logger.error("Migration failed: \(error.localizedDescription)")
//        throw error
//    }

    app.jwt.signers.use(
        .hs256(key: app.appConfig.jwt.secretKey)
    )
    
    if usePostgres {
        configureRepositories(app)
    } else {
        configureMongoRepositories(app)
    }
    configureServices(app, config: app.appConfig)
    configureJWTSecretKey(app, config: app.appConfig)
    configureMiddlewares(app)
    
    try routes(app)
}

extension Application {
    var mongo: Database {
        self.databases.database(.mongo, logger: self.logger, on: self.eventLoopGroup.next())!
    }
    
    var postgres: Database {
        self.databases.database(.psql, logger: self.logger, on: self.eventLoopGroup.next())!
    }
}

// MARK: - Configure JWT SecretKey

private func configureJWTSecretKey(_ app: Application, config: AppConfig) {
    app.jwt.signers.use(
        .hs256(key: config.jwt.secretKey)
    )
}

// MARK: - Configure Repositories

private func configureMongoRepositories(_ app: Application) {
    app.userRepository = UserMongoDBRepository(db: app.mongo)
    app.trainerRepository = TrainerMongoDBRepository(db: app.mongo)
    app.specializationRepository = SpecializationMongoDBRepository(db: app.mongo)
    app.membershipTypeRepository = MembershipTypeMongoDBRepository(db: app.mongo)
    app.trainingRoomRepository = TrainingRoomMongoDBRepository(db: app.mongo)
    app.trainerSpecializationRepository = TrainerSpecializationMongoDBRepository(db: app.mongo)
    app.trainingRepository = TrainingMongoDBRepository(db: app.mongo)
    app.trainerReviewRepository = TrainerReviewMongoDBRepository(db: app.mongo)
    app.paymentRepository = PaymentMongoDBRepository(db: app.postgres)
    app.membershipRepository = MembershipMongoDBRepository(db: app.mongo)
    app.attendanceRepository = AttendanceMongoDBRepository(db: app.mongo)
}

private func configureRepositories(_ app: Application) {
     app.userRepository = UserRepository(db: app.postgres)
     app.trainerRepository = TrainerRepository(db: app.postgres)
     app.specializationRepository = SpecializationRepository(db: app.postgres)
     app.membershipTypeRepository = MembershipTypeRepository(db: app.postgres)
     app.trainingRoomRepository = TrainingRoomRepository(db: app.postgres)
     app.trainerSpecializationRepository = TrainerSpecializationRepository(db: app.postgres)
     app.trainerReviewRepository = TrainerReviewRepository(db: app.postgres)
     app.trainingRepository = TrainingRepository(db: app.postgres)
     app.paymentRepository = PaymentRepository(db: app.postgres)
     app.membershipRepository = MembershipRepository(db: app.postgres)
     app.attendanceRepository = AttendanceRepository(db: app.postgres)
}
// MARK: - Configure Services

private func configureServices(_ app: Application, config: AppConfig) {
    app.hasherService = BcryptHasherService()
    app.jwtService = JWTService(
        expirationTime: TimeInterval(
            config.jwt.expirationTime
        )
    )
    app.userService = UserService(
        userRepository: app.userRepository!,
        passwordHasher: app.hasherService!
    )
    app.authService = AuthService(
        userService: app.userService!,
        passwordHasher: app.hasherService!
    )
    app.userSelfService = UserSelfService(
        userService: app.userService!
    )
    app.userTrainerService = UserTrainerService(
        userService: app.userService!
    )
    app.trainerService = TrainerService(
        repository: app.trainerRepository!
    )
    app.trainerUserService = TrainerUserService(
        trainerService: app.trainerService!,
        userService: app.userService!
    )
    app.specializationService = SpecializationService(
        repository: app.specializationRepository!
    )
    app.trainerSpecializationService = TrainerSpecializationService(
        repository: app.trainerSpecializationRepository!
    )
    app.trainerSelfService = TrainerSelfService(
        trainerService: app.trainerService!,
        trainerSpecializationService: app.trainerSpecializationService!
    )
    app.trainingRoomService = TrainingRoomService(
        repository: app.trainingRoomRepository!
    )
    app.trainingService = TrainingService(
        repository: app.trainingRepository!
    )
    app.trainingUserService = TrainingUserService(
        trainingService: app.trainingService!,
        specService: app.specializationService!,
        roomService: app.trainingRoomService!,
        trainerService: app.trainerService!,
        userService: app.userService!
    )
    app.trainingTrainerService = TrainingTrainerService(
        trainingService: app.trainingService!,
        specService: app.specializationService!,
        roomService: app.trainingRoomService!,
        trainerService: app.trainerService!,
        userService: app.userService!
    )
    app.membershipTypeService = MembershipTypeService(
        repository: app.membershipTypeRepository!
    )
    app.paymentService = PaymentService(
        repository: app.paymentRepository!
    )
    app.membershipService = MembershipService(
        membershipRepository: app.membershipRepository!,
        membershipTypeService: app.membershipTypeService!
    )
    app.membershipPurchaseService = MembershipPurchaseService(
        membershipService: app.membershipService!,
        membershipTypeService: app.membershipTypeService!,
        paymentService: app.paymentService!
    )
    app.attendanceService = AttendanceService(
        repository: app.attendanceRepository!
    )
    app.trainerAttendanceService = TrainerAttendanceService(
        attendanceService: app.attendanceService!,
        trainingService: app.trainingService!,
        trainerService: app.trainerService!
    )
    app.userAttendanceService = UserAttendanceService(
        attendanceService: app.attendanceService!,
        membershipService: app.membershipService!,
        trainingService: app.trainingService!
    )
    app.trainerReviewService = TrainerReviewService(
        repository: app.trainerReviewRepository!
    )
}

private func configureMiddlewares(_ app: Application) {
    app.jwtMiddleware = JWTMiddleware(userService: app.userService!)
    app.loginValidationMiddleware = LoginValidationMiddleware()
    app.registerValidationMiddleware = RegisterValidationMiddleware()
    app.userValidationMiddleware = UserValidationMiddleware()
    app.uuidValidationMiddleware = UUIDValidationMiddleware()
    app.userEmailValidationMiddleware = UserEmailValidationMiddleware()
    app.userPhoneNumberValidationMiddleware =
        UserPhoneNumberValidationMiddleware()
    app.adminRoleMiddleware = AdminRoleMiddleware()
    app.trainerRoleMiddleware = TrainerRoleMiddleware()
    app.adminOrTrainerRoleMiddleware = AdminOrTrainerRoleMiddleware(
        adminMiddleware: app.adminRoleMiddleware!,
        trainerMiddleware: app.trainerRoleMiddleware!
    )
    app.userRoleNameValidationMiddleware = UserRoleNameValidationMiddleware()
    app.userCreateValidationMiddleware = UserCreateValidationMiddleware()
    app.trainerValidationMiddleware = TrainerValidationMiddleware()
    app.trainerCreateValidationMiddleware = TrainerCreateValidationMiddleware()
    app.specializationValidationMiddleware =
        SpecializationValidationMiddleware()
    app.specializationCreateValidationMiddleware =
        SpecializationCreateValidationMiddleware()
    app.specializationFindByNameValidationMiddleware =
        SpecializationFindByNameValidationMiddleware()
    app.trainerSpecializationValidationMiddleware =
        TrainerSpecializationValidationMiddleware()
    app.trainerSpecializationCreateValidationMiddleware =
        TrainerSpecializationCreateValidationMiddleware()
    app.trainingRoomValidationMiddleware = TrainingRoomValidationMiddleware()
    app.trainingRoomCreateValidationMiddleware =
        TrainingRoomCreateValidationMiddleware()
    app.trainingRoomFindByNameValidationMiddleware =
        TrainingRoomFindByNameValidationMiddleware()
    app.trainingRoomFindByCapacityValidationMiddleware =
        TrainingRoomFindByCapacityValidationMiddleware()
    app.trainingCreateValidationMiddleware =
        TrainingCreateValidationMiddleware()
    app.trainingValidationMiddleware = TrainingValidationMiddleware()
    app.membershipTypeCreateValidationMiddleware =
        MembershipTypeCreateValidationMiddleware()
    app.membershipTypeFindByNameValidationMiddleware =
        MembershipTypeFindByNameValidationMiddleware()
    app.membershipTypeValidationMiddleware =
        MembershipTypeValidationMiddleware()
    app.paymentValidationMiddleware = PaymentValidationMiddleware()
    app.paymentCreateValidationMiddleware = PaymentCreateValidationMiddleware()
    app.membershipCreateValidationMiddleware = .init()
    app.membershipValidationMiddleware = .init()
    app.membershipPurchaseValidationMiddleware =
        MembershipPurchaseValidationMiddleware()
    app.attendanceCreateValidationMiddleware =
        AttendanceCreateValidationMiddleware()
    app.attendanceValidationMiddleware = AttendanceValidationMiddleware()
    app.trainerReviewValidationMiddleware = TrainerReviewValidationMiddleware()
    app.trainerReviewCreateValidationMiddleware =
        TrainerReviewCreateValidationMiddleware()
}

// MARK: - TrainerReview Repository

extension Application {
    private struct TrainerReviewRepositoryKey: StorageKey {
        typealias Value = ITrainerReviewRepository
    }
    var trainerReviewRepository: ITrainerReviewRepository? {
        get { self.storage[TrainerReviewRepositoryKey.self] }
        set { self.storage[TrainerReviewRepositoryKey.self] = newValue }
    }
}

// MARK: - TrainerReview Service

extension Application {
    private struct TrainerReviewServiceKey: StorageKey {
        typealias Value = ITrainerReviewService
    }
    var trainerReviewService: ITrainerReviewService? {
        get { self.storage[TrainerReviewServiceKey.self] }
        set { self.storage[TrainerReviewServiceKey.self] = newValue }
    }
}

// MARK: - TrainerReview Validation Middleware

extension Application {
    private struct TrainerReviewValidationMiddlewareKey: StorageKey {
        typealias Value = TrainerReviewValidationMiddleware
    }
    var trainerReviewValidationMiddleware: TrainerReviewValidationMiddleware? {
        get { self.storage[TrainerReviewValidationMiddlewareKey.self] }
        set {
            self.storage[TrainerReviewValidationMiddlewareKey.self] = newValue
        }
    }
}

// MARK: - User Repository

extension Application {
    private struct UserRepositoryKey: StorageKey {
        typealias Value = IUserRepository
    }
    var userRepository: IUserRepository? {
        get { self.storage[UserRepositoryKey.self] }
        set { self.storage[UserRepositoryKey.self] = newValue }
    }
}

// MARK: - TrainerReview Create Validation Middleware

extension Application {
    private struct TrainerReviewCreateValidationMiddlewareKey: StorageKey {
        typealias Value = TrainerReviewCreateValidationMiddleware
    }
    var trainerReviewCreateValidationMiddleware:
        TrainerReviewCreateValidationMiddleware?
    {
        get { self.storage[TrainerReviewCreateValidationMiddlewareKey.self] }
        set {
            self.storage[TrainerReviewCreateValidationMiddlewareKey.self] =
                newValue
        }
    }
}

// MARK: - Attendance Repository

extension Application {
    private struct AttendanceRepositoryKey: StorageKey {
        typealias Value = IAttendanceRepository
    }
    var attendanceRepository: IAttendanceRepository? {
        get { self.storage[AttendanceRepositoryKey.self] }
        set { self.storage[AttendanceRepositoryKey.self] = newValue }
    }
}

// MARK: - Membership Repository

extension Application {
    private struct MembershipRepositoryKey: StorageKey {
        typealias Value = IMembershipRepository
    }
    var membershipRepository: IMembershipRepository? {
        get { self.storage[MembershipRepositoryKey.self] }
        set { self.storage[MembershipRepositoryKey.self] = newValue }
    }
}

// MARK: - Trainer Repository

extension Application {
    private struct TrainerRepositoryKey: StorageKey {
        typealias Value = ITrainerRepository
    }
    var trainerRepository: ITrainerRepository? {
        get { self.storage[TrainerRepositoryKey.self] }
        set { self.storage[TrainerRepositoryKey.self] = newValue }
    }
}

// MARK: - Membership Create Validation Middleware

extension Application {
    private struct MembershipCreateValidationMiddlewareKey: StorageKey {
        typealias Value = MembershipCreateValidationMiddleware
    }

    var membershipCreateValidationMiddleware:
        MembershipCreateValidationMiddleware?
    {
        get {
            self.storage[MembershipCreateValidationMiddlewareKey.self]
        }
        set {
            self.storage[MembershipCreateValidationMiddlewareKey.self] =
                newValue
        }
    }
}

// MARK: - Membership Validation Middleware

extension Application {
    private struct MembershipValidationMiddlewareKey: StorageKey {
        typealias Value = MembershipValidationMiddleware
    }

    var membershipValidationMiddleware: MembershipValidationMiddleware? {
        get {
            self.storage[MembershipValidationMiddlewareKey.self]
        }
        set {
            self.storage[MembershipValidationMiddlewareKey.self] = newValue
        }
    }
}

// MARK: - Payment Repository

extension Application {
    private struct PaymentRepositoryKey: StorageKey {
        typealias Value = IPaymentRepository
    }
    var paymentRepository: IPaymentRepository? {
        get { self.storage[PaymentRepositoryKey.self] }
        set { self.storage[PaymentRepositoryKey.self] = newValue }
    }
}

// MARK: - Specialization Repository

extension Application {
    private struct SpecializationRepositoryKey: StorageKey {
        typealias Value = ISpecializationRepository
    }
    var specializationRepository: ISpecializationRepository? {
        get { self.storage[SpecializationRepositoryKey.self] }
        set { self.storage[SpecializationRepositoryKey.self] = newValue }
    }
}

// MARK: - TrainingRoom Repository

extension Application {
    private struct TrainingRoomRepositoryKey: StorageKey {
        typealias Value = ITrainingRoomRepository
    }
    var trainingRoomRepository: ITrainingRoomRepository? {
        get { self.storage[TrainingRoomRepositoryKey.self] }
        set { self.storage[TrainingRoomRepositoryKey.self] = newValue }
    }
}

// MARK: - Training Repository

extension Application {
    private struct TrainingRepositoryKey: StorageKey {
        typealias Value = ITrainingRepository
    }
    var trainingRepository: ITrainingRepository? {
        get { self.storage[TrainingRepositoryKey.self] }
        set { self.storage[TrainingRepositoryKey.self] = newValue }
    }
}

// MARK: - MembershipType Repository

extension Application {
    private struct MembershipTypeRepositoryKey: StorageKey {
        typealias Value = IMembershipTypeRepository
    }
    var membershipTypeRepository: IMembershipTypeRepository? {
        get { self.storage[MembershipTypeRepositoryKey.self] }
        set { self.storage[MembershipTypeRepositoryKey.self] = newValue }
    }
}

// MARK: - TrainerSpecialization Repository

extension Application {
    private struct TrainerSpecializationRepositoryKey: StorageKey {
        typealias Value = ITrainerSpecializationRepository
    }
    var trainerSpecializationRepository: ITrainerSpecializationRepository? {
        get { self.storage[TrainerSpecializationRepositoryKey.self] }
        set { self.storage[TrainerSpecializationRepositoryKey.self] = newValue }
    }
}

// MARK: - TrainerSpecialization Service

extension Application {
    private struct TrainerSpecializationServiceKey: StorageKey {
        typealias Value = ITrainerSpecializationService
    }
    var trainerSpecializationService: ITrainerSpecializationService? {
        get { self.storage[TrainerSpecializationServiceKey.self] }
        set { self.storage[TrainerSpecializationServiceKey.self] = newValue }
    }
}

// MARK: - User Service

extension Application {
    private struct UserServiceKey: StorageKey {
        typealias Value = IUserService
    }
    var userService: IUserService? {
        get { self.storage[UserServiceKey.self] }
        set { self.storage[UserServiceKey.self] = newValue }
    }
}

// MARK: - Attendance Service

extension Application {
    private struct AttendanceServiceKey: StorageKey {
        typealias Value = IAttendanceService
    }
    var attendanceService: IAttendanceService? {
        get { self.storage[AttendanceServiceKey.self] }
        set { self.storage[AttendanceServiceKey.self] = newValue }
    }
}

// MARK: - Trainer Attendance Service

extension Application {
    private struct TrainerAttendanceServiceKey: StorageKey {
        typealias Value = ITrainerAttendanceService
    }
    var trainerAttendanceService: ITrainerAttendanceService? {
        get { self.storage[TrainerAttendanceServiceKey.self] }
        set { self.storage[TrainerAttendanceServiceKey.self] = newValue }
    }
}

// MARK: - User Attendance Service

extension Application {
    private struct UserAttendanceServiceKey: StorageKey {
        typealias Value = IUserAttendanceService
    }
    var userAttendanceService: IUserAttendanceService? {
        get { self.storage[UserAttendanceServiceKey.self] }
        set { self.storage[UserAttendanceServiceKey.self] = newValue }
    }
}

// MARK: - Payment Service

extension Application {
    private struct PaymentServiceKey: StorageKey {
        typealias Value = IPaymentService
    }
    var paymentService: IPaymentService? {
        get { self.storage[PaymentServiceKey.self] }
        set { self.storage[PaymentServiceKey.self] = newValue }
    }
}

// MARK: - MembershipType Service

extension Application {
    private struct MembershipTypeServiceKey: StorageKey {
        typealias Value = IMembershipTypeService
    }
    var membershipTypeService: IMembershipTypeService? {
        get { self.storage[MembershipTypeServiceKey.self] }
        set { self.storage[MembershipTypeServiceKey.self] = newValue }
    }
}

// MARK: - Membership Service

extension Application {
    private struct MembershipServiceKey: StorageKey {
        typealias Value = IMembershipService
    }
    var membershipService: IMembershipService? {
        get { self.storage[MembershipServiceKey.self] }
        set { self.storage[MembershipServiceKey.self] = newValue }
    }
}

// MARK: - Training User Service

extension Application {
    private struct TrainingUserServiceKey: StorageKey {
        typealias Value = ITrainingUserService
    }
    var trainingUserService: ITrainingUserService? {
        get { self.storage[TrainingUserServiceKey.self] }
        set { self.storage[TrainingUserServiceKey.self] = newValue }
    }
}

// MARK: - Training Trainer Service

extension Application {
    private struct TrainingTrainerServiceKey: StorageKey {
        typealias Value = ITrainingTrainerService
    }
    var trainingTrainerService: ITrainingTrainerService? {
        get { self.storage[TrainingTrainerServiceKey.self] }
        set { self.storage[TrainingTrainerServiceKey.self] = newValue }
    }
}

// MARK: - TrainingRoom Service

extension Application {
    private struct TrainingRoomServiceKey: StorageKey {
        typealias Value = ITrainingRoomService
    }
    var trainingRoomService: ITrainingRoomService? {
        get { self.storage[TrainingRoomServiceKey.self] }
        set { self.storage[TrainingRoomServiceKey.self] = newValue }
    }
}

// MARK: - Training Service

extension Application {
    private struct TrainingServiceKey: StorageKey {
        typealias Value = ITrainingService
    }
    var trainingService: ITrainingService? {
        get { self.storage[TrainingServiceKey.self] }
        set { self.storage[TrainingServiceKey.self] = newValue }
    }
}

// MARK: - User Self Service

extension Application {
    private struct UserSelfServiceKey: StorageKey {
        typealias Value = IUserSelfService
    }
    var userSelfService: IUserSelfService? {
        get { self.storage[UserSelfServiceKey.self] }
        set { self.storage[UserSelfServiceKey.self] = newValue }
    }
}

// MARK: - Trainer Self Service

extension Application {
    private struct TrainerSelfServiceKey: StorageKey {
        typealias Value = ITrainerSelfService
    }
    var trainerSelfService: ITrainerSelfService? {
        get { self.storage[TrainerSelfServiceKey.self] }
        set { self.storage[TrainerSelfServiceKey.self] = newValue }
    }
}

// MARK: - Specialization Service

extension Application {
    private struct SpecializationServiceKey: StorageKey {
        typealias Value = ISpecializationService
    }
    var specializationService: ISpecializationService? {
        get { self.storage[SpecializationServiceKey.self] }
        set { self.storage[SpecializationServiceKey.self] = newValue }
    }
}

// MARK: - Auth Service

extension Application {
    private struct AuthServiceKey: StorageKey {
        typealias Value = IAuthService
    }
    var authService: IAuthService? {
        get { self.storage[AuthServiceKey.self] }
        set { self.storage[AuthServiceKey.self] = newValue }
    }
}

// MARK: - Hasher Service

extension Application {
    private struct HasherServiceKey: StorageKey {
        typealias Value = IHasherService
    }
    var hasherService: IHasherService? {
        get { self.storage[HasherServiceKey.self] }
        set { self.storage[HasherServiceKey.self] = newValue }
    }
}

// MARK: - JWT Service

extension Application {
    private struct JWTServiceKey: StorageKey {
        typealias Value = IJWTService
    }
    var jwtService: IJWTService? {
        get { self.storage[JWTServiceKey.self] }
        set { self.storage[JWTServiceKey.self] = newValue }
    }
}

// MARK: - JWT Middleware

extension Application {
    private struct JWTMiddlewareKey: StorageKey {
        typealias Value = JWTMiddleware
    }
    var jwtMiddleware: JWTMiddleware? {
        get { self.storage[JWTMiddlewareKey.self] }
        set { self.storage[JWTMiddlewareKey.self] = newValue }
    }
}

// MARK: - Login Validation MiddlewareKey

extension Application {
    private struct LoginValidationMiddlewareKey: StorageKey {
        typealias Value = LoginValidationMiddleware
    }
    var loginValidationMiddleware: LoginValidationMiddleware? {
        get { self.storage[LoginValidationMiddlewareKey.self] }
        set { self.storage[LoginValidationMiddlewareKey.self] = newValue }
    }
}

// MARK: - Register Validation Middleware

extension Application {
    private struct RegisterValidationMiddlewareKey: StorageKey {
        typealias Value = RegisterValidationMiddleware
    }
    var registerValidationMiddleware: RegisterValidationMiddleware? {
        get { self.storage[RegisterValidationMiddlewareKey.self] }
        set { self.storage[RegisterValidationMiddlewareKey.self] = newValue }
    }
}

// MARK: - User Validation Middleware

extension Application {
    private struct UserValidationMiddlewareKey: StorageKey {
        typealias Value = UserValidationMiddleware
    }
    var userValidationMiddleware: UserValidationMiddleware? {
        get { self.storage[UserValidationMiddlewareKey.self] }
        set { self.storage[UserValidationMiddlewareKey.self] = newValue }
    }
}

// MARK: - UUID Validation Middleware

extension Application {
    private struct UUIDValidationMiddlewareKey: StorageKey {
        typealias Value = UUIDValidationMiddleware
    }
    var uuidValidationMiddleware: UUIDValidationMiddleware? {
        get { self.storage[UUIDValidationMiddlewareKey.self] }
        set { self.storage[UUIDValidationMiddlewareKey.self] = newValue }
    }
}

// MARK: - User Email Validation Middleware

extension Application {
    private struct UserEmailValidationMiddlewareKey: StorageKey {
        typealias Value = UserEmailValidationMiddleware
    }
    var userEmailValidationMiddleware: UserEmailValidationMiddleware? {
        get { self.storage[UserEmailValidationMiddlewareKey.self] }
        set { self.storage[UserEmailValidationMiddlewareKey.self] = newValue }
    }
}

// MARK: - User PhoneNumber Validation Middleware

extension Application {
    private struct UserPhoneNumberValidationMiddlewareKey: StorageKey {
        typealias Value = UserPhoneNumberValidationMiddleware
    }
    var userPhoneNumberValidationMiddleware:
        UserPhoneNumberValidationMiddleware?
    {
        get { self.storage[UserPhoneNumberValidationMiddlewareKey.self] }
        set {
            self.storage[UserPhoneNumberValidationMiddlewareKey.self] = newValue
        }
    }
}

// MARK: - Admin Role Middleware

extension Application {
    private struct AdminRoleMiddlewareKey: StorageKey {
        typealias Value = AdminRoleMiddleware
    }
    var adminRoleMiddleware: AdminRoleMiddleware? {
        get { self.storage[AdminRoleMiddlewareKey.self] }
        set { self.storage[AdminRoleMiddlewareKey.self] = newValue }
    }
}

// MARK: - Trainer Role Middleware

extension Application {
    private struct TrainerRoleMiddlewareKey: StorageKey {
        typealias Value = TrainerRoleMiddleware
    }
    var trainerRoleMiddleware: TrainerRoleMiddleware? {
        get { self.storage[TrainerRoleMiddlewareKey.self] }
        set { self.storage[TrainerRoleMiddlewareKey.self] = newValue }
    }
}

// MARK: - Trainer Or Admin Role Middleware

extension Application {
    private struct AdminOrTrainerRoleMiddlewareKey: StorageKey {
        typealias Value = AdminOrTrainerRoleMiddleware
    }
    var adminOrTrainerRoleMiddleware: AdminOrTrainerRoleMiddleware? {
        get { self.storage[AdminOrTrainerRoleMiddlewareKey.self] }
        set { self.storage[AdminOrTrainerRoleMiddlewareKey.self] = newValue }
    }
}

// MARK: - UserTrainer Service

extension Application {
    private struct IUserTrainerServiceKey: StorageKey {
        typealias Value = IUserTrainerService
    }
    var userTrainerService: IUserTrainerService? {
        get { self.storage[IUserTrainerServiceKey.self] }
        set { self.storage[IUserTrainerServiceKey.self] = newValue }
    }
}

// MARK: - UserRoleName Validation Middleware

extension Application {
    private struct UserRoleNameValidationMiddlewareKey: StorageKey {
        typealias Value = UserRoleNameValidationMiddleware
    }
    var userRoleNameValidationMiddleware: UserRoleNameValidationMiddleware? {
        get { self.storage[UserRoleNameValidationMiddlewareKey.self] }
        set {
            self.storage[UserRoleNameValidationMiddlewareKey.self] = newValue
        }
    }
}

// MARK: - User Create Validation Middleware

extension Application {
    private struct UserCreateValidationMiddlewareKey: StorageKey {
        typealias Value = UserCreateValidationMiddleware
    }
    var userCreateValidationMiddleware: UserCreateValidationMiddleware? {
        get { self.storage[UserCreateValidationMiddlewareKey.self] }
        set { self.storage[UserCreateValidationMiddlewareKey.self] = newValue }
    }
}

// MARK: - Trainer Validation Middleware

extension Application {
    private struct TrainerValidationMiddlewareKey: StorageKey {
        typealias Value = TrainerValidationMiddleware
    }
    var trainerValidationMiddleware: TrainerValidationMiddleware? {
        get { self.storage[TrainerValidationMiddlewareKey.self] }
        set { self.storage[TrainerValidationMiddlewareKey.self] = newValue }
    }
}

// MARK: - Trainer Create Validation Middleware

extension Application {
    private struct TrainerCreateValidationMiddlewareKey: StorageKey {
        typealias Value = TrainerCreateValidationMiddleware
    }
    var trainerCreateValidationMiddleware: TrainerCreateValidationMiddleware? {
        get { self.storage[TrainerCreateValidationMiddlewareKey.self] }
        set {
            self.storage[TrainerCreateValidationMiddlewareKey.self] = newValue
        }
    }
}

// MARK: - Specialization Create Validation Middleware Key

extension Application {
    private struct SpecializationCreateValidationMiddlewareKey: StorageKey {
        typealias Value = SpecializationCreateValidationMiddleware
    }

    var specializationCreateValidationMiddleware:
        SpecializationCreateValidationMiddleware?
    {
        get { self.storage[SpecializationCreateValidationMiddlewareKey.self] }
        set {
            self.storage[SpecializationCreateValidationMiddlewareKey.self] =
                newValue
        }
    }
}

// MARK: - Specialization Validation Middleware Key

extension Application {
    private struct SpecializationValidationMiddlewareKey: StorageKey {
        typealias Value = SpecializationValidationMiddleware
    }

    var specializationValidationMiddleware: SpecializationValidationMiddleware?
    {
        get { self.storage[SpecializationValidationMiddlewareKey.self] }
        set {
            self.storage[SpecializationValidationMiddlewareKey.self] = newValue
        }
    }
}

// MARK: - Specialization Find By Name Validation Middleware Key

extension Application {
    private struct SpecializationFindByNameValidationMiddlewareKey: StorageKey {
        typealias Value = SpecializationFindByNameValidationMiddleware
    }

    var specializationFindByNameValidationMiddleware:
        SpecializationFindByNameValidationMiddleware?
    {
        get {
            self.storage[SpecializationFindByNameValidationMiddlewareKey.self]
        }
        set {
            self.storage[SpecializationFindByNameValidationMiddlewareKey.self] =
                newValue
        }
    }
}

// MARK: - Trainer Service

extension Application {
    private struct TrainerServiceKey: StorageKey {
        typealias Value = ITrainerService
    }
    var trainerService: ITrainerService? {
        get { self.storage[TrainerServiceKey.self] }
        set { self.storage[TrainerServiceKey.self] = newValue }
    }
}

// MARK: - TrainerUser Service
extension Application {
    private struct TrainerUserServiceKey: StorageKey {
        typealias Value = ITrainerUserService
    }
    var trainerUserService: ITrainerUserService? {
        get { self.storage[TrainerUserServiceKey.self] }
        set { self.storage[TrainerUserServiceKey.self] = newValue }
    }
}

// MARK: - TrainerSpecialization Create Validation Middleware
extension Application {
    private struct TrainerSpecializationCreateValidationMiddlewareKey:
        StorageKey
    {
        typealias Value = TrainerSpecializationCreateValidationMiddleware
    }
    var trainerSpecializationCreateValidationMiddleware:
        TrainerSpecializationCreateValidationMiddleware?
    {
        get {
            self.storage[
                TrainerSpecializationCreateValidationMiddlewareKey.self]
        }
        set {
            self.storage[
                TrainerSpecializationCreateValidationMiddlewareKey.self] =
                newValue
        }
    }
}

// MARK: - TrainerSpecialization Validation Middleware

extension Application {
    private struct TrainerSpecializationValidationMiddlewareKey: StorageKey {
        typealias Value = TrainerSpecializationValidationMiddleware
    }
    var trainerSpecializationValidationMiddleware:
        TrainerSpecializationValidationMiddleware?
    {
        get { self.storage[TrainerSpecializationValidationMiddlewareKey.self] }
        set {
            self.storage[TrainerSpecializationValidationMiddlewareKey.self] =
                newValue
        }
    }
}

// MARK: - TrainingRoomCreateValidationMiddleware
extension Application {
    private struct TrainingRoomCreateValidationMiddlewareKey: StorageKey {
        typealias Value = TrainingRoomCreateValidationMiddleware
    }

    var trainingRoomCreateValidationMiddleware:
        TrainingRoomCreateValidationMiddleware?
    {
        get { self.storage[TrainingRoomCreateValidationMiddlewareKey.self] }
        set {
            self.storage[TrainingRoomCreateValidationMiddlewareKey.self] =
                newValue
        }
    }
}

// MARK: - TrainingRoomFindByCapacityValidationMiddleware
extension Application {
    private struct TrainingRoomFindByCapacityValidationMiddlewareKey: StorageKey
    {
        typealias Value = TrainingRoomFindByCapacityValidationMiddleware
    }

    var trainingRoomFindByCapacityValidationMiddleware:
        TrainingRoomFindByCapacityValidationMiddleware?
    {
        get {
            self.storage[TrainingRoomFindByCapacityValidationMiddlewareKey.self]
        }
        set {
            self.storage[
                TrainingRoomFindByCapacityValidationMiddlewareKey.self] =
                newValue
        }
    }
}

// MARK: - TrainingRoomFindByNameValidationMiddleware
extension Application {
    private struct TrainingRoomFindByNameValidationMiddlewareKey: StorageKey {
        typealias Value = TrainingRoomFindByNameValidationMiddleware
    }

    var trainingRoomFindByNameValidationMiddleware:
        TrainingRoomFindByNameValidationMiddleware?
    {
        get { self.storage[TrainingRoomFindByNameValidationMiddlewareKey.self] }
        set {
            self.storage[TrainingRoomFindByNameValidationMiddlewareKey.self] =
                newValue
        }
    }
}

// MARK: - TrainingRoomValidationMiddleware
extension Application {
    private struct TrainingRoomValidationMiddlewareKey: StorageKey {
        typealias Value = TrainingRoomValidationMiddleware
    }

    var trainingRoomValidationMiddleware: TrainingRoomValidationMiddleware? {
        get { self.storage[TrainingRoomValidationMiddlewareKey.self] }
        set {
            self.storage[TrainingRoomValidationMiddlewareKey.self] = newValue
        }
    }
}

// MARK: - TrainingCreateValidationMiddleware
extension Application {
    private struct TrainingCreateValidationMiddlewareKey: StorageKey {
        typealias Value = TrainingCreateValidationMiddleware
    }
    var trainingCreateValidationMiddleware: TrainingCreateValidationMiddleware?
    {
        get { self.storage[TrainingCreateValidationMiddlewareKey.self] }
        set {
            self.storage[TrainingCreateValidationMiddlewareKey.self] = newValue
        }
    }
}

// MARK: - TrainingValidationMiddleware
extension Application {
    private struct TrainingValidationMiddlewareKey: StorageKey {
        typealias Value = TrainingValidationMiddleware
    }
    var trainingValidationMiddleware: TrainingValidationMiddleware? {
        get { self.storage[TrainingValidationMiddlewareKey.self] }
        set { self.storage[TrainingValidationMiddlewareKey.self] = newValue }
    }
}

// MARK: - MembershipType Create Validation Middleware

extension Application {
    private struct MembershipTypeCreateValidationMiddlewareKey: StorageKey {
        typealias Value = MembershipTypeCreateValidationMiddleware
    }

    var membershipTypeCreateValidationMiddleware:
        MembershipTypeCreateValidationMiddleware?
    {
        get { self.storage[MembershipTypeCreateValidationMiddlewareKey.self] }
        set {
            self.storage[MembershipTypeCreateValidationMiddlewareKey.self] =
                newValue
        }
    }
}

// MARK: - MembershipType Find By Name Validation Middleware

extension Application {
    private struct MembershipTypeFindByNameValidationMiddlewareKey: StorageKey {
        typealias Value = MembershipTypeFindByNameValidationMiddleware
    }

    var membershipTypeFindByNameValidationMiddleware:
        MembershipTypeFindByNameValidationMiddleware?
    {
        get {
            self.storage[MembershipTypeFindByNameValidationMiddlewareKey.self]
        }
        set {
            self.storage[MembershipTypeFindByNameValidationMiddlewareKey.self] =
                newValue
        }
    }
}

// MARK: - MembershipType General Validation Middleware

extension Application {
    private struct MembershipTypeValidationMiddlewareKey: StorageKey {
        typealias Value = MembershipTypeValidationMiddleware
    }

    var membershipTypeValidationMiddleware: MembershipTypeValidationMiddleware?
    {
        get { self.storage[MembershipTypeValidationMiddlewareKey.self] }
        set {
            self.storage[MembershipTypeValidationMiddlewareKey.self] = newValue
        }
    }
}

// MARK: - Payment Validation Middleware

extension Application {
    private struct PaymentValidationMiddlewareKey: StorageKey {
        typealias Value = PaymentValidationMiddleware
    }

    var paymentValidationMiddleware: PaymentValidationMiddleware? {
        get { self.storage[PaymentValidationMiddlewareKey.self] }
        set { self.storage[PaymentValidationMiddlewareKey.self] = newValue }
    }
}

// MARK: - Payment Create Validation Middleware

extension Application {
    private struct PaymentCreateValidationMiddlewareKey: StorageKey {
        typealias Value = PaymentCreateValidationMiddleware
    }

    var paymentCreateValidationMiddleware: PaymentCreateValidationMiddleware? {
        get { self.storage[PaymentCreateValidationMiddlewareKey.self] }
        set {
            self.storage[PaymentCreateValidationMiddlewareKey.self] = newValue
        }
    }
}

// MARK: - Membership Purchase Service

extension Application {
    private struct MembershipPurchaseServiceKey: StorageKey {
        typealias Value = IMembershipPurchaseService
    }
    var membershipPurchaseService: IMembershipPurchaseService? {
        get { self.storage[MembershipPurchaseServiceKey.self] }
        set { self.storage[MembershipPurchaseServiceKey.self] = newValue }
    }
}

// MARK: - Membership Purchase Validation Middleware

extension Application {
    private struct MembershipPurchaseValidationMiddlewareKey: StorageKey {
        typealias Value = MembershipPurchaseValidationMiddleware
    }
    var membershipPurchaseValidationMiddleware:
        MembershipPurchaseValidationMiddleware?
    {
        get { self.storage[MembershipPurchaseValidationMiddlewareKey.self] }
        set {
            self.storage[MembershipPurchaseValidationMiddlewareKey.self] =
                newValue
        }
    }
}

// MARK: - AttendanceCreateValidationMiddleware

extension Application {
    private struct AttendanceCreateValidationMiddlewareKey: StorageKey {
        typealias Value = AttendanceCreateValidationMiddleware
    }

    var attendanceCreateValidationMiddleware:
        AttendanceCreateValidationMiddleware?
    {
        get {
            self.storage[AttendanceCreateValidationMiddlewareKey.self]
        }
        set {
            self.storage[AttendanceCreateValidationMiddlewareKey.self] =
                newValue
        }
    }
}

// MARK: - AttendanceValidationMiddleware

extension Application {
    private struct AttendanceValidationMiddlewareKey: StorageKey {
        typealias Value = AttendanceValidationMiddleware
    }

    var attendanceValidationMiddleware: AttendanceValidationMiddleware? {
        get {
            self.storage[AttendanceValidationMiddlewareKey.self]
        }
        set {
            self.storage[AttendanceValidationMiddlewareKey.self] = newValue
        }
    }
}
