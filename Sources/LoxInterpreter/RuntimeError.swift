import LoxScanner

public struct RuntimeError: Error, Equatable {
  public enum ErrorType: Equatable {
    case invalidUnaryMinusOperand(Object)
    case invalidBinaryOperands(lhs: Object, operator: Token.TokenType, rhs: Object)
    case undefinedVariable(String)
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
    }
    return "Error at \(token.meta.line):\(token.meta.column): \(typeError)"
  }
}
