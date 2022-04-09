// auto-generated, do not edit
import Foundation
import LoxScanner

public protocol StmtVisitor {
  associatedtype SR
  func visitBlockStmt(_ stmt: Ast.Statement.Block) throws -> SR
  func visitClassStmt(_ stmt: Ast.Statement.Class) throws -> SR
  func visitExpressionStmt(_ stmt: Ast.Statement.Expression) throws -> SR
  func visitFunctionStmt(_ stmt: Ast.Statement.Function) throws -> SR
  func visitIfStmt(_ stmt: Ast.Statement.If) throws -> SR
  func visitPrintStmt(_ stmt: Ast.Statement.Print) throws -> SR
  func visitReturnStmt(_ stmt: Ast.Statement.Return) throws -> SR
  func visitVarStmt(_ stmt: Ast.Statement.Var) throws -> SR
  func visitWhileStmt(_ stmt: Ast.Statement.While) throws -> SR
}

public extension Ast.Statement {
  struct Block: Stmt {
    public let id = UUID()
    public let statements: [Stmt]

    public init(statements: [Stmt]) {
      self.statements = statements
    }

    public func accept<V: StmtVisitor>(visitor: V) throws -> V.SR {
      try visitor.visitBlockStmt(self)
    }
  }

  struct Class: Stmt {
    public let id = UUID()
    public let name: Token
    public let superclass: Ast.Expression.Variable?
    public let methods: [Ast.Statement.Function]

    public init(name: Token, superclass: Ast.Expression.Variable?, methods: [Ast.Statement.Function]) {
      self.name = name
      self.superclass = superclass
      self.methods = methods
    }

    public func accept<V: StmtVisitor>(visitor: V) throws -> V.SR {
      try visitor.visitClassStmt(self)
    }
  }

  struct Expression: Stmt {
    public let id = UUID()
    public let expression: Expr

    public init(expression: Expr) {
      self.expression = expression
    }

    public func accept<V: StmtVisitor>(visitor: V) throws -> V.SR {
      try visitor.visitExpressionStmt(self)
    }
  }

  struct Function: Stmt {
    public let id = UUID()
    public let name: Token
    public let params: [Token]
    public let body: [Stmt]

    public init(name: Token, params: [Token], body: [Stmt]) {
      self.name = name
      self.params = params
      self.body = body
    }

    public func accept<V: StmtVisitor>(visitor: V) throws -> V.SR {
      try visitor.visitFunctionStmt(self)
    }
  }

  struct If: Stmt {
    public let id = UUID()
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
    public let id = UUID()
    public let expression: Expr

    public init(expression: Expr) {
      self.expression = expression
    }

    public func accept<V: StmtVisitor>(visitor: V) throws -> V.SR {
      try visitor.visitPrintStmt(self)
    }
  }

  struct Return: Stmt {
    public let id = UUID()
    public let keyword: Token
    public let value: Expr?

    public init(keyword: Token, value: Expr?) {
      self.keyword = keyword
      self.value = value
    }

    public func accept<V: StmtVisitor>(visitor: V) throws -> V.SR {
      try visitor.visitReturnStmt(self)
    }
  }

  struct Var: Stmt {
    public let id = UUID()
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

  struct While: Stmt {
    public let id = UUID()
    public let condition: Expr
    public let body: Stmt

    public init(condition: Expr, body: Stmt) {
      self.condition = condition
      self.body = body
    }

    public func accept<V: StmtVisitor>(visitor: V) throws -> V.SR {
      try visitor.visitWhileStmt(self)
    }
  }
} 
