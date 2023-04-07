//
//  JoinRoom.swift
//
//
//  Created by Андрей Лосюков on 07.04.2023.
//

import Fluent
import Vapor

final class JoinRoom: Model, Content {

    static let schema = "users_joined_to_rooms"

    // room id
    @ID(key: .id)
    var id: UUID?

    @Field(key: "invitationCode")
    var invitationCode: String?

    @Field(key: "userToJoin")
    var userToJoin: User

    init(idRoom: UUID, invitationCode: String? = nil, userToJoin: User) {
        self.id = idRoom
        self.invitationCode = invitationCode
        self.userToJoin = userToJoin
    }

    init() {
    }
}

extension JoinRoom {
    struct Create: Content {
        var idRoom: UUID

        var invitationCode: String?

        var userToJoin: User
    }
}
