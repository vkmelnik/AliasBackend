//
//  File.swift
//  
//
//  Created by Мельник Всеволод on 30.03.2023.
//

import Vapor

struct BearerAuthenticator: AsyncBearerAuthenticator {
    typealias User = App.User

    func authenticate(
        bearer: BearerAuthorization,
        for request: Request
    ) async throws {
        if bearer.token == "foo" {
           //request.auth.login(User(name: "Vapor"))
       }
   }
}
