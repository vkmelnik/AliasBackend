import Vapor
import Fluent
import Foundation

final class Room {
    static let schema = "rooms"

    var id: UUID?

    var name: String

    var invitationCode: String?

    var admin: User

    var players: [User]

    init(name: String, invitationCode: String?, admin : User, players: [User] = []) {
        self.id = UUID()
        self.name = name
        self.admin = admin
        self.invitationCode = invitationCode
        self.players = players
        self.players.append(admin)

        connections = [:]
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, invitationCode, admin, players
    }

    var connections: [String: WebSocket]

    func bot(_ message: String) {
        send(name: "Bot", message: message)
    }

    func send(name: String, message: String) {

        let messageNode: [String: String] = [
            "username": name,
            "message": message
        ]


        for (username, socket) in connections {
            guard username != name else {
                continue
            }

            socket.send(String(describing: messageNode))
        }
    }
}

extension Room {
    struct Create: Content {
        var name: String
        var invitationCode: String?
        var admin: User
        var players: [User]?
    }
}
