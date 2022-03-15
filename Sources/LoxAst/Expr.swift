import LoxScanner

public protocol Expr {
  func accept<V: ExprVisitor>(visitor: V) throws -> V.R
}
