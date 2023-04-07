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
    
    app.post("create_room") { req async throws -> Room in
        let roomCreate = try req.content.decode(Room.Create.self)
        var room: Room
        if let invitationCode = roomCreate.invitationCode {
            room = Room(name: roomCreate.name, invitationCode: invitationCode,
            admin: roomCreate.admin)
        } else {
            room = Room(name: roomCreate.name, invitationCode: nil,
            admin: roomCreate.admin)
        }
        Games.shared.append(room)
        return room
    }
    
    app.post("join_room") { req async throws -> Bool in
        let joinRoomCreate = try req.content.decode(JoinRoom.Create.self)
        if let invitationCode = joinRoomCreate.invitationCode {
            for room in Games.shared {
                if room.invitationCode == invitationCode && joinRoomCreate.idRoom == room.id {
                    room.players.append(joinRoomCreate.userToJoin)
                    return true
                }
            }
            return false
        } else {
            for room in Games.shared {
                if joinRoomCreate.idRoom == room.id {
                    room.players.append(joinRoomCreate.userToJoin)
                    return true
                }
            }
            return false
        }
    }
    
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: TodoController())
}
