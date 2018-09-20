// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ContentaVapor",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vitolibrarius/ContentaTools.git", from: "0.0.0"),
    ],
    targets: [
        .target( name: "ContentaVapor", dependencies: [
            "Vapor",
            "ContentaTools"
        ]),
        .testTarget( name: "ContentaVaporTests", dependencies: [
            "ContentaVapor"
        ]),
    ]
)
