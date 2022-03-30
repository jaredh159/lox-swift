import Darwin
import Foundation
import LoxAst
import LoxInterpreter
import LoxParser
import LoxScanner

@main enum Lox {
  enum EvalMode: Equatable {
    case interpret
    case tokens
  }

  static var interpreter = Interpreter()
  static var hadError = false
  static var hadRuntimeError = false
  static var printMode = EvalMode.interpret

  static func main() {
    var file: String?
    let args = Array(CommandLine.arguments.dropFirst())
    for arg in args {
      if arg == "--tokens" || arg == "-t" {
        printMode = .tokens
      } else if !arg.starts(with: "-") {
        file = arg
      }
    }

    do {
      if let file = file {
        try runFile(path: file)
      } else {
        runPrompt()
      }
    } catch {
      let error = error as! Error
      report(error)
      exit(error.exitCode)
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
    if hadRuntimeError { exit(.errSoftware) }
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
    let scanner = Scanner(source: source, onError: Lox.reportScannerError(_:))

    if printMode == .tokens {
      scanner.getTokens().forEach { $0.print() }
      return
    }

    let parser = Parser(tokens: scanner.getTokens(), onError: Lox.reportParserError(_:))
    if hadError {
      return
    }

    let statements = parser.parse()
    if let runtimeError = interpreter.interpret(statements) {
      hadRuntimeError = true
      print(runtimeError.message)
    }
  }

  public static func reportScannerError(_ error: LoxScanner.Scanner.Error) {
    report(.scannerError(error))
  }

  public static func reportParserError(_ error: Parser.Error) {
    report(.parserError(error))
  }

  private static func report(_ error: Lox.Error) {
    fputs("\(error.description)\n", stderr)
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
    case scannerError(LoxScanner.Scanner.Error)
    case parserError(Parser.Error)
  }

  enum ExitCode: Int32 {
    case success = 0
    case err = 1
    case errUsage = 64
    case errInput = 65
    case errNoInput = 66
    case errSoftware = 70
  }
}

extension Lox.Error: LocalizedError {
  var description: String {
    switch self {
    case .noFileAtPath(let path):
      return "No file at path: \(path)"
    case .scannerError(.unexpectedCharacter(line: let line, column: let col)):
      return "Scanner Error: unexpected character at \(line):\(col)"
    case .scannerError(.unterminatedString(line: let line, column: let col)):
      return "Scanner Error: unterminated string at \(line):\(col)"
    case .parserError(.expectedToken(_, let message, let line, let col)):
      return "Parser Error: \(message) at \(line):\(col)"
    case .parserError(.expectedExpression(let line, let col)):
      return "Parser Error: expected expression at \(line):\(col)"
    case .parserError(.invalidAssignmentTarget(let line, let col)):
      return "Parser Error: invalid assignment target at \(line):\(col)"
    case .parserError(.excessArguments(let line, let col)):
      return "Parser Error: excess arguments (max 255) at \(line):\(col)"
    case .parserError(.excessParameters(let line, let col)):
      return "Parser Error: excess parameters (max 255) at \(line):\(col)"
    }
  }

  var errorDescription: String? {
    description
  }

  var exitCode: Lox.ExitCode {
    switch self {
    case .noFileAtPath:
      return .errNoInput
    case .scannerError, .parserError:
      return .errInput
    }
  }
}
