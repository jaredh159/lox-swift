public protocol Expr {
  func accept<V: ExprVisitor>(visitor: V) -> V.R
}
