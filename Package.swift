// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LoxSwift",
  dependencies: [
    .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.0"),
  ],
  targets: [
    .executableTarget(name: "LoxSwift", dependencies: ["LoxScanner", "LoxParser", "LoxAst"]),
    .executableTarget(name: "LoxCodegen", dependencies: []),
    .target(name: "LoxAst", dependencies: ["LoxScanner"]),
    .target(name: "LoxParser", dependencies: ["LoxScanner", "LoxAst"]),
    .target(name: "LoxScanner", dependencies: ["Rainbow"]),
    .testTarget(name: "LoxAstTests", dependencies: ["LoxAst", "LoxScanner"]),
    .testTarget(name: "LoxScannerTests", dependencies: ["LoxScanner"]),
    .testTarget(name: "LoxSwiftTests", dependencies: ["LoxSwift"]),
    .testTarget(name: "LoxParserTests", dependencies: ["LoxScanner", "LoxAst"]),
  ]
)
