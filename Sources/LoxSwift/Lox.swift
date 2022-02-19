import Darwin
import Foundation
import LoxScanner

@main enum Lox {
  static func main() {
    do {
      let args = Array(CommandLine.arguments.dropFirst())
      if args.count > 1 {
        print("Usage: lox [script]")
        exit(.errUsage)
      } else if args.count == 1 {
        try runFile(path: args[0])
      } else {
        try runPrompt()
      }
    } catch {
      print("ERROR -- \(error.localizedDescription)")
      if let loxError = error as? Lox.Error {
        exit(loxError.exitCode)
      }
      exit(.err)
    }
  }

  static func runFile(path: String) throws {
    guard FileManager.default.fileExists(atPath: path) else {
      throw Error.noFileAtPath(path)
    }
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let fileContents = String(data: data, encoding: .utf8)!
    try run(source: fileContents)
  }

  static func runPrompt() throws {
    repeat {
      print("> ", terminator: "")
      guard let line = readLine() else { break }
      try run(source: line)
    } while true
  }

  static func run(source: String) throws {
    // for now, just print the tokens
    Scanner(source: source).tokens().forEach { token in
      print("TOKEN: \(token)")
    }
  }

  static func exit(_ code: ExitCode) -> Never {
    Darwin.exit(code.rawValue)
  }
}

// extensions

extension Lox {
  enum Error: Swift.Error {
    case noFileAtPath(String)
  }

  enum ExitCode: Int32 {
    case success = 0
    case err = 1
    case errUsage = 64
    case errNoInput = 66
  }
}

extension Lox.Error: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .noFileAtPath(let path):
      return "No file at path: \(path)"
    }
  }

  var exitCode: Lox.ExitCode {
    switch self {
    case .noFileAtPath:
      return .errNoInput
    }
  }
}
