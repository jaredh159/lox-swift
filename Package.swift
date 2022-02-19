// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LoxSwift",
  dependencies: [
  ],
  targets: [
    .executableTarget(name: "LoxSwift", dependencies: ["LoxScanner"]),
    .target(name: "LoxScanner", dependencies: []),
    .testTarget(name: "LoxSwiftTests", dependencies: ["LoxSwift"]),
  ]
)
