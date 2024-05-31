//
//  AppEnvironment.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/7/24.
//

import SwiftUI

struct AppEnvironment {
    var container: AppEnvironmentContainer
    var dependencies: Dependencies
    
    static func bootstrap() -> AppEnvironment {
        let dependencies = createDependencyGraph()
        let container = AppEnvironmentContainer()
        return AppEnvironment(container: container, dependencies: dependencies)
    }
    
    private static func createDependencyGraph() -> Dependencies {
        let fetcher = HttpClient(config: .default)
        let postViewModel = RedditPageViewModel(postsRepository: RedditPostsRepository(fetcher: fetcher),
                                           subredditRepository: ProdSubredditRepository(networkFetcher: fetcher))
        let subredditRepository = ProdSubredditRepository(networkFetcher: fetcher)
        return Dependencies(postsViewModel: postViewModel, subredditRepository: subredditRepository)
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
    
    init(postsViewModel: RedditPageViewModel, subredditRepository: SubredditRepository) {
        self.postsViewModel = postsViewModel
        self.subredditRepository = subredditRepository
    }
    
    static var defaultValue = Dependencies(postsViewModel: .preview, subredditRepository: .preview)
}

extension RedditPageViewModel {
    static var preview: RedditPageViewModel {
        RedditPageViewModel(postsRepository: PreviewPostsRepository(), subredditRepository: PreviewSubredditRepository())
    }
}

extension SubredditRepository where Self == PreviewSubredditRepository {
    static var preview: PreviewSubredditRepository {
        PreviewSubredditRepository()
    }
}
