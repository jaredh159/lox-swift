import Darwin
import Foundation

struct Lox {
  enum Error: Swift.Error {
    case noFileAtPath(String)
  }

  func main(args: [String]) throws {
    if args.count > 1 {
      print("Usage: lox [script]")
      exit(64)
    } else if args.count == 1 {
      try runFile(path: args[0])
    } else {
      try runPrompt()
    }
  }

  func runFile(path: String) throws {
    guard FileManager.default.fileExists(atPath: path) else {
      throw Error.noFileAtPath(path)
    }
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let fileContents = String(data: data, encoding: .utf8)!
    try run(source: fileContents)
  }

  func runPrompt() throws {
    repeat {
      print("> ", terminator: "")
      guard let line = readLine() else { break }
      try run(source: line)
    } while true
  }

  func run(source: String) throws {
    print("Run source:\n\n\(source)")
  }
}

extension Lox.Error: LocalizedError {
  var errorDescription: String? {
    switch self {
    case let .noFileAtPath(path):
      return "No file at path: \(path)"
    }
  }
}
