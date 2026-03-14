// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "swift-oslog",
  platforms: [
    .iOS(.v18),
    .macOS(.v15),
    .tvOS(.v18),
    .watchOS(.v11),
  ],
  products: [
    .library(name: "OSLogging", targets: ["OSLogging"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.10.0"),
  ],
  targets: [

    .target(
      name: "OSLogging",
      dependencies: [
        .product(name: "Logging", package: "swift-log"),
      ]
    ),

    .testTarget(
      name: "OSLoggingTests",
      dependencies: [
        "OSLogging",
        .product(name: "Logging", package: "swift-log"),
      ]
    ),
  ]
)
