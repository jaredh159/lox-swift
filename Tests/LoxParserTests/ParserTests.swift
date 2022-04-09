import XCTest

import LoxAst
import LoxParser
import LoxScanner

private typealias E = Ast.Expression
private typealias S = Ast.Statement

final class ParserTests: XCTestCase {

  func testVarDeclNoInitializer() throws {
    let varStmt = assertSingleStmt(from: "var x;", is: S.Var.self)
    XCTAssertNil(varStmt.initializer)
    XCTAssertEqual(varStmt.name.lexeme, "x")
  }

  func testVarDeclWithInitializer() throws {
    let varStmt = assertSingleStmt(from: "var x = 3 + 3;", is: S.Var.self)
    XCTAssertEqual(varStmt.name.lexeme, "x")
    assert(varStmt.initializer, is: E.Binary.self)
  }

  func testVariableExpression() throws {
    let exprStmt = assertSingleStmt(from: "x;", is: S.Expression.self)
    assert(exprStmt.expression, isVar: "x")
  }

  func testAssignmentExpression() throws {
    let exprStmt = assertSingleStmt(from: "x = 3;", is: S.Expression.self)
    let assign = assert(exprStmt.expression, is: E.Assign.self)
    XCTAssertEqual(assign.name.lexeme, "x")
    assert(assign.value, isLiteral: 3)
  }

  func testBlockStatement() throws {
    let blockStmt = assertSingleStmt(from: "{ x; }", is: S.Block.self)
    XCTAssertEqual(blockStmt.statements.count, 1)
    let expr = assert(blockStmt.statements[0], is: S.Expression.self)
    assert(expr.expression, isVar: "x")
  }

  func testIfStatementNoElse() throws {
    let ifStmt = assertSingleStmt(from: "if (true) 3;", is: S.If.self)
    assert(ifStmt.condition, isLiteral: true)
    let thenStmt = assert(ifStmt.thenBranch, is: S.Expression.self)
    assert(thenStmt.expression, isLiteral: 3)
    XCTAssertNil(ifStmt.elseBranch)
  }

  func testIfStatementWithElse() throws {
    let ifStmt = assertSingleStmt(from: "if (true) 3; else 4;", is: S.If.self)
    assert(ifStmt.condition, isLiteral: true)
    let thenStmt = assert(ifStmt.thenBranch, is: S.Expression.self)
    assert(thenStmt.expression, isLiteral: 3)
    let elseStmt = assert(ifStmt.elseBranch, is: S.Expression.self)
    assert(elseStmt.expression, isLiteral: 4)
  }

  func testOrStatement() throws {
    let orStmt = assertSingleStmt(from: "false or true;", is: S.Expression.self)
    let orExp = assert(orStmt.expression, is: E.Logical.self)
    assert(orExp.left, isLiteral: false)
    assert(orExp.right, isLiteral: true)
    XCTAssertEqual(orExp.operator.type, .or)
  }

  func testAndStatement() throws {
    let orStmt = assertSingleStmt(from: "true and 3;", is: S.Expression.self)
    let andExp = assert(orStmt.expression, is: E.Logical.self)
    assert(andExp.left, isLiteral: true)
    assert(andExp.right, isLiteral: 3)
    XCTAssertEqual(andExp.operator.type, .and)
  }

  func testWhileStatement() throws {
    let whileStmt = assertSingleStmt(from: "while (true) 3;", is: S.While.self)
    assert(whileStmt.condition, isLiteral: true)
    let body = assert(whileStmt.body, is: S.Expression.self)
    assert(body.expression, isLiteral: 3)
  }

  func testForLoopInfinite() throws {
    let whileStmt = assertSingleStmt(from: "for (;;) 3;", is: S.While.self)
    assert(whileStmt.condition, isLiteral: true)
    let body = assert(whileStmt.body, is: S.Expression.self)
    assert(body.expression, isLiteral: 3)
  }

  func testForLoopFull() throws {
    let outerBlock = assertSingleStmt(
      from: "for (var i = 0; i < 10; i = i + 1) print i;",
      is: S.Block.self
    )
    XCTAssertEqual(outerBlock.statements.count, 2)
    let initializer = assert(outerBlock.statements.first, is: S.Var.self)
    XCTAssertEqual(initializer.name.lexeme, "i")
    assert(initializer.initializer!, isLiteral: 0)
    let whileStmt = assert(outerBlock.statements.last, is: S.While.self)
    let comparison = assert(whileStmt.condition, is: E.Binary.self)
    assert(comparison.left, is: E.Variable.self)
    XCTAssertEqual(comparison.operator.type, .less)
    assert(comparison.right, isLiteral: 10)
    let whileBody = assert(whileStmt.body, is: S.Block.self)
    XCTAssertEqual(whileBody.statements.count, 2)
    let printStmt = assert(whileBody.statements.first, is: S.Print.self)
    assert(printStmt.expression, isVar: "i")
    let assign = assert(whileBody.statements.last, is: S.Expression.self)
    let incr = assert(assign.expression, is: E.Assign.self)
    XCTAssertEqual(incr.name.lexeme, "i")
    let assignExpr = assert(incr.value, is: E.Binary.self)
    assert(assignExpr.left, isVar: "i")
    XCTAssertEqual(assignExpr.operator.type, .plus)
    assert(assignExpr.right, isLiteral: 1)
  }

