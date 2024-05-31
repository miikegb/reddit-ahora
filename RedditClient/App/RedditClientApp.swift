//
//  RedditClientApp.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/26/24.
//

import SwiftUI

@main
struct RedditClientApp: App {
    var appEnvironment = AppEnvironment.bootstrap()
    
    var body: some Scene {
        WindowGroup {
            WindowContent()
        }
        .environment(\.runningEnvironment, appEnvironment.container)
        .environment(\.dependencies, appEnvironment.dependencies)
        .environmentObject(NavigationModel())
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}

struct WindowContent: View {
    @Environment(\.runningEnvironment.runningTest) private var isRunningTest
    
    var body: some View {
        if isRunningTest {
            EmptyView()
        } else {
            ContentView()
            #if os(macOS)
                .background(TranslucentVisualEffect().ignoresSafeArea())
            #endif
        }
    }
}
