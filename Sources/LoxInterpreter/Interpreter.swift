import Foundation
import LoxAst
import LoxScanner

private typealias E = Ast.Expression
private typealias S = Ast.Statement

public class Interpreter: ExprVisitor, StmtVisitor {
  public var globals = Environment()
  private var environment: Environment
  private var locals: [UUID: Int] = [:]

  public init() {
    environment = globals
    globals.define(name: "assertEqual", value: .callable(AssertEqual()))
    globals.define(name: "clock", value: .callable(Clock()))
  }

  public func interpret(_ statements: [Stmt]) -> RuntimeError? {
    do {
      try statements.forEach(execute(_:))
    } catch {
      return error as? RuntimeError
    }
    return nil
  }

  public func resolve(expr: Expr, depth: Int) {
    locals[expr.id] = depth
  }

  @discardableResult
  public func evaluate(_ expr: Expr) throws -> Object {
    try expr.accept(visitor: self)
  }

  public func visitExpressionStmt(_ stmt: Ast.Statement.Expression) throws {
    try evaluate(stmt.expression)
  }

  public func visitClassStmt(_ stmt: Ast.Statement.Class) throws {
    var superclass: LoxClass?
    if let stmtSuperclass = stmt.superclass {
      let superObj = try evaluate(stmtSuperclass)
      if case .class(let klass) = superObj {
        superclass = klass
      } else {
        throw RuntimeError(.invalidSuperclass(stmtSuperclass.name.lexeme), stmtSuperclass.name)
      }
    }

    environment.define(name: stmt.name.lexeme, value: nil)
    if let superclass = superclass {
      environment = Environment(enclosing: environment)
      environment.define(name: "super", value: .class(superclass))
    }

    var methods: [String: UserFunction] = [:]
    for method in stmt.methods {
      methods[method.name.lexeme] = UserFunction(
        method,
        environment: environment,
        isInitializer: method.name.lexeme == "init"
      )
    }

    let klass = LoxClass(name: stmt.name.lexeme, superclass: superclass, methods: methods)
    if superclass != nil, let enclosing = environment.enclosing {
      environment = enclosing
    }

    try environment.assign(name: stmt.name, value: .class(klass))
  }

  public func visitPrintStmt(_ stmt: Ast.Statement.Print) throws {
    let value = try evaluate(stmt.expression)
    print(value.toString)
  }

  public func visitBlockStmt(_ stmt: Ast.Statement.Block) throws {
    try executeBlock(stmt.statements, environment: Environment(enclosing: environment))
  }

  public func visitWhileStmt(_ stmt: Ast.Statement.While) throws {
    while try evaluate(stmt.condition).isTruthy {
      try execute(stmt.body)
    }
  }

  public func executeBlock(_ statements: [Stmt], environment: Environment) throws {
    let previous = self.environment
    defer { self.environment = previous }
    self.environment = environment
    try statements.forEach { try execute($0) }
  }

  public func visitVarStmt(_ stmt: Ast.Statement.Var) throws {
    if let initializer = stmt.initializer {
      let value = try evaluate(initializer)
      environment.define(name: stmt.name.lexeme, value: .some(value))
    } else {
      environment.define(name: stmt.name.lexeme, value: .some(nil))
    }
  }

  public func visitIfStmt(_ stmt: Ast.Statement.If) throws {
    if try evaluate(stmt.condition).isTruthy {
      try execute(stmt.thenBranch)
    } else if let elseBranch = stmt.elseBranch {
      try execute(elseBranch)
    }
  }

  public func visitFunctionStmt(_ stmt: Ast.Statement.Function) throws {
    let function = UserFunction(stmt, environment: environment)
    environment.define(name: stmt.name.lexeme, value: .callable(function))
  }

  public func visitReturnStmt(_ stmt: Ast.Statement.Return) throws {
    let value: Object?
    if let stmtValue = stmt.value {
      value = try evaluate(stmtValue)
    } else {
      value = nil
    }
    throw Return(value: value)
  }

  public func visitVariableExpr(_ expr: Ast.Expression.Variable) throws -> Object {
    try lookupVariable(name: expr.name, expr: expr) ?? nil
  }

  private func lookupVariable(name: Token, expr: Expr) throws -> Object? {
    if let distance = locals[expr.id] {
      return environment.get(at: distance, name.lexeme)
    } else {
      return try globals.get(name)
    }
  }

