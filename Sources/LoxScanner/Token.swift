import Rainbow

public enum Token: Equatable {
  public struct Meta: Equatable {
    let lexeme: String
    let offset: Int
    let trivia: String?

    public init(lexeme: String, offset: Int, trivia: String? = nil) {
      self.lexeme = lexeme
      self.offset = offset
      self.trivia = trivia
    }
  }

  // single character tokens
  case leftParen(Meta)
  case rightParen(Meta)
  case leftBrace(Meta)
  case rightBrace(Meta)
  case comma(Meta)
  case dot(Meta)
  case minus(Meta)
  case plus(Meta)
  case semicolon(Meta)
  case slash(Meta)
  case star(Meta)

  // one or two character tokens
  case bang(Meta)
  case bangEqual(Meta)
  case equal(Meta)
  case equalEqual(Meta)
  case greater(Meta)
  case greaterEqual(Meta)
  case less(Meta)
  case lessEqual(Meta)

  // literals
  case identifier(Meta)
  case string(Meta)
  case number(Meta)

  // keywords
  case and(Meta)
  case `class`(Meta)
  case `else`(Meta)
  case `false`(Meta)
  case fun(Meta)
  case `for`(Meta)
  case `if`(Meta)
  case `nil`(Meta)
  case or(Meta)
  case print(Meta)
  case `return`(Meta)
  case `super`(Meta)
  case this(Meta)
  case `true`(Meta)
  case `var`(Meta)
  case `while`(Meta)

  // special
  case eof(Meta)
}

extension Token: CustomStringConvertible {

  public var description: String {
    return "\(typeDescription) \(meta.lexeme)"
  }

  public var meta: Token.Meta {
    switch self {
    case .leftParen(let meta),
         .rightParen(let meta),
         .leftBrace(let meta),
         .rightBrace(let meta),
         .comma(let meta),
         .dot(let meta),
         .minus(let meta),
         .plus(let meta),
         .semicolon(let meta),
         .slash(let meta),
         .star(let meta),
         .bang(let meta),
         .bangEqual(let meta),
         .equal(let meta),
         .equalEqual(let meta),
         .greater(let meta),
         .greaterEqual(let meta),
         .less(let meta),
         .lessEqual(let meta),
         .identifier(let meta),
         .string(let meta),
         .number(let meta),
         .and(let meta),
         .class(let meta),
         .else(let meta),
         .false(let meta),
         .fun(let meta),
         .for(let meta),
         .if(let meta),
         .nil(let meta),
         .or(let meta),
         .print(let meta),
         .return(let meta),
         .super(let meta),
         .this(let meta),
         .true(let meta),
         .var(let meta),
         .while(let meta),
         .eof(let meta):
      return meta
    }
  }

  var typeDescription: String {
    switch self {
    case .leftParen:
      return "LEFT_PAREN"
    case .rightParen:
      return "RIGHT_PAREN"
    case .leftBrace:
      return "LEFT_BRACE"
    case .rightBrace:
      return "RIGHT_BRACE"
    case .comma:
      return "COMMA"
    case .dot:
      return "DOT"
    case .minus:
      return "MINUS"
    case .plus:
      return "PLUS"
    case .semicolon:
      return "SEMICOLON"
    case .slash:
      return "SLASH"
    case .star:
      return "STAR"
    case .bang:
      return "BANG"
    case .bangEqual:
      return "BANG_EQUAL"
    case .equal:
      return "EQUAL"
    case .equalEqual:
      return "EQUAL_EQUAL"
    case .greater:
      return "GREATER"
    case .greaterEqual:
      return "GREATER_EQUAL"
    case .less:
      return "LESS"
    case .lessEqual:
      return "LESS_EQUAL"
    case .identifier:
      return "IDENTIFIER"
    case .string:
      return "STRING"
    case .number:
      return "NUMBER"
    case .and:
      return "AND"
    case .class:
      return "CLASS"
    case .else:
      return "ELSE"
    case .false:
      return "FALSE"
    case .fun:
      return "FUN"
    case .for:
      return "FOR"
    case .if:
      return "IF"
    case .nil:
      return "NIL"
    case .or:
      return "OR"
    case .print:
      return "PRINT"
    case .return:
      return "RETURN"
    case .super:
      return "SUPER"
    case .this:
      return "THIS"
    case .true:
      return "TRUE"
    case .var:
      return "VAR"
    case .while:
      return "WHILE"
    case .eof:
      return "EOF"
    }
  }
}

public extension Token {
  func print() {
    Swift.print("Token ", terminator: "")
    Swift.print("type: ".dim, terminator: "")
    Swift.print(typeDescription.green, terminator: "")
    if !meta.lexeme.isEmpty {
      Swift.print(", lexeme: ".dim, terminator: "")
      Swift.print(meta.lexeme.magenta, terminator: "")
    }
    Swift.print(", offset: ".dim, terminator: "")
    Swift.print(String(meta.offset).yellow)
  }
}