  func testCallExpNoArgs() {
    let exprStmt = assertSingleStmt(from: "foo();", is: S.Expression.self)
    let callExp = assert(exprStmt.expression, is: E.Call.self)
    assert(callExp.callee, isVar: "foo")
    let paren = assert(callExp.paren, is: Token.self)
    XCTAssertEqual(paren.type, .rightParen)
    XCTAssertEqual(callExp.arguments.count, 0)
  }

  func testCallExpWithArgs() {
    let exprStmt = assertSingleStmt(from: "foo(1, 2);", is: S.Expression.self)
    let callExp = assert(exprStmt.expression, is: E.Call.self)
    assert(callExp.callee, isVar: "foo")
    let paren = assert(callExp.paren, is: Token.self)
    XCTAssertEqual(paren.type, .rightParen)
    XCTAssertEqual(callExp.arguments.count, 2)
    assert(callExp.arguments.first!, isLiteral: 1)
    assert(callExp.arguments.last!, isLiteral: 2)
  }

  func testSimpleFunctionDecl() {
    let funDecl = assertSingleStmt(from: "fun foo() {}", is: S.Function.self)
    XCTAssertEqual(funDecl.params.count, 0)
    XCTAssertEqual(funDecl.body.count, 0)
    XCTAssertEqual(funDecl.name.lexeme, "foo")
  }

  func testFunctionDeclWithParamsAndBody() {
    let funDecl = assertSingleStmt(from: "fun bar(x, y) { print x + y; }", is: S.Function.self)
    XCTAssertEqual(funDecl.name.lexeme, "bar")
    XCTAssertEqual(funDecl.params.count, 2)
    XCTAssertEqual(funDecl.params[0].lexeme, "x")
    XCTAssertEqual(funDecl.params[1].lexeme, "y")
    XCTAssertEqual(funDecl.body.count, 1)
    let printStmt = assert(funDecl.body.first, is: S.Print.self)
    let binary = assert(printStmt.expression, is: E.Binary.self)
    assert(binary.left, isVar: "x")
    XCTAssertEqual(binary.operator.type, .plus)
    assert(binary.right, isVar: "y")
  }

  func testReturnStmt() {
    let funDecl = assertSingleStmt(from: "fun foo() { return 1; }", is: S.Function.self)
    XCTAssertEqual(funDecl.body.count, 1)
    let returnStmt = assert(funDecl.body.first!, is: S.Return.self)
    XCTAssertEqual(returnStmt.keyword.lexeme, "return")
    assert(returnStmt.value!, isLiteral: 1)
  }

  func testClassDecl() {
    let input = """
    class Breakfast {
      cook() {
        print "eggs a-fryin'!";
      }

      returnThis() {
        return this;
      }
    }
    """
    let classDecl = assertSingleStmt(from: input, is: S.Class.self)
    XCTAssertEqual(classDecl.name.lexeme, "Breakfast")
    XCTAssertEqual(classDecl.methods.count, 2)
    let cookMethod = assert(classDecl.methods.first!, is: S.Function.self)
    XCTAssertEqual(cookMethod.params.count, 0)
    XCTAssertEqual(cookMethod.body.count, 1)
    XCTAssertEqual(cookMethod.name.lexeme, "cook")
    let printStmt = assert(cookMethod.body.first!, is: S.Print.self)
    assert(printStmt.expression, isLiteral: "eggs a-fryin'!")
    let returnThisMethod = assert(classDecl.methods.last!, is: S.Function.self)
    XCTAssertEqual(returnThisMethod.params.count, 0)
    XCTAssertEqual(returnThisMethod.body.count, 1)
    XCTAssertEqual(returnThisMethod.name.lexeme, "returnThis")
    let returnStmt = assert(returnThisMethod.body.first!, is: S.Return.self)
    assert(returnStmt.value, is: E.This.self)
  }

  func testSubClassDecl() {
    let input = """
    class Cruller < Donut {}
    """
    let classDecl = assertSingleStmt(from: input, is: S.Class.self)
    XCTAssertEqual(classDecl.name.lexeme, "Cruller")
    assert(classDecl.superclass!, isVar: "Donut")
  }

  func testSetExpr() {
    let exprStmt = assertSingleStmt(from: "foo.bar = 1;", is: S.Expression.self)
    let setExpr = assert(exprStmt.expression, is: E.Set.self)
    assert(setExpr.object, isVar: "foo")
    XCTAssertEqual(setExpr.name.lexeme, "bar")
    assert(setExpr.value, isLiteral: 1)
  }

  func testGetExpr() {
    let exprStmt = assertSingleStmt(from: "foo.bar();", is: S.Expression.self)
    let callExp = assert(exprStmt.expression, is: E.Call.self)
    XCTAssertEqual(callExp.arguments.count, 0)
    let getExpr = assert(callExp.callee, is: E.Get.self)
    assert(getExpr.object, isVar: "foo")
    XCTAssertEqual(getExpr.name.lexeme, "bar")
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

private func assert(_ expr: Expr, isLiteral expected: Ast.Literal) {
  let literal = assert(expr, is: E.Literal.self)
  XCTAssertEqual(literal.value, expected)
}

private func assert(_ expr: Expr, isVar expected: String) {
  let variable = assert(expr, is: E.Variable.self)
  XCTAssertEqual(variable.name.lexeme, expected)
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