  public func visitCallExpr(_ expr: Ast.Expression.Call) throws -> Object {
    let callee = try evaluate(expr.callee)
    var arguments: [Object] = []
    for argument in expr.arguments {
      arguments.append(try evaluate(argument))
    }
    switch callee {
    case .callable(let callable):
      return try callable.call(self, arguments: arguments, token: expr.paren)
    case .class(let constructor):
      return try constructor.call(self, arguments: arguments, token: expr.paren)
    default:
      throw RuntimeError(.invalidCallable, expr.paren)
    }
  }

  public func visitGetExpr(_ expr: Ast.Expression.Get) throws -> Object {
    let object = try evaluate(expr.object)
    guard case .instance(let instance) = object else {
      throw RuntimeError(.invalidPropertyAccess, expr.name)
    }
    return try instance.get(name: expr.name)
  }

  public func visitAssignExpr(_ expr: Ast.Expression.Assign) throws -> Object {
    let value = try evaluate(expr.value)
    if let distance = locals[expr.id] {
      environment.assign(at: distance, name: expr.name, value: value)
    } else {
      try globals.assign(name: expr.name, value: value)
    }
    return value
  }

  public func visitLogicalExpr(_ expr: Ast.Expression.Logical) throws -> Object {
    let lhs = try evaluate(expr.left)
    if expr.operator.type == .or {
      if lhs.isTruthy { return lhs }
    } else if !lhs.isTruthy {
      return lhs
    }
    return try evaluate(expr.right)
  }

  public func visitSetExpr(_ expr: Ast.Expression.Set) throws -> Object {
    let object = try evaluate(expr.object)
    guard case .instance(let instance) = object else {
      throw RuntimeError(.invalidPropertyAccess, expr.name)
    }
    let value = try evaluate(expr.value)
    instance.set(name: expr.name, value: value)
    return value
  }

  public func visitSuperExpr(_ expr: Ast.Expression.Super) throws -> Object {
    guard let distance = locals[expr.id],
          let superObj = environment.get(at: distance, "super"),
          case .class(let superclass) = superObj,
          let instanceObj = environment.get(at: distance - 1, "this"),
          case .instance(let instance) = instanceObj else {
      preconditionFailure()
    }

    guard let method = superclass.find(method: expr.method.lexeme) else {
      throw RuntimeError(.undefinedProperty, expr.method)
    }

    return .callable(method.bind(to: instance))
  }

  public func visitThisExpr(_ expr: Ast.Expression.This) throws -> Object {
    try lookupVariable(name: expr.keyword, expr: expr) ?? nil
  }

  public func visitBinaryExpr(_ expr: Ast.Expression.Binary) throws -> Object {
    let lhs = try evaluate(expr.left)
    let rhs = try evaluate(expr.right)
    switch (lhs, expr.operator, rhs) {

    case (.string(let left), .plus, .string(let right)):
      return .string(left + right)

    case (let left, .bangEqual, let right):
      return .boolean(left != right)

    case (let left, .equalEqual, let right):
      return .boolean(left == right)

    case (.number(let left), let op, .number(let right)):
      switch op {
      case .minus:
        return .number(left - right)
      case .slash:
        return .number(left / right)
      case .star:
        return .number(left * right)
      case .plus:
        return .number(left + right)
      case .greater:
        return .boolean(left > right)
      case .greaterEqual:
        return .boolean(left >= right)
      case .less:
        return .boolean(left < right)
      case .lessEqual:
        return .boolean(left <= right)
      default:
        preconditionFailure()
      }

    default:
      throw RuntimeError(
        .invalidBinaryOperands(lhs: lhs, operator: expr.operator.type, rhs: rhs),
        expr.operator
      )
    }
  }

  public func visitGroupingExpr(_ expr: Ast.Expression.Grouping) throws -> Object {
    try evaluate(expr.expression)
  }

  public func visitLiteralExpr(_ expr: Ast.Expression.Literal) throws -> Object {
    switch expr.value {
    case .string(let str):
      return .string(str)
    case .number(let num):
      return .number(num)
    case .boolean(let bool):
      return .boolean(bool)
    case .nil:
      return nil
    }
  }

  public func visitUnaryExpr(_ expr: Ast.Expression.Unary) throws -> Object {
    let right = try evaluate(expr.right)
    switch (expr.operator, right) {
    case (.minus, .number(let number)):
      return .number(-number)
    case (.minus, let rhs):
      throw RuntimeError(.invalidUnaryMinusOperand(rhs), expr.operator)
    case (.bang, let object):
      return .boolean(!object.isTruthy)
    default:
      preconditionFailure()
    }
  }

  private func execute(_ statement: Stmt) throws {
    try statement.accept(visitor: self)
  }
}

struct Return: Error {
  let value: Object?
}
