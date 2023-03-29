//
//  File.swift
//  
//
//  Created by Vsevolod Melnik on 29.03.2023.
//

import Vapor

struct UserAuthenticator: AsyncBasicAuthenticator {
    typealias User = App.User

    func authenticate(
        basic: BasicAuthorization,
        for request: Request
    ) async throws {
        if basic.username == "test" && basic.password == "secret" {
            request.auth.login(User(name: "Vapor"))
        }
   }
}
