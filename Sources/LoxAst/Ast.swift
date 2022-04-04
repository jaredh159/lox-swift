import Foundation
import LoxScanner

public enum Ast {
  public enum Expression {}
  public enum Statement {}
}

public protocol Expr {
  var id: UUID { get }
  func accept<V: ExprVisitor>(visitor: V) throws -> V.ER
}

public protocol Stmt {
  var id: UUID { get }
  func accept<V: StmtVisitor>(visitor: V) throws -> V.SR
}
