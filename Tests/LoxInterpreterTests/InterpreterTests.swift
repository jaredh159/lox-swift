import XCTest

import LoxAst
import LoxInterpreter
import LoxParser
import LoxScanner

final class InterpreterTests: XCTestCase {
  func testExpressionsThatEvaluateToALiteral() {
    let cases: [(String, Ast.Literal)] = [
      ("1", 1),
      ("2", 2),
      ("3.145", 3.145),
      ("true", true),
      ("false", false),
      ("nil", nil),
      ("(1)", 1),
      ("(true)", true),
      ("-1", -1),
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
    ]
    for (input, expected) in cases {
      XCTAssertEqual(eval(input), .literal(expected))
    }
  }
}

private func eval(_ input: String) -> Object {
  let scanner = LoxScanner.Scanner(source: input, onError: { _ in fatalError() })
  let parser = Parser(tokens: scanner.getTokens(), onError: { _ in fatalError() })
  let expr = parser.parse()
  let interpreter = Interpreter()
  return interpreter.evaluate(expr!)
}
