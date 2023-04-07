import Fluent
import Vapor

func routes(_ app: Application) throws {
    var rooms: [String: Room] = [:]
    let protected = app.grouped(UserAuthenticator())
        .grouped(User.guardMiddleware())
    protected.get("me") { req -> String in
        try req.auth.require(User.self).name
    }

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
    
    app.webSocket("room", ":id") { req, ws in
        var username: String? = nil
        var room: Room?  = nil
        ws.onText { ws, text in
            // check for auth
            guard let roomId = req.parameters.get("id") else { return }
            if rooms[roomId] == nil {
                rooms[roomId] = Room()
            }
            room = rooms[roomId]
            let jsonDecoder = JSONDecoder()
            guard let jsonData = text.data(using: .utf8) else { return }
            let json = try? jsonDecoder.decode(Dictionary<String, String>.self, from: jsonData)

            guard let u = json?["username"] else {
                return
            }
            username = u

            // check authorization
            guard let token = json?["token"] else {
                return
            }

            do {
                guard let username = username, let user = try await User.query(on: req.db)
                    .filter(\.$name == username)
                    .first() else {
                    return
                }

                if user.token != token {
                    return
                }
            } catch {
                return
            }
            
            if room?.connections[u] == nil {
                room?.connections[u] = ws
                room?.bot("\(u) has joined. 👋")
            }
            
            if let u = username, let m = json?["message"] {
                room?.send(name: u, message: m)
            }
            
            ws.onClose.whenComplete { res in
                guard let u = username else {
                    return
                }
                
                room?.bot("\(u) has left")
                room?.connections.removeValue(forKey: u)
            }
        }
    }

    try app.register(collection: TodoController())
}
