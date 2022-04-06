import LoxAst
import LoxScanner

private typealias TokenType = Token.TokenType
private typealias E = Ast.Expression
private typealias S = Ast.Statement

public class Parser {
  private let reportError: (Error) -> Void
  private var tokens: [Token]
  private var current: Int = 0

  enum FunctionKind: String {
    case function
    case method
  }

  public init(tokens: [Token], onError reportError: @escaping (Error) -> Void) {
    self.tokens = tokens
    self.reportError = reportError
  }

  public func parse() -> [Stmt] {
    var statements: [Stmt] = []
    do {
      while !isAtEnd {
        try declaration().map { statements.append($0) }
      }
      return statements
    } catch {
      // @TODO error handling...
      return statements
    }
  }

  private func declaration() throws -> Stmt? {
    do {
      if match(.class) { return try classDeclaration() }
      if match(.fun) { return try function(.function) }
      if match(.var) { return try varDeclaration() }
      return try statement()
    } catch {
      synchronize()
      return nil
    }
  }

  private func classDeclaration() throws -> Stmt {
    let name = try consume(expected: .identifier, "expected class name")
    try consume(expected: .leftBrace, "expected `{` before class body")
    var methods: [S.Function] = []

    while !peekIs(.rightBrace), !isAtEnd {
      methods.append(try function(.method))
    }
    try consume(expected: .rightBrace, "expected `}` after class body")
    return S.Class(name: name, methods: methods)
  }

  private func function(_ kind: FunctionKind) throws -> S.Function {
    let name = try consume(expected: .identifier, "expected \(kind) name")
    try consume(expected: .leftParen, "expected '(' after \(kind) name")
    var parameters: [Token] = []
    if !peekIs(.rightParen) {
      repeat {
        if parameters.count >= 255 {
          error(.excessParameters(line: peek.line, column: peek.column))
        }
        parameters.append(try consume(expected: .identifier, "expected parameter name"))

      } while match(.comma)
    }
    try consume(expected: .rightParen, "expected ')' after parameters")
    try consume(expected: .leftBrace, "expected '{' before \(kind) body")
    let body = try block()
    return S.Function(name: name, params: parameters, body: body)
  }

  private func varDeclaration() throws -> Stmt {
    let name = try consume(expected: .identifier, "expected variable name")
    var initializer: Expr?
    if match(.equal) {
      initializer = try expression()
    }
    try consume(expected: .semicolon, "expected `;` after variable declaration")
    return S.Var(name: name, initializer: initializer)
  }

  private func statement() throws -> Stmt {
    if match(.print) {
      return try printStatement()
    } else if match(.return) {
      return try returnStatement()
    } else if match(.leftBrace) {
      return S.Block(statements: try block())
    } else if match(.if) {
      return try ifStatement()
    } else if match(.while) {
      return try whileStatement()
    } else if match(.for) {
      return try forStatement()
    } else {
      return try expressionStatement()
    }
  }

  private func returnStatement() throws -> Stmt {
    let keyword = previous
    let value: Expr? = peekIs(.semicolon) ? nil : try expression()
    try consume(expected: .semicolon, "expected `;` after return value")
    return S.Return(keyword: keyword, value: value)
  }

  private func forStatement() throws -> Stmt {
    try consume(expected: .leftParen, "expected '(' after 'for'")
    let initializer: Stmt?
    if match(.semicolon) {
      initializer = nil
    } else if match(.var) {
      initializer = try varDeclaration()
    } else {
      initializer = try expressionStatement()
    }

    let condition: Expr?
    if !peekIs(.semicolon) {
      condition = try expression()
    } else {
      condition = nil
    }
    try consume(expected: .semicolon, "expected `;` after loop condition")

    let increment: Expr?
    if !peekIs(.rightParen) {
      increment = try expression()
    } else {
      increment = nil
    }
    try consume(expected: .rightParen, "expected `)` after `for` clauses")

    var body = try statement()
    if let increment = increment {
      body = S.Block(statements: [body, S.Expression(expression: increment)])
    }

    body = S.While(condition: condition ?? E.Literal(value: true), body: body)

    if let initializer = initializer {
      body = S.Block(statements: [initializer, body])
    }

    return body
  }

