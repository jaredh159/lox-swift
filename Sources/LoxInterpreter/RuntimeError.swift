import LoxScanner

public struct RuntimeError: Error, Equatable {
  public enum ErrorType: Equatable {
    case invalidUnaryMinusOperand(Object)
    case invalidBinaryOperands(lhs: Object, operator: Token.TokenType, rhs: Object)
    case undefinedVariable(String)
    case functionArity(expected: Int, recieved: Int, name: String?)
    case assertEqualFailure(actual: Object, expected: Object)
    case invalidCallable
  }

  public let type: ErrorType
  public let token: Token

  public init(_ type: ErrorType, _ token: Token) {
    self.type = type
    self.token = token
  }

  public var message: String {
    let typeError: String
    switch type {
    case .invalidUnaryMinusOperand(let operand):
      typeError = "invalid operand to unary minus: \(operand.toString)"
    case .invalidBinaryOperands(lhs: _, operator: let op, rhs: _):
      typeError = "invalid binary operands for operator \(op.string)"
    case .undefinedVariable(let name):
      typeError = "undefined variable `\(name)`"
    case .functionArity(expected: let expected, recieved: let received, name: let name):
      let fnName = name != nil ? "\(name!) " : ""
      typeError = "function \(fnName)expects \(expected) argument/s, recieved \(received)"
    case .invalidCallable:
      typeError = "can only call functions and classes"
    case .assertEqualFailure(actual: let actual, expected: let expected):
      typeError =
        "assertEqual failed - \(actual.toString) is not equal to expected \(expected.toString)"
    }
    return "Error at \(token.meta.line):\(token.meta.column): \(typeError)"
  }
}

// extensions

extension RuntimeError: CustomDebugStringConvertible {
  public var debugDescription: String {
    message
  }
}
