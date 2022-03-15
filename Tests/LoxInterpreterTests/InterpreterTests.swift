import XCTest

import LoxAst
import LoxInterpreter
import LoxParser
import LoxScanner

final class InterpreterTests: XCTestCase {
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
      XCTAssertEqual(try eval(input).get(), expected)
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
      switch eval(input) {
      case .failure(let error):
        XCTAssertEqual(error.type, expected)
      case .success:
        XCTAssertTrue(false, "Unexpected lack of error for input `\(input)`")
      }
    }
  }
}

private func eval(_ input: String) -> Result<Object, RuntimeError> {
  let scanner = LoxScanner.Scanner(
    source: input,
    onError: { e in fatalError(e.localizedDescription) }
  )
  let parser = Parser(tokens: scanner.getTokens(), onError: { _ in fatalError() })
  let expr = parser.parse()
  let interpreter = Interpreter()
  return interpreter.interpret(expr!)
}
