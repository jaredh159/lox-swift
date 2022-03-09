public protocol Expr {
  func accept<V: ExprVisitor>(visitor: V) -> V.R
}

public extension Ast.Expression.Literal {
  enum Value: Equatable {
    case string(String)
    case number(Double)
    case boolean(Bool)
    case `nil`

    var string: String {
      switch self {
      case .string(let str):
        return str
      case .number(let num):
        return String(num)
          .replacingOccurrences(of: #"\.0+$"#, with: "", options: .regularExpression)
      case .boolean(let bool):
        return String(bool)
      case .nil:
        return "nil"
      }
    }
  }
}
