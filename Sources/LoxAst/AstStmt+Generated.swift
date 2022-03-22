// auto-generated, do not edit
import LoxScanner

public protocol StmtVisitor {
  associatedtype SR
  func visitBlockStmt(_ stmt: Ast.Statement.Block) throws -> SR
  func visitExpressionStmt(_ stmt: Ast.Statement.Expression) throws -> SR
  func visitIfStmt(_ stmt: Ast.Statement.If) throws -> SR
  func visitPrintStmt(_ stmt: Ast.Statement.Print) throws -> SR
  func visitVarStmt(_ stmt: Ast.Statement.Var) throws -> SR
}

public extension Ast.Statement {
  struct Block: Stmt {
    public let statements: [Stmt]

    public init(statements: [Stmt]) {
      self.statements = statements
    }

    public func accept<V: StmtVisitor>(visitor: V) throws -> V.SR {
      try visitor.visitBlockStmt(self)
    }
  }

  struct Expression: Stmt {
    public let expression: Expr

    public init(expression: Expr) {
      self.expression = expression
    }

    public func accept<V: StmtVisitor>(visitor: V) throws -> V.SR {
      try visitor.visitExpressionStmt(self)
    }
  }

  struct If: Stmt {
    public let condition: Expr
    public let thenBranch: Stmt
    public let elseBranch: Stmt?

    public init(condition: Expr, thenBranch: Stmt, elseBranch: Stmt?) {
      self.condition = condition
      self.thenBranch = thenBranch
      self.elseBranch = elseBranch
    }

    public func accept<V: StmtVisitor>(visitor: V) throws -> V.SR {
      try visitor.visitIfStmt(self)
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

  struct Var: Stmt {
    public let name: Token
    public let initializer: Expr?

    public init(name: Token, initializer: Expr?) {
      self.name = name
      self.initializer = initializer
    }

    public func accept<V: StmtVisitor>(visitor: V) throws -> V.SR {
      try visitor.visitVarStmt(self)
    }
  }
} 
