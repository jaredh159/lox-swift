import LoxAst
import LoxScanner

private typealias TokenType = Token.TokenType
private typealias E = Ast.Expression

public class Parser {
  private let reportError: (Error) -> Void
  private var tokens: [Token]
  private var current: Int = 0

  public init(tokens: [Token], onError reportError: @escaping (Error) -> Void) {
    self.tokens = tokens
    self.reportError = reportError
  }

  public func parse() -> Expr? {
    do {
      return try expression()
    } catch {
      return nil
    }
  }

  private func expression() throws -> Expr {
    try equality()
  }

  private func equality() throws -> Expr {
    var expr = try comparison()
    while match(any: .bangEqual, .equalEqual) {
      let op = previous
      let right = try comparison()
      expr = E.Binary(left: expr, operator: op, right: right)
    }
    return expr
  }

  private func comparison() throws -> Expr {
    var expr = try term()
    while match(any: .greater, .greaterEqual, .less, .lessEqual) {
      let op = previous
      let right = try term()
      expr = E.Binary(left: expr, operator: op, right: right)
    }
    return expr
  }

  private func term() throws -> Expr {
    var expr = try factor()
    while match(any: .minus, .plus) {
      let op = previous
      let right = try factor()
      expr = E.Binary(left: expr, operator: op, right: right)
    }
    return expr
  }

  private func factor() throws -> Expr {
    var expr = try unary()
    while match(any: .slash, .star) {
      let op = previous
      let right = try unary()
      expr = E.Binary(left: expr, operator: op, right: right)
    }
    return expr
  }

  private func unary() throws -> Expr {
    if match(any: .bang, .minus) {
      let op = previous
      let right = try unary()
      return E.Unary(operator: op, right: right)
    }
    return try primary()
  }

  private func primary() throws -> Expr {
    if match(.false) { return E.Literal(value: .boolean(false)) }
    if match(.true) { return E.Literal(value: .boolean(true)) }
    if match(.nil) { return E.Literal(value: .nil) }

    if match(any: .number, .string) {
      let token = previous
      switch token {
      case .number(_, let number):
        return E.Literal(value: .number(number))
      case .string(_, let string):
        return E.Literal(value: .string(string))
      default:
        preconditionFailure()
      }
    }

    if match(.leftParen) {
      let expr = try expression()
      try consume(expected: .rightParen)
      return E.Grouping(expression: expr)
    }

    throw error(.expectedExpression(line: peek.meta.line, column: peek.meta.column))
  }

  private func synchronize() {
    advance()

    while !isAtEnd {
      if previous.type == .semicolon { return }
      switch peek.type {
      case .class,
           .fun,
           .var,
           .for,
           .if,
           .while,
           .return:
        return
      default:
        advance()
      }
    }
  }

  private func match(any types: TokenType...) -> Bool {
    for type in types {
      if peekIs(type) {
        advance()
        return true
      }
    }
    return false
  }

  private func match(_ type: TokenType) -> Bool {
    match(any: type)
  }

  private func peekIs(_ type: TokenType) -> Bool {
    guard !isAtEnd else { return false }
    return peek.type == type
  }

  @discardableResult
  private func advance() -> Token {
    if !isAtEnd { current += 1 }
    return previous
  }

  @discardableResult
  private func consume(expected type: TokenType) throws -> Token {
    if peekIs(type) { return advance() }
    let meta = peek.meta
    throw error(.expectedToken(type: type, line: meta.line, column: meta.column))
  }

  private func error(_ error: Error) -> Error {
    reportError(error)
    return error
  }

  private var isAtEnd: Bool {
    peek.type == .eof
  }

  private var peek: Token {
    tokens[current]
  }

  private var previous: Token {
    tokens[current - 1]
  }
}

// extensions

public extension Parser {
  enum Error: Swift.Error {
    case expectedToken(type: Token.TokenType, line: Int, column: Int)
    case expectedExpression(line: Int, column: Int)
  }
}
