import Foundation

public extension Ast {
  class RpnVisitor: ExprVisitor {
    private var stack: [String] = []

    public init() {}

    public func eval(_ expr: Expr) -> String {
      expr.accept(visitor: self)
      return stack.joined(separator: " ")
    }

    public func visitBinary(_ expr: Ast.Expression.Binary) {
      expr.left.accept(visitor: self)
      expr.right.accept(visitor: self)
      stack.append(expr.operator.token.meta.lexeme)
    }

    public func visitGrouping(_ expr: Ast.Expression.Grouping) {
      expr.expression.accept(visitor: self)
    }

    public func visitLiteral(_ expr: Ast.Expression.Literal) {
      stack.append(expr.value.string)
    }

    public func visitUnary(_ expr: Ast.Expression.Unary) {
      expr.right.accept(visitor: self)
    }
  }
}
