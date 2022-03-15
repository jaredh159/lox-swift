import XCTest

import LoxAst
import LoxParser
import LoxScanner

final class ParserTests: XCTestCase {
  private typealias E = Ast.Expression

  func testBinaryExpr() throws {
    let scanner = Scanner(
      source: "1 < 2",
      onError: { err in fatalError(err.localizedDescription) }
    )
    let parser = Parser(
      tokens: scanner.getTokens(),
      onError: { err in fatalError(err.localizedDescription) }
    )
    let expr = parser.parse()
    XCTAssertNotNil(expr)
    XCTAssertTrue(expr is E.Binary)
    let binary = expr as! E.Binary
    XCTAssertTrue(binary.left is E.Literal)
    XCTAssertTrue(binary.right is E.Literal)
    let leftLit = binary.left as! E.Literal
    let rightLit = binary.right as! E.Literal
    XCTAssertEqual(leftLit.value, .number(1))
    XCTAssertEqual(rightLit.value, .number(2))
    XCTAssertEqual(binary.operator.type, .less)
    XCTAssertEqual(try Ast.PrinterVisitor().eval(expr!), "(< 1 2)")
  }
}
