import LoxAst
import LoxInterpreter
import LoxParser
import LoxScanner
import XCTest

final class ResolverTests: XCTestCase {
  func testSelfReferencingInititalizerShouldError() throws {
    try expectResolutionError(
      """
      var a = "outer";
      {
        var a = a;
      }
      """,
      .selfReferencingInitializer(name: "a", line: 3, col: 11)
    )
  }

  func testDuplicateScopedVarShouldError() throws {
    try expectResolutionError(
      """
      {
        var a = "first";
        var a = "second";
      }
      """,
      .duplicateVariable(name: "a", line: 3, col: 7)
    )
  }

  func testTopLevelReturnErrors() throws {
    try expectResolutionError("return 1;", .topLevelReturn(line: 1, col: 1))
  }
}

// helpers

func expectResolutionError(_ input: String, _ expectedError: Resolver.Error) throws {
  var resolveError: Resolver.Error?
  let resolver = Resolver(interpreter: Interpreter(), errorHandler: { err in
    resolveError = err
  })

  try resolver.resolve(statements(from: input))

  XCTAssertEqual(resolveError, expectedError)
}

func statements(from input: String, testCase: StaticString = #fileID) -> [Stmt] {
  let scanner = LoxScanner.Scanner(
    source: input,
    onError: { err in
      fatalError(
        "\(testCase) Scanner error for input: `\(input)`, err: \(String(describing: err))"
      )
    }
  )
  let parser = Parser(
    tokens: scanner.getTokens(),
    onError: { err in
      fatalError(
        "\(testCase) Parse error for input: `\(input)`, err: \(String(describing: err))"
      )
    }
  )
  return parser.parse()
}
