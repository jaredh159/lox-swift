import Foundation
import LoxAst
import LoxScanner

public protocol Callable {
  var id: String { get }
  var arity: Int { get }
  var toString: String { get }
  func call(_ interpreter: Interpreter, arguments: [Object], token: Token) throws -> Object
}

public struct UserFunction: Callable {
  public let id = UUID().uuidString
  private let declaration: Ast.Statement.Function
  private let closure: Environment

  public var arity: Int {
    declaration.params.count
  }

  public var toString: String {
    "<user fn: \(declaration.name.meta.lexeme)>"
  }

  public init(_ declaration: Ast.Statement.Function, environment closure: Environment) {
    self.declaration = declaration
    self.closure = closure
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
      return `return`.value ?? nil
    }

    return nil
  }
}

// "native" functions

public struct Clock: Callable {
  public let id = "Lox.Globals.Clock"
  public let arity = 0
  public let toString = "<native fn: clock>"

  public func call(
    _ interpreter: Interpreter,
    arguments: [Object],
    token: Token
  ) throws -> Object {
    .number(Double(Date().timeIntervalSinceReferenceDate))
  }
}

public struct AssertEqual: Callable {
  public let id = "Lox.Globals.AssertEqual"
  public let arity = 2
  public let toString = "<native fn: assertEqual>"

  public func call(
    _ interpreter: Interpreter,
    arguments: [Object],
    token: Token
  ) throws -> Object {
    guard arguments.count == arity else {
      throw RuntimeError(
        .functionArity(expected: arity, recieved: arguments.count, name: "assertEqual"),
        token
      )
    }
    guard arguments[0] == arguments[1] else {
      throw RuntimeError(.assertEqualFailure(actual: arguments[0], expected: arguments[1]), token)
    }
    return nil
  }
}
