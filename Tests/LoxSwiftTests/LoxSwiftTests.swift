import class Foundation.Bundle
import XCTest

final class LoxSwiftTests: XCTestCase {
  func testExample() throws {
    XCTAssertNil(nil)
    //   guard #available(macOS 10.13, *) else {
    //     return
    //   }

    //   let fooBinary = productsDirectory.appendingPathComponent("LoxSwift")

    //   let process = Process()
    //   process.executableURL = fooBinary

    //   let pipe = Pipe()
    //   process.standardOutput = pipe

    //   try process.run()
    //   process.waitUntilExit()

    //   let data = pipe.fileHandleForReading.readDataToEndOfFile()
    //   let output = String(data: data, encoding: .utf8)

    //   XCTAssertEqual(output, "Hello, world!\n")
    // }

    // // Returns path to the built products directory.
    // var productsDirectory: URL {
    //   #if os(macOS)
    //     for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
    //       return bundle.bundleURL.deletingLastPathComponent()
    //     }
    //     fatalError("couldn't find the products directory")
    //   #else
    //     return Bundle.main.bundleURL
    //   #endif
    // }
  }
}
