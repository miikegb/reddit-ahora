//
//  AppEnvironment.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/7/24.
//

import SwiftUI

struct AppEnvironment {
    var container = AppEnvironmentContainer()
}

struct AppEnvironmentContainer: EnvironmentKey {
    var runningTest: Bool {
#if DEBUG
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
#else
        false
#endif
    }
    
    static var defaultValue = AppEnvironmentContainer()
}

extension EnvironmentValues {
    var runningEnvironment: AppEnvironmentContainer {
        get { self[AppEnvironmentContainer.self] }
        set { self[AppEnvironmentContainer.self] = newValue }
    }
}

