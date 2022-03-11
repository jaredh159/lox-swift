import LoxAst

public enum Object: Equatable {
  case literal(Ast.Literal)

  var isTruthy: Bool {
    switch self {
    case .literal(.nil):
      return false
    case .literal(.boolean(false)):
      return false
    default:
      return true
    }
  }
}
