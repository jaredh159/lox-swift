import LoxScanner

public protocol Expr {
  func accept<V: ExprVisitor>(visitor: V) -> V.R
}

public protocol TokenSubset {
  var token: Token { get }
  init?(from token: Token)
}

public extension Ast.Expression.Unary {
  enum Operator: TokenSubset, Equatable {
    case bang(Token)
    case minus(Token)

    public var token: Token {
      switch self {
      case .bang(let token), .minus(let token):
        return token
      }
    }

    public init?(from token: Token) {
      switch token.type {
      case .bang:
        self = .bang(token)
      case .minus:
        self = .minus(token)
      default:
        return nil
      }
    }
  }
}

public extension Ast.Expression.Binary {
  enum Operator: TokenSubset, Equatable {
    case minus(Token)
    case slash(Token)
    case star(Token)
    case plus(Token)

    public var token: Token {
      switch self {
      case .minus(let token),
           .plus(let token),
           .slash(let token),
           .star(let token):
        return token
      }
    }

    public init?(from token: Token) {
      switch token.type {
      case .minus:
        self = .minus(token)
      case .plus:
        self = .plus(token)
      case .slash:
        self = .slash(token)
      case .star:
        self = .star(token)
      default:
        return nil
      }
    }
  }
}
