//
//  UserServiceTests.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Vapor
import XCTest

@testable import App
@testable import Domain
@testable import DataAccess

final class UserServiceTests: XCTestCase {
    var userService: IUserService!
    var userRepositoryMock: IUserRepository!
    var passwordHasher: IHasherService!

    override func setUp() {
        super.setUp()
        userRepositoryMock = UserRepositoryMock()
        passwordHasher = BcryptHasherService()
        userService = UserService(
            userRepository: userRepositoryMock,
            passwordHasher: passwordHasher
        )
    }

    override func tearDown() {
        userService = nil
        userRepositoryMock = nil
        super.tearDown()
    }

    // MARK: - Тесты на создание пользователя

    func testCreateUser_Success() async throws {
        let userDTO = UserCreateDTO(
            email: "test@example.com",
            phoneNumber: "+1234567890",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: "2000-01-01 00:00:00",
            gender: UserGender.male,
            role: UserRoleName.client
        )
        let user = try await userService.create(userDTO)
        let createdUser = try await userRepositoryMock.find(
            email: "test@example.com"
        )
        XCTAssertNotNil(createdUser)
        XCTAssertEqual(user, createdUser)
    }

    func testCreateUser_EmailAlreadyExists() async throws {
        let userDTO = UserCreateDTO(
            email: "test@example.com",
            phoneNumber: "+1234567890",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: "2000-01-01 00:00:00",
            gender: UserGender.male,
            role: UserRoleName.client
        )
        let userDTOSameEmail = UserCreateDTO(
            email: "test@example.com",
            phoneNumber: "+1234567891",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: "2002-01-01 00:00:00",
            gender: UserGender.male,
            role: UserRoleName.client
        )

        _ = try await userService.create(userDTO)
        do {
            _ = try await userService.create(userDTOSameEmail)
            XCTFail()
        } catch UserError.emailAlreadyExists {
        } catch {
            XCTFail()
        }
    }
    
    func testCreateUser_PhoneNumberAlreadyExists() async throws {
        let userDTO = UserCreateDTO(
            email: "test@example.com",
            phoneNumber: "+1234567890",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: "2000-01-01 00:00:00",
            gender: UserGender.male,
            role: UserRoleName.client
        )
        let userDTOSamePhone = UserCreateDTO(
            email: "test2@example.com",
            phoneNumber: "+1234567890",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: "2000-01-01 00:00:00",
            gender: UserGender.male,
            role: UserRoleName.client
        )

        _ = try await userService.create(userDTO)
        do {
            _ = try await userService.create(userDTOSamePhone)
            XCTFail()
        } catch UserError.phoneNumberAlreadyExists {
        } catch {
            XCTFail()
        }
    }

    // MARK: - Тесты на обновление пользователя

    func testUpdateUser_Success() async throws {
        let userDTO = UserCreateDTO(
            email: "test@example.com",
            phoneNumber: "+1234567890",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: "2000-01-01 00:00:00",
            gender: UserGender.male,
            role: UserRoleName.client
        )
        let user = try await userService.create(userDTO)

        let newUserDTO = UserUpdateDTO(
            email: nil,
            phoneNumber: "+1234567891",
            password: "Password321!",
            firstName: "Иванка",
            lastName: "Иванова",
            birthDate: nil,
            gender: UserGender.female
        )
        let result = try await userService.update(
            id: user!.id, with: newUserDTO
        )
        XCTAssertNotNil(result)
    }

    func testUpdateUser_UserNotFound() async throws {
        do {
            _ = try await userService.update(
                id: UUID(),
                with: UserUpdateDTO(
                    email: "test@example.com",
                    phoneNumber: "+1234567890",
                    password: "Password123!",
                    firstName: "Иван",
                    lastName: "Иванов",
                    birthDate: "2000-01-01 00:00:00",
                    gender: UserGender.male,
                    role: UserRoleName.client
                )
            )
            XCTFail()
        } catch UserError.userNotFound {
        } catch {
            XCTFail()
        }
    }

    func testUpdateUser_EmailAlreadyExists() async throws {
        let userDTO1 = UserCreateDTO(
            email: "test@example.com",
            phoneNumber: "+1234567890",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: "2000-01-01 00:00:00",
            gender: UserGender.male,
            role: UserRoleName.client
        )
        _ = try await userService.create(userDTO1)

        let userDTO2 = UserCreateDTO(
            email: "test1@example.com",
            phoneNumber: "+1234567891",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: "2000-01-01 00:00:00",
            gender: UserGender.male,
            role: UserRoleName.client
        )
        let user2 = try await userService.create(userDTO2)

        let updUserDTO = UserUpdateDTO(
            email: "test@example.com",
            phoneNumber: nil,
            password: nil,
            firstName: nil,
            lastName: nil,
            birthDate: nil,
            gender: nil
        )
        do {
            _ = try await userService.update(id: user2!.id, with: updUserDTO)
            XCTFail()
        } catch UserError.emailAlreadyExists {
        } catch {
            XCTFail()
        }
    }

    func testUpdateUser_PhoneNumberAlreadyExists() async throws {
        let userDTO1 = UserCreateDTO(
            email: "test@example.com",
            phoneNumber: "+1234567890",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: "2000-01-01 00:00:00",
            gender: UserGender.male,
            role: UserRoleName.client
        )
        _ = try await userService.create(userDTO1)

        let userDTO2 = UserCreateDTO(
            email: "test1@example.com",
            phoneNumber: "+1234567891",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: "2000-01-01 00:00:00",
            gender: UserGender.male,
            role: UserRoleName.client
        )
        let user2 = try await userService.create(userDTO2)

        let updUserDTO = UserUpdateDTO(
            email: nil,
            phoneNumber: "+1234567890",
            password: nil,
            firstName: nil,
            lastName: nil,
            birthDate: nil,
            gender: nil
        )
        do {
            _ = try await userService.update(id: user2!.id, with: updUserDTO)
            XCTFail()
        } catch UserError.phoneNumberAlreadyExists {
        } catch {
            XCTFail()
        }
    }

    // MARK: - Тесты на поиск

    func testFindUser_Success() async throws {
        let userDTO = UserCreateDTO(
            email: "test@example.com",
            phoneNumber: "+1234567890",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: "2000-01-01 00:00:00",
            gender: UserGender.male,
            role: UserRoleName.client
        )
        let user = try await userService.create(userDTO)
        let foundUserByEmail = try await userService.find(
            email: "test@example.com")
        XCTAssertNotNil(foundUserByEmail)

        let foundUserByPhone = try await userService.find(
            phoneNumber: "+1234567890")
        XCTAssertNotNil(foundUserByPhone)

        let foundUserByID = try await userService.find(id: user!.id)
        XCTAssertNotNil(foundUserByID)

        let foundUserAll = try await userService.findAll()
        XCTAssertEqual(foundUserAll.count, 1)

        XCTAssertEqual(foundUserByEmail, foundUserByPhone)
        XCTAssertEqual(foundUserByEmail, foundUserByID)
        XCTAssertEqual(foundUserByEmail, foundUserAll[0])
    }

    // MARK: - Тест на удаление пользователя

    func testDeleteUser_Success() async throws {
        let userDTO = UserCreateDTO(
            email: "test@example.com",
            phoneNumber: "+1234567890",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: "2000-01-01 00:00:00",
            gender: UserGender.male,
            role: UserRoleName.client
        )
        let user = try await userService.create(userDTO)
        try await userService.delete(id: user!.id)
        let foundUser = try await userService.find(id: user!.id)

        XCTAssertNil(foundUser)
    }
}
