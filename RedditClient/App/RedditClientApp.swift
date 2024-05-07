//
//  RedditClientApp.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/26/24.
//

import SwiftUI

@main
struct RedditClientApp: App {
    var isRunningTests: Bool {
#if DEBUG
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
#else
        false
#endif
    }
    var body: some Scene {
        WindowGroup {
            if isRunningTests {
                EmptyView()
            } else {
                ContentView()
                    .background(TranslucentVisualEffect().ignoresSafeArea())
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
}

struct TranslucentVisualEffect: NSViewRepresentable {
    func makeNSView(context: Context) -> some NSView { NSVisualEffectView() }
    func updateNSView(_ nsView: NSViewType, context: Context) { }
}
