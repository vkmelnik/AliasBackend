//
//  File.swift
//  
//
//  Created by Vsevolod Melnik on 29.03.2023.
//

import Fluent
import Vapor

final class User: Model, Content, Authenticatable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "password")
    var password: String

    @Field(key: "token")
    var token: String

    init() { }

    init(id: UUID? = nil, name: String, email: String, password: String, token: String) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.token = token
    }
}

extension User {
    struct Migration: AsyncMigration {
        var name: String { "CreateUser" }

        func prepare(on database: Database) async throws {
            try await database.schema("users")
                .id()
                .field("name", .string, .required)
                .field("email", .string, .required)
                .field("password", .string, .required)
                .field("token", .string, .required)
                .unique(on: "email")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("users").delete()
        }
    }
}

extension User {
    struct Create: Content {
        var name: String
        var email: String
        var password: String
        var confirmPassword: String
    }
}

extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}
