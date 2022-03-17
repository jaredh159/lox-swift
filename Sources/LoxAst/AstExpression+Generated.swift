// auto-generated, do not edit
import LoxScanner

public protocol ExprVisitor {
  associatedtype ER
  func visitBinaryExpr(_ expr: Ast.Expression.Binary) throws -> ER
  func visitGroupingExpr(_ expr: Ast.Expression.Grouping) throws -> ER
  func visitLiteralExpr(_ expr: Ast.Expression.Literal) throws -> ER
  func visitUnaryExpr(_ expr: Ast.Expression.Unary) throws -> ER
}

public extension Ast.Expression {
  struct Binary: Expr {
    public let left: Expr
    public let `operator`: Token
    public let right: Expr

    public init(left: Expr, operator: Token, right: Expr) {
      self.left = left
      self.operator = `operator`
      self.right = right
    }

    public func accept<V: ExprVisitor>(visitor: V) throws -> V.ER {
      try visitor.visitBinaryExpr(self)
    }
  }

  struct Grouping: Expr {
    public let expression: Expr

    public init(expression: Expr) {
      self.expression = expression
    }

    public func accept<V: ExprVisitor>(visitor: V) throws -> V.ER {
      try visitor.visitGroupingExpr(self)
    }
  }

  struct Literal: Expr {
    public let value: Ast.Literal

    public init(value: Ast.Literal) {
      self.value = value
    }

    public func accept<V: ExprVisitor>(visitor: V) throws -> V.ER {
      try visitor.visitLiteralExpr(self)
    }
  }

  struct Unary: Expr {
    public let `operator`: Token
    public let right: Expr

    public init(operator: Token, right: Expr) {
      self.operator = `operator`
      self.right = right
    }

    public func accept<V: ExprVisitor>(visitor: V) throws -> V.ER {
      try visitor.visitUnaryExpr(self)
    }
  }
} 
