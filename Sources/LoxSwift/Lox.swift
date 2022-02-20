import Darwin
import Foundation
import LoxScanner

@main enum Lox {
  static var hadError = false

  static func main() {
    do {
      let args = Array(CommandLine.arguments.dropFirst())
      if args.count > 1 {
        print("Usage: lox [script]")
        exit(.errUsage)
      } else if args.count == 1 {
        try runFile(path: args[0])
      } else {
        runPrompt()
      }
    } catch {
      print("ERROR -- \(error.localizedDescription)")
      if let loxError = error as? Lox.Error {
        exit(loxError.exitCode)
      }
      exit(.err)
    }
  }

  private static func runFile(path: String) throws {
    guard FileManager.default.fileExists(atPath: path) else {
      throw Error.noFileAtPath(path)
    }
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let fileContents = String(data: data, encoding: .utf8)!
    run(source: fileContents)
    if hadError { exit(.errInput) }
  }

  private static func runPrompt() {
    repeat {
      print("> ", terminator: "")
      guard let line = readLine() else { break }
      run(source: line)
    } while true
  }

  private static func run(source: String) {
    // for now, just print the tokens
    Scanner(source: source).tokens().forEach { token in
      print("TOKEN: \(token)")
    }
  }

  private static func error(line: Int, _ message: String) {
    report(line: line, where: "", message)
  }

  private static func report(line: Int, where: String, _ message: String) {
    fputs("[line \(line)] Error\(`where`): \(message)\n", stderr)
    hadError = true
  }

  private static func exit(_ code: ExitCode) -> Never {
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
    case errInput = 65
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
