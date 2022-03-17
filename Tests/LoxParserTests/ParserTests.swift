import XCTest

import LoxAst
import LoxParser
import LoxScanner

private typealias E = Ast.Expression
private typealias S = Ast.Statement

final class ParserTests: XCTestCase {

  func testBinaryExpr() throws {
    let expr = assertSingleExprStmt(input: "1 < 2;").expression
    let binary = assert(expr, is: E.Binary.self)
    let left = assert(binary.left, is: E.Literal.self)
    let right = assert(binary.right, is: E.Literal.self)
    XCTAssertEqual(left.value, .number(1))
    XCTAssertEqual(right.value, .number(2))
    XCTAssertEqual(binary.operator.type, .less)
    XCTAssertEqual(try Ast.PrinterVisitor().eval(expr), "(< 1 2)")
  }
}

// helpers

private func assert<Input, Expected>(
  _ expr: Input,
  is type: Expected.Type,
  file: StaticString = #file,
  line: UInt = #line
) -> Expected {
  XCTAssertTrue(expr is Expected, file: file, line: line)
  return expr as! Expected
}

private func assertSingleExprStmt(
  input: String,
  file: StaticString = #file,
  line: UInt = #line
) -> S.Expression {
  let statements = getStatements(input)
  XCTAssertEqual(1, statements.count, file: file, line: line)
  return assert(statements[0], is: S.Expression.self, file: file, line: line)
}

private func getStatements(_ input: String) -> [Stmt] {
  let scanner = Scanner(
    source: input,
    onError: { err in fatalError("ParserTests scanner error: \(err)") }
  )
  let parser = Parser(
    tokens: scanner.getTokens(),
    onError: { err in fatalError("ParserTests parser error: \(err)") }
  )
  return parser.parse()
}
