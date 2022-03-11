import Foundation

public extension Ast {
  struct PrinterVisitor: ExprVisitor {
    public init() {}

    public func eval(_ expr: Expr) -> String {
      expr.accept(visitor: self)
    }

    public func print(_ expr: Expr) {
      Swift.print(eval(expr))
    }

    public func visitBinary(_ expr: Ast.Expression.Binary) -> String {
      parenthesize(name: expr.operator.token.meta.lexeme, expr.left, expr.right)
    }

    public func visitGrouping(_ expr: Ast.Expression.Grouping) -> String {
      parenthesize(name: "group", expr.expression)
    }

    public func visitLiteral(_ expr: Ast.Expression.Literal) -> String {
      expr.value.string
    }

    public func visitUnary(_ expr: Ast.Expression.Unary) -> String {
      parenthesize(name: expr.operator.token.meta.lexeme, expr.right)
    }

    func parenthesize(name: String, _ exprs: Expr...) -> String {
      "(\(name) \(exprs.map { $0.accept(visitor: self) }.joined(separator: " ")))"
    }
  }
}
