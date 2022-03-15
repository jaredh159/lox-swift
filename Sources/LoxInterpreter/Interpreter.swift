import LoxAst

private typealias E = Ast.Expression

public class Interpreter: ExprVisitor {
  public init() {}

  public func interpret(_ expr: Expr) -> Result<Object, RuntimeError> {
    do {
      return .success(try evaluate(expr))
    } catch {
      return .failure(error as! RuntimeError)
    }
  }

  public func evaluate(_ expr: Expr) throws -> Object {
    try expr.accept(visitor: self)
  }

  public func visitBinary(_ expr: Ast.Expression.Binary) throws -> Object {
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

  public func visitGrouping(_ expr: Ast.Expression.Grouping) throws -> Object {
    try evaluate(expr.expression)
  }

  public func visitLiteral(_ expr: Ast.Expression.Literal) throws -> Object {
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

  public func visitUnary(_ expr: Ast.Expression.Unary) throws -> Object {
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
}