  private func ifStatement() throws -> Stmt {
    try consume(expected: .leftParen, "expected '(' after 'if'")
    let condition = try expression()
    try consume(expected: .rightParen, "expected ')' after if condition")
    let thenBranch = try statement()
    var elseBranch: Stmt?
    if match(.else) {
      elseBranch = try statement()
    }
    return S.If(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
  }

  private func whileStatement() throws -> Stmt {
    try consume(expected: .leftParen, "expected '(' after 'while'")
    let condition = try expression()
    try consume(expected: .rightParen, "expected ')' after condition")
    let body = try statement()
    return S.While(condition: condition, body: body)
  }

  private func block() throws -> [Stmt] {
    var statements: [Stmt] = []
    while !peekIs(.rightBrace), !isAtEnd, let decl = try declaration() {
      statements.append(decl)
    }
    try consume(expected: .rightBrace, "expected `}` after block")
    return statements
  }

  private func printStatement() throws -> Stmt {
    let value = try expression()
    try consume(expected: .semicolon, "expected `;` after value")
    return S.Print(expression: value)
  }

  private func expressionStatement() throws -> Stmt {
    let expr = try expression()
    try consume(expected: .semicolon, "expected `;` after expression")
    return S.Expression(expression: expr)
  }

  private func expression() throws -> Expr {
    try assignment()
  }

  private func assignment() throws -> Expr {
    let expr = try or()
    if match(.equal) {
      let equals = previous
      let value = try assignment()
      if let varExpr = expr as? E.Variable {
        return E.Assign(name: varExpr.name, value: value)
      } else if let getExpr = expr as? E.Get {
        return E.Set(object: getExpr.object, name: getExpr.name, value: value)
      } else {
        error(.invalidAssignmentTarget(line: equals.line, column: equals.column))
      }
    }
    return expr
  }

  private func or() throws -> Expr {
    var expr = try and()
    while match(.or) {
      let op = previous
      let rhs = try and()
      expr = E.Logical(left: expr, operator: op, right: rhs)
    }
    return expr
  }

  private func and() throws -> Expr {
    var expr = try equality()
    while match(.and) {
      let op = previous
      let rhs = try equality()
      expr = E.Logical(left: expr, operator: op, right: rhs)
    }
    return expr
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
    return try call()
  }

  private func call() throws -> Expr {
    var expr = try primary()
    while true {
      if match(.leftParen) {
        expr = try finishCall(expr)
      } else if match(.dot) {
        let name = try consume(expected: .identifier, "expected property name after `.`")
        expr = E.Get(object: expr, name: name)
      } else {
        break
      }
    }
    return expr
  }

  private func finishCall(_ callee: Expr) throws -> Expr {
    var arguments: [Expr] = []
    if !peekIs(.rightParen) {
      repeat {
        if arguments.count >= 255 {
          error(.excessArguments(line: peek.line, column: peek.column))
        }
        arguments.append(try expression())
      } while match(.comma)
    }
    let paren = try consume(expected: .rightParen, "expected `)` after arguments")
    return E.Call(callee: callee, paren: paren, arguments: arguments)
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

    if match(.identifier) {
      return E.Variable(name: previous)
    }

    if match(.leftParen) {
      let expr = try expression()
      try consume(expected: .rightParen, "expected `)` after grouped expression")
      return E.Grouping(expression: expr)
    }

    throw error(.expectedExpression(line: peek.line, column: peek.column))
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

  // Bob calls this `check()`
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
  private func consume(expected type: TokenType, _ message: String) throws -> Token {
    if peekIs(type) { return advance() }
    throw error(.expectedToken(type: type, message: message, line: peek.line, column: peek.column))
  }

  @discardableResult
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
    case expectedToken(type: Token.TokenType, message: String, line: Int, column: Int)
    case expectedExpression(line: Int, column: Int)
    case invalidAssignmentTarget(line: Int, column: Int)
    case excessParameters(line: Int, column: Int)
    case excessArguments(line: Int, column: Int)
  }
}
