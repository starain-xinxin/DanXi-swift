import Foundation
import SwiftUI

extension THHole {
    enum CodingKeys: String, CodingKey {
        case id = "hole_id"
        case divisionId = "division_id"
        case view
        case reply
        case updateTime = "time_updated"
        case createTime = "time_created"
        case tags
        
        case floorStruct = "floors"
        enum FloorsKeys: String, CodingKey {
            case firstFloor = "first_floor"
            case lastFloor = "last_floor"
            case floors = "prefetch"
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        divisionId = try values.decode(Int.self, forKey: .divisionId)
        view = try values.decode(Int.self, forKey: .view)
        reply = try values.decode(Int.self, forKey: .reply)
        tags = try values.decode([THTag].self, forKey: .tags)
        let iso8601UpdateTime = try values.decode(String.self, forKey: .updateTime)
        let iso8601CreateTime = try values.decode(String.self, forKey: .createTime)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withTimeZone,.withFractionalSeconds,.withInternetDateTime]
        if let updateTime = formatter.date(from: iso8601UpdateTime), let createTime = formatter.date(from: iso8601CreateTime) {
            self.updateTime = updateTime
            self.createTime = createTime
        } else {
            throw NetworkError.invalidResponse
        }
        
        let floorStruct = try values.nestedContainer(keyedBy: CodingKeys.FloorsKeys.self, forKey: .floorStruct)
        firstFloor = try floorStruct.decode(THFloor.self, forKey: .firstFloor)
        lastFloor = try floorStruct.decode(THFloor.self, forKey: .lastFloor)
        floors = try floorStruct.decode([THFloor].self, forKey: .floors)
    }
}

extension THFloor {
    enum CodingKeys: String, CodingKey {
        case id = "floor_id"
        case updateTime = "time_updated"
        case createTime = "time_created"
        case like
        case liked
        case isMe = "is_me"
        case deleted
        case holeId = "hole_id"
        case storey, content
        case posterName = "anonyname"
        case mention
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        like = try values.decode(Int.self, forKey: .like)
        liked = try values.decodeIfPresent(Bool.self, forKey: .liked)
        isMe = try values.decodeIfPresent(Bool.self, forKey: .isMe) ?? false
        deleted = try values.decodeIfPresent(Bool.self, forKey: .deleted) ?? false
        holeId = try values.decode(Int.self, forKey: .holeId)
        storey = try values.decode(Int.self, forKey: .storey)
        content = try values.decode(String.self, forKey: .content)
        let posterName = try values.decode(String.self, forKey: .posterName)
        self.posterName = posterName
        
        let iso8601UpdateTime = try values.decode(String.self, forKey: .updateTime)
        let iso8601CreateTime = try values.decode(String.self, forKey: .createTime)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withTimeZone,.withFractionalSeconds,.withInternetDateTime]
        if let createTime = formatter.date(from: iso8601CreateTime),
            let updateTime = formatter.date(from: iso8601UpdateTime) {
            self.createTime = createTime
            self.updateTime = updateTime
        } else {
            throw NetworkError.invalidResponse
        }
        mention = try values.decodeIfPresent([THMention].self, forKey: .mention) ?? []
        
        self.posterColor = randomColor(name: posterName)
    }
}

extension THMention {
    enum CodingKeys: String, CodingKey {
        case floorId = "floor_id"
        case holeId = "hole_id"
        case content
        case posterName = "anonyname"
    }
}

extension THUser {
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case nickname
        case favorites
        case joinTime = "joined_time"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        nickname = try values.decode(String.self, forKey: .nickname)
        favorites = try values.decode([Int].self, forKey: .favorites)
        let iso8601JoinTime = try values.decode(String.self, forKey: .joinTime)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withTimeZone,.withFractionalSeconds,.withInternetDateTime]
        if let time = formatter.date(from: iso8601JoinTime) {
            joinTime = time
        } else {
            throw NetworkError.invalidResponse
        }
    }
}

extension THDivision {
    enum CodingKeys: String, CodingKey {
        case id = "division_id"
        case name
        case description
        case pinned
    }
}

extension THTag {
    enum CodingKeys: String, CodingKey {
        case id = "tag_id"
        case name, temperature
    }
    
    init(id: Int, temperature: Int, name: String) {
        self.id = id
        self.temperature = temperature
        self.name = name
        self.color = randomColor(name: name)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        let nameStr = try values.decode(String.self, forKey: .name)
        name = nameStr
        temperature = try values.decode(Int.self, forKey: .temperature)
        
        color = randomColor(name: name)
    }
}


