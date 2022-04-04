// auto-generated, do not edit
import Foundation
import LoxScanner

public protocol ExprVisitor {
  associatedtype ER
  func visitAssignExpr(_ expr: Ast.Expression.Assign) throws -> ER
  func visitBinaryExpr(_ expr: Ast.Expression.Binary) throws -> ER
  func visitCallExpr(_ expr: Ast.Expression.Call) throws -> ER
  func visitGroupingExpr(_ expr: Ast.Expression.Grouping) throws -> ER
  func visitLiteralExpr(_ expr: Ast.Expression.Literal) throws -> ER
  func visitLogicalExpr(_ expr: Ast.Expression.Logical) throws -> ER
  func visitUnaryExpr(_ expr: Ast.Expression.Unary) throws -> ER
  func visitVariableExpr(_ expr: Ast.Expression.Variable) throws -> ER
}

public extension Ast.Expression {
  struct Assign: Expr {
    public let id = UUID()
    public let name: Token
    public let value: Expr

    public init(name: Token, value: Expr) {
      self.name = name
      self.value = value
    }

    public func accept<V: ExprVisitor>(visitor: V) throws -> V.ER {
      try visitor.visitAssignExpr(self)
    }
  }

  struct Binary: Expr {
    public let id = UUID()
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

  struct Call: Expr {
    public let id = UUID()
    public let callee: Expr
    public let paren: Token
    public let arguments: [Expr]

    public init(callee: Expr, paren: Token, arguments: [Expr]) {
      self.callee = callee
      self.paren = paren
      self.arguments = arguments
    }

    public func accept<V: ExprVisitor>(visitor: V) throws -> V.ER {
      try visitor.visitCallExpr(self)
    }
  }

  struct Grouping: Expr {
    public let id = UUID()
    public let expression: Expr

    public init(expression: Expr) {
      self.expression = expression
    }

    public func accept<V: ExprVisitor>(visitor: V) throws -> V.ER {
      try visitor.visitGroupingExpr(self)
    }
  }

  struct Literal: Expr {
    public let id = UUID()
    public let value: Ast.Literal

    public init(value: Ast.Literal) {
      self.value = value
    }

    public func accept<V: ExprVisitor>(visitor: V) throws -> V.ER {
      try visitor.visitLiteralExpr(self)
    }
  }

  struct Logical: Expr {
    public let id = UUID()
    public let left: Expr
    public let `operator`: Token
    public let right: Expr

    public init(left: Expr, operator: Token, right: Expr) {
      self.left = left
      self.operator = `operator`
      self.right = right
    }

    public func accept<V: ExprVisitor>(visitor: V) throws -> V.ER {
      try visitor.visitLogicalExpr(self)
    }
  }

  struct Unary: Expr {
    public let id = UUID()
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

  struct Variable: Expr {
    public let id = UUID()
    public let name: Token

    public init(name: Token) {
      self.name = name
    }

    public func accept<V: ExprVisitor>(visitor: V) throws -> V.ER {
      try visitor.visitVariableExpr(self)
    }
  }
} 
