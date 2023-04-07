import Fluent
import Vapor

func routes(_ app: Application) throws {
    var rooms: [String: Room] = [:]
    let protected = app.grouped(UserAuthenticator())
        .grouped(User.guardMiddleware())
    protected.get("me") { req -> String in
        try req.auth.require(User.self).name
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
            
            if let u = json?["username"], room?.connections[u] == nil {
                username = u
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
