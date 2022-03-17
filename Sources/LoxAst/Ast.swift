import LoxScanner

public enum Ast {
  public enum Expression {}
  public enum Statement {}
}

public protocol Expr {
  func accept<V: ExprVisitor>(visitor: V) throws -> V.ER
}

public protocol Stmt {
  func accept<V: StmtVisitor>(visitor: V) throws -> V.SR
}
