import Foundation

public extension Ast {
  class RpnVisitor: ExprVisitor {
    private var stack: [String] = []

    public init() {}

    public func eval(_ expr: Expr) throws -> String {
      try expr.accept(visitor: self)
      return stack.joined(separator: " ")
    }

    public func visitBinary(_ expr: Ast.Expression.Binary) throws {
      try expr.left.accept(visitor: self)
      try expr.right.accept(visitor: self)
      stack.append(expr.operator.meta.lexeme)
    }

    public func visitGrouping(_ expr: Ast.Expression.Grouping) throws {
      try expr.expression.accept(visitor: self)
    }

    public func visitLiteral(_ expr: Ast.Expression.Literal) throws {
      stack.append(expr.value.string)
    }

    public func visitUnary(_ expr: Ast.Expression.Unary) throws {
      try expr.right.accept(visitor: self)
    }
  }
}
