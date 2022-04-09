import Foundation
import LoxAst
import LoxScanner

public protocol Callable {
  var id: String { get }
  var arity: Int { get }
  var toString: String { get }
  func call(_ interpreter: Interpreter, arguments: [Object], token: Token) throws -> Object
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
