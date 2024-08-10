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

public protocol CommonThing {
    var id: String { get }
    var name: String { get }
}

public enum Thing: Decodable {
    case comment(Comment)
    case account(Redditor)
    case link(Link)
    case message
    case subreddit(Subreddit)
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
    public var associatedValue: (any CommonThing)? {
        switch self {
        case let .comment(comment): comment
        case let .account(redditor): redditor
        case let .link(link): link
        case let .subreddit(subreddit): subreddit
        case let .more(more): more
        case .message: nil
        case .award: nil
        }
    }
    
    private enum CodingKeys: CodingKey {
        case kind
        case data
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)
        self = switch kind {
        case "t1": .comment(try container.decode(Comment.self, forKey: .data))
        case "t2": .account(try container.decode(Redditor.self, forKey: .data))
        case "t3": .link(try container.decode(Link.self, forKey: .data))
        case "t5": .subreddit(try container.decode(Subreddit.self, forKey: .data))
        case "more": .more(try container.decode(More.self, forKey: .data))
        default: throw DecodingError.typeMismatch(Thing.self, DecodingError.Context.init(codingPath: [CodingKeys.kind], debugDescription: "Trying to decode an unknown thing, please make sure it is a recognized kind of thing."))
        }
    }
}

public struct Listing: Decodable {
    var kind: String
    var before: String?
    public var after: String?
    var modhash: String
    var dist: Int?
    public var children: [Thing]
    
    private enum CodingKeys: CodingKey {
        case kind
        case data
    }
    
    private enum DataKeys: CodingKey {
        case before, after, dist, modhash, children
    }
    
    public init(from decoder: any Decoder) throws {
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

public struct Comment: CommonThing, Decodable {
    public var id: String
    public var name: String
    public var author: String
    public var body: String
    public var created: Date
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
        case id
        case name
        case author
        case body
        case created
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
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.author = try container.decode(String.self, forKey: .author)
        self.body = try container.decode(String.self, forKey: .body)
        self.created = try container.decode(Date.self, forKey: .created)
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

public struct Redditor: CommonThing, Decodable {
    public var id: String
    public var name: String
    var created: Date
    public var iconImg: String
    var snoovatarImg: String
    var totalKarma: Int
    var commentKarma: Int
    var linkKarma: Int
    
    public init(id: String, name: String, created: Date, iconImg: String, snoovatarImg: String, totalKarma: Int, commentKarma: Int, linkKarma: Int) {
        self.id = id
        self.name = name
        self.created = created
        self.iconImg = iconImg
        self.snoovatarImg = snoovatarImg
        self.totalKarma = totalKarma
        self.commentKarma = commentKarma
        self.linkKarma = linkKarma
    }
}

public struct ImageMetadata: Decodable {
    var url: URL
    var width: Int
    var height: Int
}

public struct ImagePreview: Decodable {
    var id: String
    var source: ImageMetadata
    var resolutions: [ImageMetadata]
}

public struct LinkPreview: Decodable {
    var images: [ImagePreview]
    var enabled: Bool
}

public struct Link: CommonThing, Votable, Created, Decodable, Identifiable, Equatable {
    public var id: String
    public var name: String
    public var author: String
    public var title: String
    public var selftext: String
    public var created: Date
    var createdUtc: Date
    public var ups: Int
    public var downs: Int
    var likes: Bool?
    var linkFlairText: String?
    public var numComments: Int
    public var subreddit: String
    public var permalink: String
    public var postHint: String?
    var pinned: Bool
    public var url: String
    var urlOverridenByDest: String?
    var contentCategories: [String]?
    var preview: LinkPreview?
    
    public static func ==(_ lhs: Link, _ rhs: Link) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.author == rhs.author &&
        lhs.title == rhs.title &&
        lhs.created == rhs.created &&
        lhs.subreddit == rhs.subreddit
    }
}

public struct Subreddit: CommonThing, Decodable, Equatable {
    public var id: String
    public var name: String
    public var title: String
    var description: String
    var headerTitle: String
    var headerImg: String?
    var bannerImg: String?
    var bannerSize: [Int]?
    var mobileBannerImage: String?
    var headerSize: [Int]?
    public var iconImg: String?
    var iconSize: [Int]?
    var primaryColor: String
    var activeUserCount: Int
    var accountsActive: Int
    var subscribers: Int
    var publicDescription: String
    var created: Date
}

public struct More: CommonThing, Decodable, Equatable {
    public var id: String
    public var name: String
    var count: Int
    var parentId: String
    var depth: Int
    var children: [String]
}
