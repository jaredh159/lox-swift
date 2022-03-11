// auto-generated, do not edit
import LoxScanner

public protocol ExprVisitor {
  associatedtype R
  func visitBinary(_ expr: Ast.Expression.Binary) -> R
  func visitGrouping(_ expr: Ast.Expression.Grouping) -> R
  func visitLiteral(_ expr: Ast.Expression.Literal) -> R
  func visitUnary(_ expr: Ast.Expression.Unary) -> R
}

public enum Ast {
  public enum Expression {
    public struct Binary: Expr {
      public let left: Expr
      public let `operator`: Operator
      public let right: Expr

      public init(left: Expr, operator: Operator, right: Expr) {
        self.left = left
        self.operator = `operator`
        self.right = right
      }

      public func accept<V: ExprVisitor>(visitor: V) -> V.R {
        return visitor.visitBinary(self)
      }
    }

    public struct Grouping: Expr {
      public let expression: Expr

      public init(expression: Expr) {
        self.expression = expression
      }

      public func accept<V: ExprVisitor>(visitor: V) -> V.R {
        return visitor.visitGrouping(self)
      }
    }

    public struct Literal: Expr {
      public let value: Ast.Literal

      public init(value: Ast.Literal) {
        self.value = value
      }

      public func accept<V: ExprVisitor>(visitor: V) -> V.R {
        return visitor.visitLiteral(self)
      }
    }

    public struct Unary: Expr {
      public let `operator`: Operator
      public let right: Expr

      public init(operator: Operator, right: Expr) {
        self.operator = `operator`
        self.right = right
      }

      public func accept<V: ExprVisitor>(visitor: V) -> V.R {
        return visitor.visitUnary(self)
      }
    }
  }
}
