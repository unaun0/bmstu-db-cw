//
//  UserRepositoryTests.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Fluent
import Vapor
import XCTest
@testable import App
@testable import Domain
@testable import DataAccess

final class UserRepositoryTests: XCTestCase {
    var app: Application!
    var db: Database!
    var userRepository: UserRepository!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        guard let configPath = Environment.get("CONFIG_PATH") else {
            fatalError("CONFIG_PATH not set in environment.")
        }
        let configData = try Data(
            contentsOf: URL(fileURLWithPath: configPath)
        )
        let appConfig = try JSONDecoder().decode(
            AppConfig.self, from: configData
        )
        app.setAppConfig(appConfig)
        let dbConfig = app.appConfig.databaseConfig(for: app.environment)
        app.databases.use(
            DatabaseConfigurationFactory.postgres(
                configuration: .init(
                    hostname: dbConfig.hostname,
                    port: dbConfig.port,
                    username: dbConfig.username,
                    password: dbConfig.password,
                    database: dbConfig.databaseName,
                    tls: .prefer(try .init(configuration: .clientDefault))
                )
            ), as: .psql
        )
        db = app.db(.psql)
        userRepository = UserRepository(db: db)
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testCreateAndDeleteUser() async throws {
        let user = User(
            email: "test-client@example.com",
            phoneNumber: "+1111111111",
            password: "Password123!",
            firstName: "Иван",
            lastName: "Иванов",
            birthDate: Calendar.current.date(byAdding: .year, value: -18, to: Date())!,
            gender: UserGender.male,
            role: UserRoleName.client
        )

        // 1. Попытка создать пользователя
        do {
            try await userRepository.create(user)
        } catch {
            XCTFail("User create failed: \(String(reflecting: error))")
            return
        }

        // 2. Попытка создать дубликат (ожидаем ошибку)
        do {
            try await userRepository.create(user)
            XCTFail("Duplicate user creation did not fail as expected")
        } catch {
            // Успешное срабатывание, можно логировать тип ошибки при необходимости
        }

        // 3. Удаление пользователя
        do {
            try await userRepository.delete(id: user.id)
        } catch {
            XCTFail("User deletion failed: \(String(reflecting: error))")
        }

        // 4. Проверка, что пользователь действительно удалён
        do {
            let fetchedUser = try await userRepository.find(id: user.id)
            XCTAssertNil(fetchedUser, "User was not deleted")
        } catch {
            XCTFail("Fetching user after deletion failed: \(String(reflecting: error))")
        }
    }
    
    func testCreateUpdateAndDeleteUser() async throws {
        // 1. Создание пользователя
        var user = User(
            email: "update-test@example.com",
            phoneNumber: "+79991234567",
            password: "InitialPass123!",
            firstName: "Алексей",
            lastName: "Смирнов",
            birthDate: Calendar.current.date(byAdding: .year, value: -20, to: Date())!,
            gender: .male,
            role: .client
        )

        do {
            try await userRepository.create(user)
        } catch {
            XCTFail("User create failed: \(String(reflecting: error))")
            return
        }

        // 2. Обновление всех полей, кроме id
        user.email = "updated-user@example.com"
        user.phoneNumber = "+78888888888"
        user.password = "NewSecurePass456!"
        user.firstName = "Олег"
        user.lastName = "Петров"
        user.birthDate = Calendar.current.date(byAdding: .year, value: -25, to: Date())!
        user.gender = .female
        user.role = .admin

        do {
            try await userRepository.update(user)
        } catch {
            XCTFail("User update failed: \(String(reflecting: error))")
            return
        }

        // 3. Проверка обновлённого пользователя
        do {
            let updatedUser = try await userRepository.find(id: user.id)
            XCTAssertNotNil(updatedUser, "Updated user not found")
            XCTAssertEqual(updatedUser?.email, user.email)
            XCTAssertEqual(updatedUser?.firstName, user.firstName)
            XCTAssertEqual(updatedUser?.role, user.role)
        } catch {
            XCTFail("Fetching updated user failed: \(String(reflecting: error))")
        }

        // 4. Удаление пользователя
        do {
            try await userRepository.delete(id: user.id)
        } catch {
            XCTFail("User deletion failed: \(String(reflecting: error))")
        }

        // 5. Проверка, что пользователь удалён
        do {
            let deletedUser = try await userRepository.find(id: user.id)
            XCTAssertNil(deletedUser, "User was not deleted")
        } catch {
            XCTFail("Fetching user after deletion failed: \(String(reflecting: error))")
        }
    }
    
