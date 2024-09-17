//
//  AppEnvironment.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/7/24.
//

import SwiftUI
import AppNetworking
import FeaturePosts

struct AppEnvironment {
    var container: AppEnvironmentContainer
    var dependencies: Dependencies
    
    @MainActor static func bootstrap() -> AppEnvironment {
        let dependencies = createDependencyGraph()
        let container = AppEnvironmentContainer()
        return AppEnvironment(container: container, dependencies: dependencies)
    }
    
    @MainActor private static func createDependencyGraph() -> Dependencies {
        let fetcher = HttpClient(config: .default)
        let subredditRepository = ProdSubredditRepository(networkFetcher: fetcher)
        let commentsRepository = ProdPostCommentsRepository(networkFetcher: fetcher)
        let postsRepository = RedditPostsRepository(fetcher: fetcher)
        let redditorRepository = ProdRedditorRepository(networkFetcher: fetcher)
        let postViewModel = RedditPageViewModel(postsRepository: postsRepository,
                                                subredditRepository: subredditRepository,
                                                commentsRepository: commentsRepository,
                                                redditorRepository: redditorRepository)
        
        return Dependencies(postsViewModel: postViewModel, subredditRepository: subredditRepository, commentsRepository: commentsRepository)
    }
}

struct AppEnvironmentContainer: EnvironmentKey {
    var runningTest: Bool {
#if DEBUG
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
#else
        false
#endif
    }
    
#if os(macOS)
    var runningOnPad: Bool { false }
    var runningOnPhone: Bool { false }
    var runningOnMac: Bool { true }
#else
    var runningOnPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var runningOnPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    var runningOnMac: Bool {
        UIDevice.current.userInterfaceIdiom == .mac
    }
#endif
    
    static var defaultValue = AppEnvironmentContainer()
}

extension EnvironmentValues {
    var runningEnvironment: AppEnvironmentContainer {
        get { self[AppEnvironmentContainer.self] }
        set { self[AppEnvironmentContainer.self] = newValue }
    }
    
    var dependencies: Dependencies {
        get { self[Dependencies.self] }
        set { self[Dependencies.self] = newValue }
    }
}

struct Dependencies: EnvironmentKey {
    var postsViewModel: RedditPageViewModel
    var subredditRepository: SubredditRepository
    var commentsRepository: PostCommentsRepository
    
    init(postsViewModel: RedditPageViewModel, subredditRepository: SubredditRepository, commentsRepository: PostCommentsRepository) {
        self.postsViewModel = postsViewModel
        self.subredditRepository = subredditRepository
        self.commentsRepository = commentsRepository
    }
    
    @MainActor static var defaultValue = Dependencies(
        postsViewModel: .preview,
        subredditRepository: .preview,
        commentsRepository: .preview
    )
}

