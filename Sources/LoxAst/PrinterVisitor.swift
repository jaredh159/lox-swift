import Foundation

public extension Ast {
  struct PrinterVisitor: ExprVisitor {
    public init() {}

    public func eval(_ expr: Expr) throws -> String {
      try expr.accept(visitor: self)
    }

    public func print(_ expr: Expr) {
      do {
        let result = try eval(expr)
        Swift.print(result)
      } catch {
        Swift.print(error)
      }
    }

    public func visitBinaryExpr(_ expr: Ast.Expression.Binary) throws -> String {
      try parenthesize(name: expr.operator.meta.lexeme, expr.left, expr.right)
    }

    public func visitGroupingExpr(_ expr: Ast.Expression.Grouping) throws -> String {
      try parenthesize(name: "group", expr.expression)
    }

    public func visitLiteralExpr(_ expr: Ast.Expression.Literal) throws -> String {
      expr.value.string
    }

    public func visitUnaryExpr(_ expr: Ast.Expression.Unary) throws -> String {
      try parenthesize(name: expr.operator.meta.lexeme, expr.right)
    }

    func parenthesize(name: String, _ exprs: Expr...) throws -> String {
      "(\(name) \(try exprs.map { try $0.accept(visitor: self) }.joined(separator: " ")))"
    }
  }
}
