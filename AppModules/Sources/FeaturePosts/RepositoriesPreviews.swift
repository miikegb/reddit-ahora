//
//  File.swift
//  AppModules
//
//  Created by Miguel Gonzalez on 8/9/24.
//

import Foundation

extension RedditPageViewModel {
    public static var preview: RedditPageViewModel {
        RedditPageViewModel(postsRepository: .preview, subredditRepository: .preview, commentsRepository: .preview, redditorRepository: .preview)
    }
}

extension PostsRepository where Self == PreviewPostsRepository {
    public static var preview: PreviewPostsRepository {
        PreviewPostsRepository()
    }
}

extension SubredditRepository where Self == PreviewSubredditRepository {
    public static var preview: PreviewSubredditRepository {
        PreviewSubredditRepository()
    }
}

extension PostCommentsRepository where Self == PreviewPostCommentsRepository {
    public static var preview: PreviewPostCommentsRepository {
        PreviewPostCommentsRepository()
    }
}

extension RedditorRepository where Self == PreviewRedditorRepository {
    public static var preview: PreviewRedditorRepository {
        PreviewRedditorRepository()
    }
}
