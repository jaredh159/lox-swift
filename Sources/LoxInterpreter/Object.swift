import LoxAst

public enum Object {
  case string(String)
  case number(Double)
  case boolean(Bool)
  case callable(Callable)
  case instance(Instance)
  case `class`(LoxClass)
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
    case .callable(let callable):
      return callable.toString.onMagenta
    case .class(let klass):
      return "\("class".dim) \(klass.toString.onLightBlue)"
    case .instance(let instance):
      return "\("instance of".dim) \(instance.class.name.black.onLightGreen)"
    case .nil:
      return "nil".magenta
    }
  }
}

// extensions

extension Object: Equatable {
  public static func == (lhs: Object, rhs: Object) -> Bool {
    switch (lhs, rhs) {
    case (.string(let a), .string(let b)):
      return a == b
    case (.number(let a), .number(let b)):
      return a == b
    case (.boolean(let a), .boolean(let b)):
      return a == b
    case (.class(let a), .class(let b)):
      return a === b
    case (.instance(let a), .instance(let b)):
      return a === b
    case (.callable(let a), .callable(let b)):
      return a.id == b.id
    case (.nil, .nil):
      return true
    default:
      return false
    }
  }
}

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
