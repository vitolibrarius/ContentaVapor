// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Contenta",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        .package(url: "https://github.com/vitolibrarius/ContentaTools.git", from: "0.0.0"),
        .package(url: "https://github.com/vitolibrarius/ContentaUserModel.git", from: "0.0.0"),
    ],
    targets: [
        .target( name: "App", dependencies: [
            "Vapor",
            "Leaf",
            "Authentication",
            "Fluent",
            "FluentSQLite",
            "ContentaTools",
            "ContentaUserModel"
        ]),
        .target(name: "Run", dependencies: [
            "App"
        ]),
        .testTarget( name: "ContentaVaporTests", dependencies: [
            "App"
        ])
    ]
)
