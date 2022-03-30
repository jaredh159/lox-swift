import Foundation
import LoxAst

public protocol Callable {
  var id: String { get }
  var arity: Int { get }
  var toString: String { get }
  func call(_ interpreter: Interpreter, arguments: [Object]) throws -> Object
}

public struct UserFunction: Callable {
  public let id = UUID().uuidString
  private let declaration: Ast.Statement.Function

  public var arity: Int {
    declaration.params.count
  }

  public var toString: String {
    "<user fn: \(declaration.name.meta.lexeme)>"
  }

  public init(_ declaration: Ast.Statement.Function) {
    self.declaration = declaration
  }

  public func call(_ interpreter: Interpreter, arguments: [Object]) throws -> Object {
    let env = Environment(enclosing: interpreter.globals)
    for (param, arg) in zip(declaration.params, arguments) {
      env.define(name: param.meta.lexeme, value: arg)
    }
    try interpreter.executeBlock(declaration.body, environment: env)
    return nil
  }
}

// "native" functions

public struct Clock: Callable {
  public let id = "Lox.Globals.Clock"
  public let arity = 0
  public let toString = "<native fn: clock>"

  public func call(_ interpreter: Interpreter, arguments: [Object]) throws -> Object {
    .number(Double(Date().timeIntervalSinceReferenceDate))
  }
}
