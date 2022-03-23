import LoxAst

private typealias E = Ast.Expression
private typealias S = Ast.Statement

public class Interpreter: ExprVisitor, StmtVisitor {
  private var environment = Environment()

  public init() {}

  public func interpret(_ statements: [Stmt]) -> RuntimeError? {
    do {
      try statements.forEach(execute(_:))
    } catch {
      return error as? RuntimeError
    }
    return nil
  }

  @discardableResult
  public func evaluate(_ expr: Expr) throws -> Object {
    try expr.accept(visitor: self)
  }

  public func visitExpressionStmt(_ stmt: Ast.Statement.Expression) throws {
    try evaluate(stmt.expression)
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

  private func executeBlock(_ statements: [Stmt], environment: Environment) throws {
    let previous = self.environment
    defer { self.environment = previous }
    self.environment = environment
    try statements.forEach { try execute($0) }
  }

  public func visitVarStmt(_ stmt: Ast.Statement.Var) throws {
    if let initializer = stmt.initializer {
      let value = try evaluate(initializer)
      environment.define(name: stmt.name.meta.lexeme, value: .some(value))
    } else {
      environment.define(name: stmt.name.meta.lexeme, value: .some(nil))
    }
  }

  public func visitIfStmt(_ stmt: Ast.Statement.If) throws {
    if try evaluate(stmt.condition).isTruthy {
      try execute(stmt.thenBranch)
    } else if let elseBranch = stmt.elseBranch {
      try execute(elseBranch)
    }
  }

  public func visitVariableExpr(_ expr: Ast.Expression.Variable) throws -> Object {
    try environment.get(expr.name) ?? .nil
  }

  public func visitAssignmentExpr(_ expr: Ast.Expression.Assignment) throws -> Object {
    let value = try evaluate(expr.value)
    try environment.assign(name: expr.name, value: value)
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
