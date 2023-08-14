// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "ask-access",
    dependencies: [
        .package(url: "https://github.com/Kitura/Swift-SMTP", .upToNextMinor(from: "5.1.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "ask-access",
            dependencies: [
                .product(name: "SwiftSMTP", package: "Swift-SMTP"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources"
        )
    ]
)
