import XCTest

import LoxAst
import LoxInterpreter
import LoxParser
import LoxScanner

final class InterpreterTests: XCTestCase {

  func testWeirdScopeEdgeCase() throws {
    let input = """
    var a = "global";
    {
      fun testA() {
        assertEqual(a, "global");
      }

      testA();
      var a = "block";
      testA();
    }
    """
    XCTAssertNil(interpret(input))
  }

  func testEvaluatingExpressions() throws {
    let cases: [(String, Object)] = [
      ("1", 1),
      ("2", 2),
      ("nil", nil),
      ("3.145", 3.145),
      ("true", true),
      ("false", false),
      ("nil", nil),
      ("(1)", 1),
      ("(true)", true),
      ("-1", -1),
      ("!nil", true),
      ("!true", false),
      ("!false", true),
      ("!!true", true),
      ("!!false", false),
      ("!1", false),
      ("2 + 3", 5),
      ("2 * 3", 6),
      ("2 - 3", -1),
      ("6 / 2", 3),
      (#""foo" + "bar""#, "foobar"),
      ("1 < 2", true),
      ("2 < 2", false),
      ("2 <= 2", true),
      ("3 > 2", true),
      ("3 > 4", false),
      ("3 >= 3", true),
      ("3 == 3", true),
      ("nil == nil", true),
      ("nil != nil", false),
      ("3 == 4", false),
      ("3 != 3", false),
      ("3 != 4", true),
      ("3 == \"three\"", false),
      ("3 != \"three\"", true),
    ]
    for (input, expected) in cases {
      XCTAssertEqual(try eval(input + ";").get(), expected)
    }
  }

  func testRuntimeErrors() throws {
    let cases: [(String, RuntimeError.ErrorType)] = [
      ("-true", .invalidUnaryMinusOperand(true)),
      ("-nil", .invalidUnaryMinusOperand(nil)),
      ("-\"foo\"", .invalidUnaryMinusOperand("foo")),
      ("true > false", .invalidBinaryOperands(lhs: true, operator: .greater, rhs: false)),
      ("nil >= \"foo\"", .invalidBinaryOperands(lhs: nil, operator: .greaterEqual, rhs: "foo")),
    ]
    for (input, expected) in cases {
      switch eval(input + ";") {
      case .failure(let error):
        XCTAssertEqual(error.type, expected)
      case .success:
        XCTAssertTrue(false, "Unexpected lack of error for input `\(input)`")
      }
    }
  }
}

private func interpret(_ input: String) -> RuntimeError? {
  Interpreter().interpret(statements(from: input))
}

private func eval(_ input: String) -> Result<Object, RuntimeError> {
  let statements = statements(from: input)
  let exprStatement = statements[0] as! Ast.Statement.Expression
  let expr = exprStatement.expression
  let interpreter = Interpreter()
  do {
    return .success(try interpreter.evaluate(expr))
  } catch {
    return .failure(error as! RuntimeError)
  }
}

private func statements(from input: String) -> [Stmt] {
  let scanner = LoxScanner.Scanner(
    source: input,
    onError: { e in fatalError(e.localizedDescription) }
  )
  let parser = Parser(
    tokens: scanner.getTokens(),
    onError: { err in fatalError("Interpreter tests error for input: `\(input)`, err: \(err)") }
  )
  return parser.parse()
}
