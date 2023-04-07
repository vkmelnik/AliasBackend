import Vapor
import Foundation

class Room {
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

    init() {
        connections = [:]
    }
}
