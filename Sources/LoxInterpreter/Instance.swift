import LoxScanner

public class Instance {
  public let `class`: LoxClass
  private var fields: [String: Object] = [:]

  public init(class: LoxClass) {
    self.class = `class`
  }

  public var toString: String {
    self.class.name + " instance"
  }

  public func get(name: Token) throws -> Object {
    if let object = fields[name.lexeme] {
      return object
    }
    if let method = self.class.find(method: name.lexeme) {
      return .callable(method.bind(to: self))
    }
    throw RuntimeError(.undefinedProperty, name)
  }

  public func set(name: Token, value: Object) {
    fields[name.lexeme] = value
  }
}
