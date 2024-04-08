//
//  Core.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/27/24.
//

import Foundation

protocol Votable {
    var ups: Int { get }
    var downs: Int { get }
    var likes: Bool? { get }
}

protocol Created {
    var created: Date { get }
    var createdUtc: Date { get }
}

protocol CommonThing {
    var id: String { get }
    var name: String { get }
}

enum Thing: Decodable {
    case comment(Comment)
    case account
    case link(Link)
    case message
    case subreddit
    case award
    case more(More)
    var `prefix`: String {
        return switch self {
        case .comment: "t1_"
        case .account: "t2_"
        case .link: "t3_"
        case .message: "t4_"
        case .subreddit: "t5_"
        case .award: "t6_"
        case .more: "more"
        }
    }
    
    enum CodingKeys: CodingKey {
        case kind
        case data
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)
        self = switch kind {
        case "t1": .comment(try container.decode(Comment.self, forKey: .data))
        case "t3": .link(try container.decode(Link.self, forKey: .data))
        case "more": .more(try container.decode(More.self, forKey: .data))
        default: throw DecodingError.typeMismatch(Thing.self, DecodingError.Context.init(codingPath: [CodingKeys.kind], debugDescription: "Trying to decode an unknown thing, please make sure it is a recognized kind of thing."))
        }
    }
}

struct Listing: Decodable {
    var kind: String
    var before: String?
    var after: String?
    var modhash: String
    var dist: Int?
    var children: [Thing]
    
    private enum CodingKeys: CodingKey {
        case kind
        case data
    }
    
    private enum DataKeys: CodingKey {
        case before, after, dist, modhash, children
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.kind = try container.decode(String.self, forKey: .kind)
        assert(self.kind == "Listing", "Expected to decode a Listing, but kind's value is \(self.kind) instead of Listing")
        
        let dataContainer = try container.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
        self.before = try dataContainer.decodeIfPresent(String.self, forKey: .before)
        self.after = try dataContainer.decodeIfPresent(String.self, forKey: .after)
        self.dist = try dataContainer.decodeIfPresent(Int.self, forKey: .dist)
        self.modhash = try dataContainer.decode(String.self, forKey: .modhash)
        self.children = try dataContainer.decode([Thing].self, forKey: .children)
    }
}

struct Comment:  Decodable {
    var author: String
    var body: String
    var likes: Bool?
    var subredditId: String
    var authorFlairTxt: String?
    var linkAuthor: String?
    var saved: Bool
    var score: Int
    var scoreHidden: Bool
    var parentId: String
    var replies: Listing?
    
    enum CodingKeys: CodingKey {
        case author
        case body
        case likes
        case subredditId
        case authorFlairTxt
        case linkAuthor
        case saved
        case score
        case scoreHidden
        case parentId
        case replies
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.author = try container.decode(String.self, forKey: .author)
        self.body = try container.decode(String.self, forKey: .body)
        self.likes = try container.decodeIfPresent(Bool.self, forKey: .likes)
        self.subredditId = try container.decode(String.self, forKey: .subredditId)
        self.authorFlairTxt = try container.decodeIfPresent(String.self, forKey: .authorFlairTxt)
        self.linkAuthor = try container.decodeIfPresent(String.self, forKey: .linkAuthor)
        self.saved = try container.decode(Bool.self, forKey: .saved)
        self.score = try container.decode(Int.self, forKey: .score)
        self.scoreHidden = try container.decode(Bool.self, forKey: .scoreHidden)
        self.parentId = try container.decode(String.self, forKey: .parentId)
        self.replies = try? container.decodeIfPresent(Listing.self, forKey: .replies)
    }
}

struct Link: CommonThing, Votable, Created, Decodable, Equatable {
    var id: String
    var name: String
    var author: String
    var title: String
    var created: Date
    var createdUtc: Date
    var ups: Int
    var downs: Int
    var likes: Bool?
    var linkFlairText: String?
    var numComments: Int
    var subreddit: String
    var permalink: String
    var postHint: String?
    var pinned: Bool
    var contentCategories: [String]?
}

struct More: CommonThing, Decodable, Equatable {
    var id: String
    var name: String
    var count: Int
    var parentId: String
    var depth: Int
    var children: [String]
}
