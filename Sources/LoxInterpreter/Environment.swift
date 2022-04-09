import LoxScanner

public class Environment {
  private var values: [String: Object?] = [:]
  private var enclosing: Environment?

  public init(enclosing: Environment? = nil) {
    self.enclosing = enclosing
  }

  public func define(name: String, value: Object?) {
    if let value = value {
      values[name] = .some(value)
    } else {
      values[name] = .some(nil)
    }
  }

  public func assign(name token: Token, value: Object) throws {
    let name = token.meta.lexeme
    let object = values[name]
    switch object {
    case .some(.some), .some(.none):
      values[name] = value
    case .none:
      if let enclosing = enclosing {
        return try enclosing.assign(name: token, value: value)
      }
      throw RuntimeError(.undefinedVariable(name), token)
    }
  }

  public func assign(at distance: Int, name: Token, value: Object) {
    ancestor(at: distance).values[name.meta.lexeme] = value
  }

  public func get(at distance: Int, _ name: String) -> Object? {
    let object = ancestor(at: distance).values[name]
    switch object {
    case .some(.some(let object)):
      return object
    case .some(.none), .none:
      return nil
    }
  }

  private func ancestor(at distance: Int) -> Environment {
    var environment = self
    for _ in 0 ..< distance {
      environment = environment.enclosing!
    }
    return environment
  }

  public func get(_ token: Token) throws -> Object? {
    let name = token.meta.lexeme
    let object = values[name]
    switch object {
    case .some(.some(let object)):
      return object
    case .some(.none):
      return nil
    case .none:
      if let enclosing = enclosing {
        return try enclosing.get(token)
      }
      throw RuntimeError(.undefinedVariable(name), token)
    }
  }
}
