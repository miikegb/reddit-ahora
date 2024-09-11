// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppModules",
    platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v6), .macCatalyst(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppNetworking",
            targets: ["AppNetworking"]),
        .library(
            name: "FeaturePosts",
            targets: ["FeaturePosts"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppNetworking"),
        .testTarget(
            name: "AppNetworkingTests",
            dependencies: ["AppNetworking"]
        ),
        
        .target(
            name: "FeaturePosts",
            dependencies: ["AppNetworking", "Core"],
            resources: [
                .copy("Fixtures"),
            ]
        ),
        .testTarget(
            name: "FeaturePostsTests",
            dependencies: ["FeaturePosts", "AppTestingUtils"],
            resources: [
                .copy("Fixtures"),
            ]
        ),
        
        .target(
            name: "Core",
            dependencies: ["AppNetworking"]),
        .testTarget(
            name: "CoreTests",
            dependencies: [ "Core" ]
        ),
        
        .target(name: "AppTestingUtils"),
    ]
)
