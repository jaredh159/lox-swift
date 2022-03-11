public extension Ast {
  enum Literal: Equatable {
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

extension Ast.Literal: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {
    self = .nil
  }
}

extension Ast.Literal: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self = .number(value)
  }
}

extension Ast.Literal: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int) {
    self = .number(Double(value))
  }
}

extension Ast.Literal: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .string(value)
  }
}

extension Ast.Literal: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    self = .boolean(value)
  }
}
