// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Yggdrasil",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(
            name: "Yggdrasil",
            targets: ["Yggdrasil"]),
    ],
    targets: [
        .target(
            name: "Yggdrasil",
            dependencies: [],
            sources: [
              "YggTree.swift",
              "YggTwig.swift",
              "Yggdrasil.swift",
              "YggXMLParser.swift"
            ]),
        .testTarget(
            name: "YggdrasilTests",
            dependencies: ["Yggdrasil"]),
    ]
)
