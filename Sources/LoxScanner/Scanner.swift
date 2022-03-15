import Foundation

public class Scanner {
  private let reportError: (Error) -> Void
  private let source: Substring
  private var tokens: [Token] = []
  private var start = 0
  private var current = 0
  private var line = 1
  private var column = 1

  public init(source: String, onError: @escaping (Error) -> Void) {
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
    case "<": return advance(if: "=") ? .lessEqual(meta) : .less(meta)
    case "/": return consumeComment() ? nextToken() : .slash(meta)
    case "\"": return string() ?? nextToken()
    case let ch where isDigit(ch): return number()
    case let ch where isAlpha(ch): return identifier()
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

  private func advance(while predicate: (Character?) -> Bool) {
    while predicate(currentChar) { advance() }
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

  private func number() -> Token {
    advance(while: isDigit)
    if currentChar == ".", isDigit(nextChar) {
      advance() // consume .
      advance(while: isDigit)
    }
    let tokenMeta = meta
    let value = Double(tokenMeta.lexeme)!
    return .number(meta, value)
  }

  private func identifier() -> Token {
    advance(while: isAlphaNumeric)
    let tokenMeta = meta
    switch tokenMeta.lexeme {
    case "and":
      return .and(tokenMeta)
    case "class":
      return .class(tokenMeta)
    case "else":
      return .else(tokenMeta)
    case "false":
      return .false(tokenMeta)
    case "for":
      return .for(tokenMeta)
    case "fun":
      return .fun(tokenMeta)
    case "if":
      return .if(tokenMeta)
    case "nil":
      return .nil(tokenMeta)
    case "or":
      return .or(tokenMeta)
    case "print":
      return .print(tokenMeta)
    case "return":
      return .return(tokenMeta)
    case "super":
      return .super(tokenMeta)
    case "this":
      return .this(tokenMeta)
    case "true":
      return .true(tokenMeta)
    case "var":
      return .var(tokenMeta)
    case "while":
      return .while(tokenMeta)
    default:
      return .identifier(meta)
    }
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
    guard !isAtEnd else { return nil }
    return source[currentIndex]
  }

  private var nextChar: Character? {
    let nextIndex = nthIndex(offsetBy: current + 1)
    guard source.indices.contains(nextIndex) else { return nil }
    return source[nextIndex]
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
  enum Error: Swift.Error, Equatable, LocalizedError {
    case unexpectedCharacter(line: Int, column: Int)
    case unterminatedString(line: Int, column: Int)

    public var errorDescription: String? {
      switch self {
      case .unexpectedCharacter(let line, let col):
        return "Unexpected character at \(line):\(col)"
      case .unterminatedString(let line, let col):
        return "Unterminated string at \(line):\(col)"
      }
    }
  }
}

private let ASCII_0 = Character("0").asciiValue!
private let ASCII_9 = Character("9").asciiValue!
private let ASCII_a = Character("a").asciiValue!
private let ASCII_A = Character("A").asciiValue!
private let ASCII_z = Character("z").asciiValue!
private let ASCII_Z = Character("Z").asciiValue!
private let ASCII_UNDERSCORE = Character("_").asciiValue!

private func isDigit(_ ch: Character?) -> Bool {
  guard let asciiValue = ch?.asciiValue else { return false }
  return asciiValue >= ASCII_0 && asciiValue <= ASCII_9
}

private func isAlpha(_ ch: Character?) -> Bool {
  guard let asciiValue = ch?.asciiValue else { return false }
  return (asciiValue >= ASCII_a && asciiValue <= ASCII_z) ||
    (asciiValue >= ASCII_A && asciiValue <= ASCII_Z) ||
    asciiValue == ASCII_UNDERSCORE
}

private func isAlphaNumeric(_ ch: Character?) -> Bool {
  return isAlpha(ch) || isDigit(ch)
}