    func testCreateAndFindUserByEmailPhoneRoleAndDelete() async throws {
        // 1. Создание пользователя
        let user = User(
            email: "search-test@example.com",
            phoneNumber: "+77777777777",
            password: "FindMePass123!",
            firstName: "Мария",
            lastName: "Кузнецова",
            birthDate: Calendar.current.date(byAdding: .year, value: -22, to: Date())!,
            gender: .female,
            role: .client
        )

        do {
            try await userRepository.create(user)
        } catch {
            XCTFail("User creation failed: \(String(reflecting: error))")
            return
        }

        // Получаем пользователя после создания
        guard
            let _ = try await userRepository.find(
                email: user.email
            )
        else {
            XCTFail("Failed to retrieve created user by email")
            return
        }

        // 2. Поиск по email
        do {
            let foundByEmail = try await userRepository.find(email: user.email)
            XCTAssertNotNil(foundByEmail, "User not found by email")
            XCTAssertEqual(foundByEmail?.email, user.email)
        } catch {
            XCTFail("Failed to find user by email: \(String(reflecting: error))")
        }

        // 3. Поиск по телефону
        do {
            let foundByPhone = try await userRepository.find(phoneNumber: user.phoneNumber)
            XCTAssertNotNil(foundByPhone, "User not found by phone number")
            XCTAssertEqual(foundByPhone?.phoneNumber, user.phoneNumber)
        } catch {
            XCTFail("Failed to find user by phone number: \(String(reflecting: error))")
        }

        // 4. Поиск по роли
        do {
            let foundByRole = try await userRepository.find(role: user.role.rawValue)
            XCTAssertTrue(
                foundByRole.contains(
                    where: { $0.id == user.id }
                ), "User not found in role search"
            )
        } catch {
            XCTFail("Failed to find users by role: \(String(reflecting: error))")
        }

        // 5. Удаление пользователя
        do {
            try await userRepository.delete(id: user.id)
        } catch {
            XCTFail("User deletion failed: \(String(reflecting: error))")
        }

        // 6. Убедиться, что пользователь удалён
        do {
            let deleted = try await userRepository.find(id: user.id)
            XCTAssertNil(deleted, "User was not deleted")
        } catch {
            XCTFail("Failed to check if user was deleted: \(String(reflecting: error))")
        }
    }
    
    func testCreateUserWithDuplicateEmailShouldFail() async throws {
        let user1 = User(
            email: "duplicate@example.com",
            phoneNumber: "+10000000001",
            password: "Pass123!",
            firstName: "Анна",
            lastName: "Петрова",
            birthDate: Calendar.current.date(byAdding: .year, value: -25, to: Date())!,
            gender: .female,
            role: .client
        )
        let user2 = User(
            email: "duplicate@example.com",
            phoneNumber: "+10000000000",
            password: "Pass12345!",
            firstName: "Анн",
            lastName: "Петров",
            birthDate: Calendar.current.date(byAdding: .year, value: -20, to: Date())!,
            gender: .male,
            role: .client
        )

        try await userRepository.create(user1)
        
        do {
            try await userRepository.create(user2)
            XCTFail("Expected duplicate email to throw error")
            try await userRepository.delete(id: user2.id)
        } catch {
            // Успешный проход теста — ошибка брошена
        }
        try await userRepository.delete(id: user1.id)
    }
    
    func testUpdateNonExistentUserShouldFail() async throws {
        let nonExistentUser = User(
            id: UUID(), // случайный UUID
            email: "nonexistent@example.com",
            phoneNumber: "+19999999999",
            password: "DoesNotMatter",
            firstName: "Павел",
            lastName: "Николаев",
            birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!,
            gender: .male,
            role: .admin
        )

        do {
            try await userRepository.update(nonExistentUser)
            XCTFail("Expected update to fail for non-existent user")
        } catch UserError.userNotFound {
            // OK
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDeleteNonExistentUserShouldFail() async throws {
        let randomId = UUID()

        do {
            try await userRepository.delete(id: randomId)
            XCTFail("Expected deletion of non-existent user to throw")
        } catch UserError.userNotFound {
            // OK
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
