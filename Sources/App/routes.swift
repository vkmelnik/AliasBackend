import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.post("auth") { req async throws -> String in
        let requestUser = try req.content.decode(User.Create.self)
        guard let user = try await User.query(on: req.db)
            .filter(\.$name == requestUser.name)
            .first() else {
            return ""
        }
        let token: String = [UInt8].random(count: 32).base64
        if requestUser.password == user.password {
            user.token = token
            try await user.update(on: req.db)
            return token
        }
        return ""
    }

    app.post("users") { req async throws -> User in
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let token: String = [UInt8].random(count: 32).base64
        let user = User(
            name: create.name,
            email: create.email,
            password: create.password,
            token: token
        )
        try await user.save(on: req.db)
        return user
    }
    
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: TodoController())
}
