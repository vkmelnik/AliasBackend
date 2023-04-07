//
//  File.swift
//  
//
//  Created by Vsevolod Melnik on 29.03.2023.
//

import Vapor
import Fluent

struct UserAuthenticator: AsyncBasicAuthenticator {
    typealias User = App.User

    func authenticate(
        basic: BasicAuthorization,
        for request: Request
    ) async throws {
        guard let user = try await User.query(on: request.db)
            .filter(\.$name == basic.username)
            .first() else {
            return
        }
        if basic.password == user.password {
            request.auth.login(User(name: user.name, email: user.email, password: user.password, token: ""))
        }
   }
}
