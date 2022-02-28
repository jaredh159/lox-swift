import Foundation

public class Scanner {
  private let reportError: (Scanner.Error) -> Void
  private let source: Substring
  private var tokens: [Token] = []
  private var start = 0
  private var current = 0
  private var line = 1
  private var column = 1

  public init(source: String, onError: @escaping (Scanner.Error) -> Void) {
    self.source = source[...]
    reportError = onError
  }

  public func getTokens() -> [Token] {
    while let token = nextToken() {
      tokens.append(token)
    }
    tokens.append(.eof(.init(lexeme: "", line: line, column: column - 1)))
    return tokens
  }

  private func nextToken() -> Token? {
    start = current

    switch advance() {
    case nil: return nil
    case "(": return .leftParen(meta)
    case ")": return .rightParen(meta)
    case "{": return .leftBrace(meta)
    case "}": return .rightBrace(meta)
    case ",": return .comma(meta)
    case ".": return .dot(meta)
    case "-": return .minus(meta)
    case "+": return .plus(meta)
    case ";": return .semicolon(meta)
    case "*": return .star(meta)
    case "!": return advance(if: "=") ? .bangEqual(meta) : .bang(meta)
    case "=": return advance(if: "=") ? .equalEqual(meta) : .equal(meta)
    case ">": return advance(if: "=") ? .greaterEqual(meta) : .greater(meta)
    case "/": return consumeComment() ? nextToken() : .slash(meta)
    case "\"": return string() ?? nextToken()
    case " ",
         "\r",
         "\t",
         "\n": return nextToken()
    default:
      reportError(.unexpectedCharacter(line: line, column: column - 1))
      return nextToken()
    }
  }

  @discardableResult
  private func advance() -> Character? {
    let ch = currentChar
    if ch == "\n" {
      line += 1
      column = 0
    }
    current += 1
    column += 1
    return ch
  }

  @discardableResult
  private func advance(if next: Character) -> Bool {
    guard currentChar == next else { return false }
    advance()
    return true
  }

  private func advance(until characters: Character...) {
    let chars = Set<Character?>(characters + [nil])
    while !chars.contains(currentChar) { advance() }
  }

  private func string() -> Token? {
    advance(until: "\"", "\n")
    guard !isAtEnd, currentChar != "\n" else {
      reportError(.unterminatedString(line: line, column: column - (current - start)))
      column += 1 // ensure EOF token has correct column
      return nil
    }
    advance() // consume the closing "
    let value = String(source[nthIndex(offsetBy: start + 1) ..< nthIndex(offsetBy: current - 1)])
    return .string(meta, value)
  }

  private func consumeComment() -> Bool {
    if advance(if: "/") {
      advance(until: "\n")
      advance(if: "\n")
      return true
    }
    return false
  }

  private var currentLine: Int {
    var line = 1
    for (index, char) in source.enumerated() {
      if index == current {
        break
      }
      if char == "\n" {
        line += 1
      }
    }
    return line
  }

  private var currentChar: Character? {
    if isAtEnd { return nil }
    return source[currentIndex]
  }

  private var meta: Token.Meta {
    let lexeme = String(source[nthIndex(offsetBy: start) ..< currentIndex])
    return Token.Meta(
      lexeme: lexeme,
      line: line,
      column: column - lexeme.count
    )
  }

  private var currentIndex: Substring.Index {
    nthIndex(offsetBy: current)
  }

  private func nthIndex(offsetBy offset: Int) -> Substring.Index {
    source.index(source.startIndex, offsetBy: offset)
  }

  private var isAtEnd: Bool {
    current >= source.count
  }
}

public extension Scanner {
  enum Error: Swift.Error, Equatable {
    case unexpectedCharacter(line: Int, column: Int)
    case unterminatedString(line: Int, column: Int)
  }
}

extension Scanner.Error: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .unexpectedCharacter(line: let line, column: let column):
      return "[\(line):\(column)] Error: Unexected character"
    case .unterminatedString(line: let line, column: let column):
      return "[\(line):\(column)] Error: Unterminated string"
    }
  }
}
