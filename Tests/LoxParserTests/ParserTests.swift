import XCTest

import LoxAst
import LoxParser
import LoxScanner

private typealias E = Ast.Expression
private typealias S = Ast.Statement

final class ParserTests: XCTestCase {

  func testBinaryExpr() throws {
    let expr = assertSingleStmt(from: "1 < 2;", is: S.Expression.self).expression
    let binary = assert(expr, is: E.Binary.self)
    let left = assert(binary.left, is: E.Literal.self)
    let right = assert(binary.right, is: E.Literal.self)
    XCTAssertEqual(left.value, .number(1))
    XCTAssertEqual(right.value, .number(2))
    XCTAssertEqual(binary.operator.type, .less)
    XCTAssertEqual(try Ast.PrinterVisitor().eval(expr), "(< 1 2)")
  }

  func testVarDeclNoInitializer() throws {
    let varStmt = assertSingleStmt(from: "var x;", is: S.Var.self)
    XCTAssertNil(varStmt.initializer)
    XCTAssertEqual(varStmt.name.meta.lexeme, "x")
  }

  func testVarDeclWithInitializer() throws {
    let varStmt = assertSingleStmt(from: "var x = 3 + 3;", is: S.Var.self)
    XCTAssertEqual(varStmt.name.meta.lexeme, "x")
    assert(varStmt.initializer, is: E.Binary.self)
  }

  func testVariableExpression() throws {
    let exprStmt = assertSingleStmt(from: "x;", is: S.Expression.self)
    let varExpr = assert(exprStmt.expression, is: E.Variable.self)
    XCTAssertEqual(varExpr.name.meta.lexeme, "x")
  }

  func testAssignmentExpression() throws {
    let exprStmt = assertSingleStmt(from: "x = 3;", is: S.Expression.self)
    let assign = assert(exprStmt.expression, is: E.Assignment.self)
    XCTAssertEqual(assign.name.meta.lexeme, "x")
    let rhs = assert(assign.value, is: E.Literal.self)
    XCTAssertEqual(rhs.value, .number(3))
  }

  func testBlockStatement() throws {
    let blockStmt = assertSingleStmt(from: "{ x; }", is: S.Block.self)
    XCTAssertEqual(blockStmt.statements.count, 1)
    let expr = assert(blockStmt.statements[0], is: S.Expression.self)
    let varExpr = assert(expr.expression, is: E.Variable.self)
    XCTAssertEqual(varExpr.name.meta.lexeme, "x")
  }
}

// helpers

@discardableResult
private func assert<Input, Expected>(
  _ expr: Input,
  is type: Expected.Type,
  file: StaticString = #file,
  line: UInt = #line
) -> Expected {
  XCTAssertTrue(expr is Expected, file: file, line: line)
  return expr as! Expected
}

private func assertSingleStmt<Expected>(
  from input: String,
  is: Expected.Type,
  file: StaticString = #file,
  line: UInt = #line
) -> Expected {
  let statements = getStatements(input)
  XCTAssertEqual(1, statements.count, file: file, line: line)
  return assert(statements[0], is: Expected.self, file: file, line: line)
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
