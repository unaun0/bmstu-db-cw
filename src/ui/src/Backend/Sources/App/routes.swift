import Vapor
import VaporToOpenAPI

import API
import Domain

func routes(_ app: Application) throws {
    app.get { req async in "It works!" }
    app.get("swagger.json") { req in
        req.application.routes.openAPI(
            info: InfoObject(
                title: "Fitness Club API",
                description: "API для управления фитнес-клубом.",
                version: "1.0.0"
            ),
            components: ComponentsObject(
                securitySchemes: [
                    "bearerAuth": .value(
                        SecuritySchemeObject(
                            type: .http,
                            scheme: "bearer",
                            bearerFormat: "JWT"
                        )
                    )
                ]
            )
        )
    }
    let authController = AuthController(
        authService: app.authService!,
        jwtService: app.jwtService!,
        registerMiddleware: app.registerValidationMiddleware!,
        loginMiddleware: app.loginValidationMiddleware!
    )
    try app.register(collection: authController)

    let userSelfController = UserSelfController(
        service: app.userSelfService!,
        jwtMiddleware: app.jwtMiddleware!,
        validationMiddleware: app.userValidationMiddleware!
    )
    try app.register(collection: userSelfController)
    
    let userTrainerController = UserTrainerController(
        service: app.userTrainerService!,
        jwtMiddleware: app.jwtMiddleware!,
        trainerMiddleware: app.adminOrTrainerRoleMiddleware!,
        uuidMiddleware: app.uuidValidationMiddleware!,
        emailMiddleware: app.userEmailValidationMiddleware!,
        phoneMiddleware: app.userPhoneNumberValidationMiddleware!
    )
    try app.register(collection: userTrainerController)
    
    let userAdminController = UserAdminController(
        service: app.userService!,
        jwtMiddleware: app.jwtMiddleware!,
        adminMiddleware: app.adminRoleMiddleware!,
        uuidMiddleware: app.uuidValidationMiddleware!,
        emailMiddleware: app.userEmailValidationMiddleware!,
        phoneMiddleware: app.userPhoneNumberValidationMiddleware!,
        roleMiddleware: app.userRoleNameValidationMiddleware!,
        userCreateMiddleware: app.userCreateValidationMiddleware!
    )
    try app.register(collection: userAdminController)
    
    let trainerAdminController = TrainerAdminController(
        service: app.trainerService!,
        jwtMiddleware: app.jwtMiddleware!,
        adminMiddleware: app.adminRoleMiddleware!,
        trainerMiddleware: app.trainerValidationMiddleware!,
        trainerCreateMiddleware: app.trainerCreateValidationMiddleware!,
        uuidMiddleware: app.uuidValidationMiddleware!
    )
    try app.register(collection: trainerAdminController)
    
    let trainerUserController = TrainerUserController(
        service: app.trainerUserService!,
        jwtMiddleware: app.jwtMiddleware!,
        uuidMiddleware: app.uuidValidationMiddleware!
    )
    try app.register(collection: trainerUserController)
    
    let specializationAdminController = SpecializationAdminController(
        service: app.specializationService!,
        jwtMiddleware: app.jwtMiddleware!,
        adminMiddleware: app.adminRoleMiddleware!,
        specCreateMiddleware: app.specializationCreateValidationMiddleware!,
        specMiddleware: app.specializationValidationMiddleware!,
        specNameMiddleware: app.specializationFindByNameValidationMiddleware!,
        uuidMiddleware: app.uuidValidationMiddleware!
    )
    try app.register(collection: specializationAdminController)
    
    let specializationUserController = SpecializationUserController(
        service: app.specializationService!,
        jwtMiddleware: app.jwtMiddleware!,
        specNameMiddleware: app.specializationFindByNameValidationMiddleware!,
        uuidMiddleware: app.uuidValidationMiddleware!
    )
    try app.register(collection: specializationUserController)
    
    let trainerSpecializationAdminController = TrainerSpecializationAdminController(
        service: app.trainerSpecializationService!,
        jwtMiddleware: app.jwtMiddleware!,
        adminMiddleware: app.adminRoleMiddleware!,
        createMiddleware: app.trainerSpecializationCreateValidationMiddleware!,
        validationMiddleware: app.trainerSpecializationValidationMiddleware!,
        uuidMiddleware: app.uuidValidationMiddleware!
    )
    try app.register(collection: trainerSpecializationAdminController)
    
    let trainerSelfService = TrainerSelfController(
        service: app.trainerSelfService!,
        jwtMiddleware: app.jwtMiddleware!,
        trainerMiddleware: app.adminOrTrainerRoleMiddleware!
    )
    try app.register(collection: trainerSelfService)
    
    let trainingRoomAdminController = TrainingRoomAdminController(
        service: app.trainingRoomService!,
        adminRoleMiddleware: app.adminRoleMiddleware!,
        jwtMiddleware: app.jwtMiddleware!,
        roomMiddleware: app.trainingRoomValidationMiddleware!,
        createMiddleware: app.trainingRoomCreateValidationMiddleware!,
        nameMiddleware: app.trainingRoomFindByNameValidationMiddleware!,
        capacityMiddleware: app.trainingRoomFindByCapacityValidationMiddleware!,
        uuidMiddleware: app.uuidValidationMiddleware!
    )
    try app.register(collection: trainingRoomAdminController)
    
    let trainingAdminController = TrainingAdminController(
        trainingService: app.trainingService!,
        adminRoleMiddleware: app.adminRoleMiddleware!,
        jwtMiddleware: app.jwtMiddleware!,
        createValidationMiddleware: app.trainingCreateValidationMiddleware!,
        validationMiddleware: app.trainingValidationMiddleware!,
        uuidValidationMiddleware: app.uuidValidationMiddleware!
    )
    try app.register(collection: trainingAdminController)
    
    let trainingUserController = TrainingUserController(
        trainingService: app.trainingUserService!,
        jwtMiddleware: app.jwtMiddleware!
    )
    try app.register(collection: trainingUserController)
    
    let trainingTrainerController = TrainingTrainerController(
        trainingService: app.trainingTrainerService!,
        jwtMiddleware: app.jwtMiddleware!,
        trainerMiddleware: app.adminOrTrainerRoleMiddleware!,
        createMiddleware: app.trainingCreateValidationMiddleware!,
        updateMiddleware:  app.trainingValidationMiddleware!,
        uuidMiddleware: app.uuidValidationMiddleware!
    )
    try app.register(collection: trainingTrainerController)
    
    let membershipTypeAdminController = MembershipTypeAdminController(
        service: app.membershipTypeService!,
        adminRoleMiddleware: app.adminRoleMiddleware!,
        jwtMiddleware: app.jwtMiddleware!,
        membershipTypeValidationMiddleware: app.membershipTypeValidationMiddleware!,
        membershipTypeCreateValidationMiddleware: app.membershipTypeCreateValidationMiddleware!,
        membershipTypeFindByNameValidationMiddleware: app.membershipTypeFindByNameValidationMiddleware!,
        uuidValidationMiddleware: app.uuidValidationMiddleware!
    )
    try app.register(collection: membershipTypeAdminController)
    
    let membershipTypeUserController = MembershipTypeUserController(
        service: app.membershipTypeService!,
        jwtMiddleware: app.jwtMiddleware!
    )
    try app.register(collection: membershipTypeUserController)
    
    let paymentAdminController = PaymentAdminController(
        service: app.paymentService!,
        jwtMiddleware: app.jwtMiddleware!,
        adminMiddleware: app.adminRoleMiddleware!,
        uuidMiddleware: app.uuidValidationMiddleware!,
        createMiddleware: app.paymentCreateValidationMiddleware!,
        updateMiddleware: app.paymentValidationMiddleware!
    )
    try app.register(collection: paymentAdminController)
    
    let paymentUserController = PaymentUserController(
        service: app.paymentService!,
        jwtMiddleware: app.jwtMiddleware!
    )
    try app.register(collection: paymentUserController)
    
    let membershipAdminController = MembershipAdminController(
        service: app.membershipService!,
        jwtMiddleware: app.jwtMiddleware!,
        adminMiddleware: app.adminRoleMiddleware!,
        uuidMiddleware: app.uuidValidationMiddleware!,
        createMiddleware: app.membershipCreateValidationMiddleware!,
        updateMiddleware: app.membershipValidationMiddleware!
    )
    try app.register(collection: membershipAdminController)
    
    let membershipPurchaseUserController = MembershipPurchaseUserController(
        service: app.membershipPurchaseService!,
        jwtMiddleware: app.jwtMiddleware!,
        uuidMiddleware: app.uuidValidationMiddleware!,
        validationMiddleware: app.membershipPurchaseValidationMiddleware!
    )
    try app.register(collection: membershipPurchaseUserController)
    
    let membershipUserController = MembershipUserController(
        service: app.membershipService!,
        jwtMiddleware: app.jwtMiddleware!
    )
    try app.register(collection: membershipUserController)
    
    let attendanceAdminController = AttendanceAdminController(
        service: app.attendanceService!,
        jwtMiddleware: app.jwtMiddleware!,
        adminMiddleware: app.adminRoleMiddleware!,
        uuidMiddleware: app.uuidValidationMiddleware!,
        createMiddleware: app.attendanceCreateValidationMiddleware!,
        updateMiddleware: app.attendanceValidationMiddleware!
    )
    try app.register(collection: attendanceAdminController)
    
    let attendanceTrainerController = TrainerAttendanceController(
        attendanceService: app.trainerAttendanceService!,
        jwtMiddleware: app.jwtMiddleware!,
        trainerMiddleware: app.adminOrTrainerRoleMiddleware!,
        uuidMiddleware: app.uuidValidationMiddleware!,
        statusMiddleware: app.attendanceValidationMiddleware!
    )
    try app.register(collection: attendanceTrainerController)
    
    let attendanceUserController = UserAttendanceController(
        attendanceService: app.userAttendanceService!,
        jwtMiddleware: app.jwtMiddleware!,
        uuidMiddleware: app.uuidValidationMiddleware!,
        dataMiddleware: app.attendanceValidationMiddleware!
    )
    try app.register(collection: attendanceUserController)
    
//    let userTrainerReviewController = UserTrainerReviewController(
//        trainerReviewService: app.trainerReviewService!,
//        jwtMiddleware: app.jwtMiddleware!,
//        uuidMiddleware: app.uuidValidationMiddleware!,
//        createValidationMiddleware: app.trainerReviewCreateValidationMiddleware!,
//        updateValidationMiddleware: app.trainerReviewValidationMiddleware!
//    )
//    try app.register(collection: userTrainerReviewController)
}
