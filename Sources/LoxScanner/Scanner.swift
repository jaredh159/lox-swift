public class Scanner {
  private let reportError: (Int, String) -> Void
  private let source: Substring
  private var tokens: [Token] = []
  private var start = 0
  private var current = 0
  private var line = 1

  public init(source: String, onError: @escaping (Int, String) -> Void) {
    self.source = source[...]
    reportError = onError
  }

  public func getTokens() -> [Token] {
    scanTokens()
  }

  private func scanTokens() -> [Token] {
    while let token = nextToken() {
      tokens.append(token)
    }

    tokens.append(.eof(.init(lexeme: "", offset: current)))
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
    case "/":
      if advance(if: "/") {
        while currentChar != nil, currentChar != "\n" { advance() }
        advance(if: "\n")
        return nextToken()
      } else {
        return .slash(meta)
      }
    default:
      reportError(currentLine, "Unexpected character.")
      return nextToken()
    }
  }

  @discardableResult
  private func advance() -> Character? {
    defer { current += 1 }
    return currentChar
  }

  @discardableResult
  private func advance(if next: Character) -> Bool {
    guard currentChar == next else { return false }
    advance()
    return true
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
    Token.Meta(
      lexeme: String(source[nthIndex(offsetBy: start) ..< currentIndex]),
      offset: current
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
