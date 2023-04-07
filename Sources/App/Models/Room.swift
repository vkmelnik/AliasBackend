//
//  File.swift
//  
//
//  Created by Андрей Лосюков on 07.04.2023.
//

import Fluent
import Vapor

final class Room : Model, Content {
    init() {
    }
    
    static let schema = "rooms"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "invitationCode")
    var invitationCode: String?
    
    @Field(key: "admin")
    var admin: User
    
    @Field(key: "users")
    var players: [User]
    
    init(name: String, invitationCode: String?, admin : User, players: [User] = []) {
        self.id = UUID()
        self.name = name
        self.admin = admin
        self.invitationCode = invitationCode
        self.players = players
        self.players.append(admin)
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
