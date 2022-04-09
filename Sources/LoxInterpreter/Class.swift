import Foundation
import LoxScanner

public class LoxClass: Callable {
  public let id = UUID().uuidString
  public let name: String
  public let superclass: LoxClass?
  private var methods: [String: UserFunction]

  public var toString: String {
    name
  }

  public var arity: Int {
    find(method: "init")?.arity ?? 0
  }

  public init(name: String, superclass: LoxClass?, methods: [String: UserFunction]) {
    self.name = name
    self.superclass = superclass
    self.methods = methods
  }

  public func find(method name: String) -> UserFunction? {
    methods[name] ?? superclass?.find(method: name)
  }

  public func call(
    _ interpreter: Interpreter,
    arguments: [Object],
    token: Token
  ) throws -> Object {
    let instance = Instance(class: self)
    if let initializer = find(method: "init") {
      _ = try initializer
        .bind(to: instance)
        .call(interpreter, arguments: arguments, token: token)
    }
    return .instance(instance)
  }
}
