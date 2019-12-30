// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JJSwiftLog",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_13),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(name: "JJSwiftLog", targets: ["JJSwiftLog"])
    ],
    targets: [
        .target(name: "JJSwiftLog", path: "JJSwiftLog/Source"),
    ],
    swiftLanguageVersions: [.v5]
)