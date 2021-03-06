import Foundation
import LoxAst
import LoxScanner

private typealias E = Ast.Expression
private typealias S = Ast.Statement

public class Resolver: StmtVisitor, ExprVisitor {
  private enum FunctionType: Equatable {
    case none
    case function
    case initializer
    case method
  }

  private enum ClassType: Equatable {
    case none
    case `class`
    case subClass
  }

  private let reportError: (Error) -> Void
  private let interpreter: Interpreter
  private var scopes = Stack<[String: Bool]>()
  private var currentFunction = FunctionType.none
  private var currentClass = ClassType.none

  public init(interpreter: Interpreter, errorHandler: @escaping (Error) -> Void) {
    self.interpreter = interpreter
    reportError = errorHandler
  }

  public func resolve(_ stmts: [Stmt]) throws {
    try stmts.forEach(resolve(_:))
  }

  private func resolve(_ expr: Expr) throws {
    try expr.accept(visitor: self)
  }

  private func resolve(_ stmt: Stmt) throws {
    try stmt.accept(visitor: self)
  }

  private func declare(_ name: Token) {
    guard let scope = scopes.peek else {
      return
    }
    if scope.value[name.lexeme] != nil {
      reportError(.duplicateVariable(
        name: name.lexeme,
        line: name.line,
        col: name.column
      ))
    }
    scope.value[name.lexeme] = false
  }

  private func define(_ name: Token) {
    if let scope = scopes.peek {
      scope.value[name.lexeme] = true
    }
  }

  private func beginScope() {
    scopes.push([:])
  }

  private func beginScope(setting name: String, to value: Bool) {
    scopes.push([name: value])
  }

  private func endScope() {
    scopes.pop()
  }

  public func visitBlockStmt(_ stmt: Ast.Statement.Block) throws {
    beginScope()
    try resolve(stmt.statements)
    endScope()
  }

  public func visitClassStmt(_ stmt: Ast.Statement.Class) throws {
    let enclosingClass = currentClass
    currentClass = .class

    declare(stmt.name)
    define(stmt.name)

    if stmt.superclass?.name.lexeme == stmt.name.lexeme {
      let token = stmt.superclass!.name
      reportError(.selfReferencingInheritance(line: token.line, col: token.column))
    }

    if let superclass = stmt.superclass {
      currentClass = .subClass
      try resolve(superclass)
    }

    if stmt.superclass != nil {
      beginScope(setting: "super", to: true)
    }

    beginScope(setting: "this", to: true)

    for method in stmt.methods {
      let type: FunctionType = method.name.lexeme == "init" ? .initializer : .method
      try resolveFunction(method, type)
    }

    endScope()

    if stmt.superclass != nil {
      endScope()
    }

    currentClass = enclosingClass
  }

  public func visitExpressionStmt(_ stmt: Ast.Statement.Expression) throws {
    try resolve(stmt.expression)
  }

  public func visitFunctionStmt(_ stmt: Ast.Statement.Function) throws {
    declare(stmt.name)
    define(stmt.name)
    try resolveFunction(stmt, .function)
  }

  private func resolveFunction(_ function: Ast.Statement.Function, _ type: FunctionType) throws {
    let enclosingFunction = currentFunction
    currentFunction = type
    beginScope()
    for param in function.params {
      declare(param)
      define(param)
    }
    try resolve(function.body)
    endScope()
    currentFunction = enclosingFunction
  }

  public func visitIfStmt(_ stmt: Ast.Statement.If) throws {
    try resolve(stmt.condition)
    try resolve(stmt.thenBranch)
    try stmt.elseBranch.map { try resolve($0) }
  }

  public func visitPrintStmt(_ stmt: Ast.Statement.Print) throws {
    try resolve(stmt.expression)
  }

  public func visitReturnStmt(_ stmt: Ast.Statement.Return) throws {
    if currentFunction == .none {
      reportError(.topLevelReturn(line: stmt.keyword.line, col: stmt.keyword.column))
    }
    guard let value = stmt.value else {
      return
    }
    if currentFunction == .initializer {
      reportError(.invalidInitializerReturn(line: stmt.keyword.line, col: stmt.keyword.column))
    }
    try resolve(value)
  }

  public func visitVarStmt(_ stmt: Ast.Statement.Var) throws {
    declare(stmt.name)
    try stmt.initializer.map { try resolve($0) }
    define(stmt.name)
  }

  public func visitWhileStmt(_ stmt: Ast.Statement.While) throws {
    try resolve(stmt.condition)
    try resolve(stmt.body)
  }

  public func visitAssignExpr(_ expr: Ast.Expression.Assign) throws {
    try resolve(expr.value)
    resolveLocal(expr: expr, name: expr.name)
  }

  public func visitBinaryExpr(_ expr: Ast.Expression.Binary) throws {
    try resolve(expr.left)
    try resolve(expr.right)
  }

  public func visitCallExpr(_ expr: Ast.Expression.Call) throws {
    try resolve(expr.callee)
    try expr.arguments.forEach { try resolve($0) }
  }

  public func visitGetExpr(_ expr: Ast.Expression.Get) throws {
    try resolve(expr.object)
  }

  public func visitGroupingExpr(_ expr: Ast.Expression.Grouping) throws {
    try resolve(expr.expression)
  }

  public func visitLiteralExpr(_ expr: Ast.Expression.Literal) throws {}

  public func visitLogicalExpr(_ expr: Ast.Expression.Logical) throws {
    try resolve(expr.left)
    try resolve(expr.right)
  }

  public func visitSetExpr(_ expr: Ast.Expression.Set) throws {
    try resolve(expr.value)
    try resolve(expr.object)
  }

  public func visitSuperExpr(_ expr: Ast.Expression.Super) throws {
    if case .none = currentClass {
      reportError(.superOutsideClass(line: expr.keyword.line, col: expr.keyword.column))
    } else if case .class = currentClass {
      reportError(.superNoSuperclass(line: expr.keyword.line, col: expr.keyword.column))
    }
    resolveLocal(expr: expr, name: expr.keyword)
  }

  public func visitThisExpr(_ expr: Ast.Expression.This) throws {
    guard currentClass != .none else {
      reportError(.invalidThisReference(line: expr.keyword.line, col: expr.keyword.column))
      return
    }
    resolveLocal(expr: expr, name: expr.keyword)
  }

  public func visitUnaryExpr(_ expr: Ast.Expression.Unary) throws {
    try resolve(expr.right)
  }

  public func visitVariableExpr(_ expr: Ast.Expression.Variable) throws {
    if let scope = scopes.peek, scope[expr.name.lexeme] == false {
      reportError(.selfReferencingInitializer(
        name: expr.name.lexeme,
        line: expr.name.line,
        col: expr.name.column
      ))
    }
    resolveLocal(expr: expr, name: expr.name)
  }

  private func resolveLocal(expr: Expr, name: Token) {
    for (i, scope) in scopes.items.enumerated().reversed() {
      if scope[name.lexeme] != nil {
        interpreter.resolve(expr: expr, depth: scopes.count - 1 - i)
      }
    }
  }
}

// extensions

public extension Resolver {
  enum Error: Swift.Error, Equatable {
    case selfReferencingInitializer(name: String, line: Int, col: Int)
    case duplicateVariable(name: String, line: Int, col: Int)
    case topLevelReturn(line: Int, col: Int)
    case invalidThisReference(line: Int, col: Int)
    case invalidInitializerReturn(line: Int, col: Int)
    case selfReferencingInheritance(line: Int, col: Int)
    case superOutsideClass(line: Int, col: Int)
    case superNoSuperclass(line: Int, col: Int)
  }
}
