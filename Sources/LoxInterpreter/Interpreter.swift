import LoxAst

private typealias E = Ast.Expression

public class Interpreter: ExprVisitor {
  public init() {}

  public func evaluate(_ expr: Expr) -> Object {
    expr.accept(visitor: self)
  }

  public func visitBinary(_ expr: Ast.Expression.Binary) -> Object {
    let lhs = evaluate(expr.left)
    let rhs = evaluate(expr.right)
    switch (lhs, expr.operator, rhs) {

    // string concatenation
    case (.literal(.string(let left)), .plus, .literal(.string(let right))):
      return .literal(.string(left + right))

    // numeric operations
    case (.literal(.number(let left)), let op, .literal(.number(let right))):
      switch op {
      case .minus:
        return .literal(.number(left - right))
      case .slash:
        return .literal(.number(left / right))
      case .star:
        return .literal(.number(left * right))
      case .plus:
        return .literal(.number(left + right))
      }

    // parser should prevent ever getting here, methinks
    default:
      preconditionFailure()
    }
  }

  public func visitGrouping(_ expr: Ast.Expression.Grouping) -> Object {
    evaluate(expr.expression)
  }

  public func visitLiteral(_ expr: Ast.Expression.Literal) -> Object {
    .literal(expr.value)
  }

  public func visitUnary(_ expr: Ast.Expression.Unary) -> Object {
    let right = evaluate(expr.right)
    switch (expr.operator, right) {
    case (.minus, .literal(.number(let number))):
      return .literal(.number(-number))
    case (.bang, let object):
      return .literal(.boolean(!object.isTruthy))
    default:
      preconditionFailure()
    }
  }
}
