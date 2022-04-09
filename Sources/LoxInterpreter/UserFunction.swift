import Foundation
import LoxAst
import LoxScanner

public struct UserFunction: Callable {
  public let id = UUID().uuidString
  private let declaration: Ast.Statement.Function
  private let closure: Environment
  private let isInitializer: Bool

  public var arity: Int {
    declaration.params.count
  }

  public var toString: String {
    "<user fn: \(declaration.name.meta.lexeme)>"
  }

  public init(
    _ declaration: Ast.Statement.Function,
    environment closure: Environment,
    isInitializer: Bool = false
  ) {
    self.declaration = declaration
    self.closure = closure
    self.isInitializer = isInitializer
  }

  public func bind(to instance: Instance) -> UserFunction {
    let environment = Environment(enclosing: closure)
    environment.define(name: "this", value: .instance(instance))
    return UserFunction(declaration, environment: environment, isInitializer: isInitializer)
  }

  public func call(
    _ interpreter: Interpreter,
    arguments: [Object],
    token: Token
  ) throws -> Object {
    let env = Environment(enclosing: closure)
    for (param, arg) in zip(declaration.params, arguments) {
      env.define(name: param.meta.lexeme, value: arg)
    }

    do {
      try interpreter.executeBlock(declaration.body, environment: env)
    } catch let `return` as Return {
      if isInitializer { return closure.get(at: 0, "this") ?? nil }
      return `return`.value ?? nil
    }

    if isInitializer {
      return closure.get(at: 0, "this") ?? nil
    }

    return nil
  }
}

extension UserFunction: Equatable {
  public static func == (lhs: UserFunction, rhs: UserFunction) -> Bool {
    lhs.id == rhs.id
  }
}
