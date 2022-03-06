import Foundation
import Rainbow

public enum Token: Equatable {

  public struct Meta: Equatable {
    public let lexeme: String
    public let line: Int
    public let column: Int

    public init(lexeme: String, line: Int, column: Int) {
      self.lexeme = lexeme
      self.line = line
      self.column = column
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
  case string(Meta, String)
  case number(Meta, Double)

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

// extensions

extension Token: CustomStringConvertible {
  public var description: String {
    return "\(type.string) \(meta.lexeme)"
  }
}

public extension Token {
  var meta: Token.Meta {
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
         .string(let meta, _),
         .number(let meta, _),
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
}

public extension Token {
  enum TokenType: String, Equatable {
    case leftParen
    case rightParen
    case leftBrace
    case rightBrace
    case comma
    case dot
    case minus
    case plus
    case semicolon
    case slash
    case star
    case bang
    case bangEqual
    case equal
    case equalEqual
    case greater
    case greaterEqual
    case less
    case lessEqual
    case identifier
    case string
    case number
    case and
    case `class`
    case `else`
    case `false`
    case fun
    case `for`
    case `if`
    case `nil`
    case or
    case print
    case `return`
    case `super`
    case this
    case `true`
    case `var`
    case `while`
    case eof

    public var string: String {
      rawValue.shoutyCased
    }
  }

  var type: TokenType {
    switch self {
    case .leftParen:
      return .leftParen
    case .rightParen:
      return .rightParen
    case .leftBrace:
      return .leftBrace
    case .rightBrace:
      return .rightBrace
    case .comma:
      return .comma
    case .dot:
      return .dot
    case .minus:
      return .minus
    case .plus:
      return .plus
    case .semicolon:
      return .semicolon
    case .slash:
      return .slash
    case .star:
      return .star
    case .bang:
      return .bang
    case .bangEqual:
      return .bangEqual
    case .equal:
      return .equal
    case .equalEqual:
      return .equalEqual
    case .greater:
      return .greater
    case .greaterEqual:
      return .greaterEqual
    case .less:
      return .less
    case .lessEqual:
      return .lessEqual
    case .identifier:
      return .identifier
    case .string:
      return .string
    case .number:
      return .number
    case .and:
      return .and
    case .class:
      return .class
    case .else:
      return .else
    case .false:
      return .false
    case .fun:
      return .fun
    case .for:
      return .for
    case .if:
      return .if
    case .nil:
      return .nil
    case .or:
      return .or
    case .print:
      return .print
    case .return:
      return .return
    case .super:
      return .super
    case .this:
      return .this
    case .true:
      return .true
    case .var:
      return .var
    case .while:
      return .while
    case .eof:
      return .eof
    }
  }
}

public extension Token {
  func print() {
    Swift.print("Token ", terminator: "")
    Swift.print("type: ".dim, terminator: "")
    Swift.print(type.string.green, terminator: "")
    if !meta.lexeme.isEmpty {
      Swift.print(", lexeme: ".dim, terminator: "")
      Swift.print(meta.lexeme.magenta, terminator: "")
    }
    Swift.print(", line: ".dim, terminator: "")
    Swift.print(String(meta.line).yellow, terminator: "")
    Swift.print(", column: ".dim, terminator: "")
    Swift.print(String(meta.column).yellow)
  }
}

private extension String {
  private var snakeCased: String {
    let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
    let normalPattern = "([a-z0-9])([A-Z])"
    return processCamelCaseRegex(pattern: acronymPattern)?
      .processCamelCaseRegex(pattern: normalPattern)?.lowercased() ?? lowercased()
  }

  var shoutyCased: String {
    snakeCased.uppercased()
  }

  private func processCamelCaseRegex(pattern: String) -> String? {
    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: count)
    return regex?.stringByReplacingMatches(
      in: self, options: [], range: range, withTemplate: "$1_$2"
    )
  }
}
