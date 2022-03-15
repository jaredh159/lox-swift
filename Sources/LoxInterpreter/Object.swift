import LoxAst

public enum Object: Equatable {
  case string(String)
  case number(Double)
  case boolean(Bool)
  case `nil`

  public var isTruthy: Bool {
    switch self {
    case .nil:
      return false
    case .boolean(false):
      return false
    default:
      return true
    }
  }

  public var toString: String {
    switch self {
    case .string(let str):
      return #""\#(str)""#.green
    case .number(let num):
      return String(num)
        .replacingOccurrences(of: #"\.0+$"#, with: "", options: .regularExpression)
        .yellow
    case .boolean(let bool):
      return String(bool).cyan
    case .nil:
      return "nil".magenta
    }
  }
}

// extensions

extension Object: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {
    self = .nil
  }
}

extension Object: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self = .number(value)
  }
}

extension Object: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int) {
    self = .number(Double(value))
  }
}

extension Object: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .string(value)
  }
}

extension Object: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    self = .boolean(value)
  }
}
