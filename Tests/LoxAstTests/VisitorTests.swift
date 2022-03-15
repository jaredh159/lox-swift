import XCTest

import LoxAst
import LoxScanner

final class VisitorTests: XCTestCase {
  private typealias E = Ast.Expression

  func testPrinterVisitor() throws {
    let expr = E.Binary(
      left: E.Unary(
        operator: .minus(.init(lexeme: "-", line: 1, column: 1)),
        right: E.Literal(value: .number(123))
      ),
      operator: .star(.init(lexeme: "*", line: 1, column: 1)),
      right: E.Grouping(expression: E.Literal(value: .number(45.67)))
    )

    XCTAssertEqual(try Ast.PrinterVisitor().eval(expr), "(* (- 123) (group 45.67))")
  }

  func testRpnVisitor() throws {
    let one = E.Literal(value: .number(1))
    let two = E.Literal(value: .number(2))
    let three = E.Literal(value: .number(3))
    let four = E.Literal(value: .number(4))
    let plus = Token.plus(.init(lexeme: "+", line: 1, column: 1))
    let minus = Token.minus(.init(lexeme: "-", line: 1, column: 1))
    let star = Token.star(.init(lexeme: "*", line: 1, column: 1))
    let lhs = E.Grouping(expression: E.Binary(left: one, operator: plus, right: two))
    let rhs = E.Grouping(expression: E.Binary(left: four, operator: minus, right: three))
    let expr = E.Binary(left: lhs, operator: star, right: rhs)
    XCTAssertEqual(try Ast.RpnVisitor().eval(expr), "1 2 + 4 3 - *")
  }
}
