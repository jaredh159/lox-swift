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
      print("> ".dim, terminator: "")
      guard let line = readLine(), line != ".exit" else {
        print("Bye!")
        exit(.success)
      }
      run(source: line)
      hadError = false
    } while true
  }

  private static func run(source: String) {
    let scanner = Scanner(source: source, onError: Lox.reportScannerError)
    // for now, just print the tokens
    scanner.getTokens().forEach { token in
      token.print()
    }
  }

  public static func reportScannerError(_ error: LoxScanner.Scanner.Error) {
    report(error.errorDescription!)
  }

  private static func report(_ message: String) {
    fputs("\(message)\n", stderr)
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
