// auto-generated, do not edit
import LoxScanner

public protocol StmtVisitor {
  associatedtype SR
  func visitExpressionStmt(_ stmt: Ast.Statement.Expression) throws -> SR
  func visitPrintStmt(_ stmt: Ast.Statement.Print) throws -> SR
}

public extension Ast.Statement {
  struct Expression: Stmt {
    public let expression: Expr

    public init(expression: Expr) {
      self.expression = expression
    }

    public func accept<V: StmtVisitor>(visitor: V) throws -> V.SR {
      try visitor.visitExpressionStmt(self)
    }
  }

  struct Print: Stmt {
    public let expression: Expr

    public init(expression: Expr) {
      self.expression = expression
    }

    public func accept<V: StmtVisitor>(visitor: V) throws -> V.SR {
      try visitor.visitPrintStmt(self)
    }
  }
} 
