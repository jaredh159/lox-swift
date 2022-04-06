import Foundation
import LoxScanner

public struct LoxClass: Hashable, Equatable, Callable {
  public let id = UUID().uuidString
  public let arity = 0
  public let name: String

  public var toString: String {
    name
  }

  public func call(
    _ interpreter: Interpreter,
    arguments: [Object],
    token: Token
  ) throws -> Object {
    .instance(.init(class: self))
  }
}
