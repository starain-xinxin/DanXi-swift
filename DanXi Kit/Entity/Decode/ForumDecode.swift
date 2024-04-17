import Foundation

extension Hole {
    enum CodingKeys: String, CodingKey {
        case id
        case timeCreated
        case timeUpdated
        case divisionId
        case view
        case reply
        case hidden
        case locked
        case tags
        case floors
    }
    
    enum NestedKeys: String, CodingKey {
        case firstFloor
        case lastFloor
        case prefetch
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        timeCreated = try container.decode(Date.self, forKey: .timeCreated)
        timeUpdated = try container.decode(Date.self, forKey: .timeUpdated)
        divisionId = try container.decode(Int.self, forKey: .divisionId)
        view = try container.decode(Int.self, forKey: .view)
        reply = try container.decode(Int.self, forKey: .reply)
        hidden = try container.decode(Bool.self, forKey: .hidden)
        locked = try container.decode(Bool.self, forKey: .locked)
        tags = try container.decode([Tag].self, forKey: .tags)
        
        let nestedContainer = try container.nestedContainer(keyedBy: NestedKeys.self, forKey: .floors)
        firstFloor = try nestedContainer.decode(Floor.self, forKey: .firstFloor)
        lastFloor = try nestedContainer.decode(Floor.self, forKey: .lastFloor)
        prefetch = try nestedContainer.decode([Floor].self, forKey: .prefetch)
    }
}

extension Floor {
    enum CodingKeys: String, CodingKey {
        case id
        case holeId
        case timeCreated
        case timeUpdated
        case anonyname
        case specialTag
        case content
        case like
        case dislike
        case liked
        case disliked
        case isMe
        case modified
        case deleted
        case foldV2
        case mention
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        holeId = try container.decode(Int.self, forKey: .holeId)
        timeCreated = try container.decode(Date.self, forKey: .timeCreated)
        timeUpdated = try container.decode(Date.self, forKey: .timeUpdated)
        anonyname = try container.decode(String.self, forKey: .anonyname)
        specialTag = try container.decode(String.self, forKey: .specialTag)
        content = try container.decode(String.self, forKey: .content)
        like = try container.decode(Int.self, forKey: .like)
        dislike = try container.decode(Int.self, forKey: .dislike)
        liked = try container.decodeIfPresent(Bool.self, forKey: .liked) ?? false
        disliked = try container.decodeIfPresent(Bool.self, forKey: .disliked) ?? false
        isMe = try container.decode(Bool.self, forKey: .isMe)
        let modified = try container.decode(Int.self, forKey: .modified)
        self.modified = !(modified == 0)
        deleted = try container.decode(Bool.self, forKey: .deleted)
        fold = try container.decode(String.self, forKey: .foldV2)
        mentions = try container.decode([Mention].self, forKey: .mention)
    }
}

extension Sensitive {
    enum CodingKeys: String, CodingKey {
        case id
        case holeId
        case timeCreated
        case timeUpdated
        case deleted
        case modified
        case isActualSensitive
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        holeId = try container.decode(Int.self, forKey: .holeId)
        timeCreated = try container.decode(Date.self, forKey: .timeCreated)
        timeUpdated = try container.decode(Date.self, forKey: .timeUpdated)
        deleted = try container.decode(Bool.self, forKey: .deleted)
        let modified = try container.decode(Int.self, forKey: .modified)
        self.modified = !(modified == 0)
        sensitive = try container.decodeIfPresent(Bool.self, forKey: .isActualSensitive)
    }
}

extension Message {
    enum CodingKeys: String, CodingKey {
        case id
        case timeCreated
        case timeUpdated
        case description
        case code
        case floor
        case report
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        timeCreated = try container.decode(Date.self, forKey: .timeCreated)
        timeUpdated = try container.decode(Date.self, forKey: .timeUpdated)
        description = try container.decode(String.self, forKey: .description)
        type = (try? container.decode(MessageType.self, forKey: .code)) ?? .mail
        floor = try container.decodeIfPresent(Floor.self, forKey: .floor)
        report = try container.decodeIfPresent(Report.self, forKey: .report)
    }
}

extension Profile {
    enum CodingKeys: String, CodingKey {
        case userId
        case nickname
        case joinedTime
        case isAdmin
        case hasAnsweredQuestions
        case config
        case permission
    }
    
    enum ConfigurationKeys: String, CodingKey {
        case notify
        case showFolded
    }
    
    enum PermissionKeys: String, CodingKey {
        case silent
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .userId)
        nickname = try container.decode(String.self, forKey: .nickname)
        joinTime = try container.decode(Date.self, forKey: .joinedTime)
        isAdmin = try container.decode(Bool.self, forKey: .isAdmin)
        answeredQuestions = try container.decode(Bool.self, forKey: .hasAnsweredQuestions)
        
        let configContainer = try container.nestedContainer(keyedBy: ConfigurationKeys.self, forKey: .config)
        notificationConfiguration = try configContainer.decode([String].self, forKey: .notify)
        showFoldedConfiguration = try configContainer.decode(String.self, forKey: .showFolded)
        
        let permissionContainer = try container.nestedContainer(keyedBy: PermissionKeys.self, forKey: .permission)
        let silent = try permissionContainer.decode([String: Date].self, forKey: .silent)
        var bannedDivision: [Int: Date] = [:]
        for (key, value) in silent {
            if let divisionId = Int(key) {
                bannedDivision[divisionId] = value
            }
        }
        self.bannedDivision = bannedDivision
    }
}
