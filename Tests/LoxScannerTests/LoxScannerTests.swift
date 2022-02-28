import XCTest

@testable import LoxScanner

final class LoxScannerTests: XCTestCase {
  func testBasicTokens() throws {
    assertTokens(
      getTokens("(){},-.+;*!!=;==;>;>=;/"),
      [
        .leftParen(.init(lexeme: "(", line: 1, column: 1)),
        .rightParen(.init(lexeme: ")", line: 1, column: 2)),
        .leftBrace(.init(lexeme: "{", line: 1, column: 3)),
        .rightBrace(.init(lexeme: "}", line: 1, column: 4)),
        .comma(.init(lexeme: ",", line: 1, column: 5)),
        .minus(.init(lexeme: "-", line: 1, column: 6)),
        .dot(.init(lexeme: ".", line: 1, column: 7)),
        .plus(.init(lexeme: "+", line: 1, column: 8)),
        .semicolon(.init(lexeme: ";", line: 1, column: 9)),
        .star(.init(lexeme: "*", line: 1, column: 10)),
        .bang(.init(lexeme: "!", line: 1, column: 11)),
        .bangEqual(.init(lexeme: "!=", line: 1, column: 12)),
        .semicolon(.init(lexeme: ";", line: 1, column: 14)),
        .equalEqual(.init(lexeme: "==", line: 1, column: 15)),
        .semicolon(.init(lexeme: ";", line: 1, column: 17)),
        .greater(.init(lexeme: ">", line: 1, column: 18)),
        .semicolon(.init(lexeme: ";", line: 1, column: 19)),
        .greaterEqual(.init(lexeme: ">=", line: 1, column: 20)),
        .semicolon(.init(lexeme: ";", line: 1, column: 22)),
        .slash(.init(lexeme: "/", line: 1, column: 23)),
        .eof(.init(lexeme: "", line: 1, column: 24)),
      ]
    )
  }

  func testWhitespaceSkipped() {
    assertTokens(
      getTokens("; ;\t;\n;\r;  \t\n\r\r;"),
      [
        .semicolon(.init(lexeme: ";", line: 1, column: 1)),
        .semicolon(.init(lexeme: ";", line: 1, column: 3)),
        .semicolon(.init(lexeme: ";", line: 1, column: 5)),
        .semicolon(.init(lexeme: ";", line: 2, column: 1)),
        .semicolon(.init(lexeme: ";", line: 2, column: 3)),
        .semicolon(.init(lexeme: ";", line: 3, column: 3)),
        .eof(.init(lexeme: "", line: 3, column: 4)),
      ]
    )
  }

  func testCommentSkipped() {
    assertTokens(
      getTokens(";// x\n;"),
      [
        .semicolon(.init(lexeme: ";", line: 1, column: 1)),
        .semicolon(.init(lexeme: ";", line: 2, column: 1)),
        .eof(.init(lexeme: "", line: 2, column: 2)),
      ]
    )
  }

  func testUnexpectedCharacter() {
    assertTokens(
      input: ";•;",
      [
        .semicolon(.init(lexeme: ";", line: 1, column: 1)),
        .semicolon(.init(lexeme: ";", line: 1, column: 3)),
        .eof(.init(lexeme: "", line: 1, column: 4)),
      ],
      withError: .unexpectedCharacter(line: 1, column: 2)
    )
  }

  func testSimpleString() {
    assertTokens(
      getTokens(#""foo""#),
      [
        .string(.init(lexeme: "\"foo\"", line: 1, column: 1), "foo"),
        .eof(.init(lexeme: "", line: 1, column: 6)),
      ]
    )
  }

  func testUnterminatedStringEOF() {
    assertTokens(
      input: "\"foo",
      [.eof(.init(lexeme: "", line: 1, column: 6))],
      withError: .unterminatedString(line: 1, column: 1)
    )
  }

  func testUnterminatedStringEOL() {
    assertTokens(
      input: "\"foo\n;",
      [
        .semicolon(.init(lexeme: ";", line: 2, column: 1)),
        .eof(.init(lexeme: "", line: 2, column: 2)),
      ],
      withError: .unterminatedString(line: 1, column: 1)
    )
  }
}

// helpers

func getTokens(
  _ input: String,
  onError: ((LoxScanner.Scanner.Error) -> Void)? = nil,
  function: StaticString = #function
) -> [Token] {
  let scanner = Scanner(
    source: input,
    onError: onError ?? { _ in fatalError("Unexpected error in test function: \(function)") }
  )
  return scanner.getTokens()
}

func assertTokens(
  input: String,
  _ tokens: [Token],
  withError expectedError: LoxScanner.Scanner.Error? = nil,
  function: StaticString = #function,
  file: StaticString = #file,
  line: UInt = #line
) {
  var handler: ((LoxScanner.Scanner.Error) -> Void)?
  var errorHandlerCalled = false
  if let expectedError = expectedError {
    handler = { error in
      errorHandlerCalled = true
      XCTAssertEqual(expectedError, error)
    }
  }
  let actualTokens = getTokens(input, onError: handler, function: function)
  assertTokens(tokens, actualTokens, file: file, line: line)
  if expectedError != nil {
    XCTAssertTrue(errorHandlerCalled)
  }
}

func assertTokens(
  _ expected: [Token],
  _ actual: [Token],
  file: StaticString = #file,
  line: UInt = #line
) {
  XCTAssertEqual(expected.count, actual.count, file: file, line: line)
  expected.enumerated().forEach { index, token in
    assertToken(token, actual[index], file: file, line: line)
  }
}

func assertToken(
  _ expected: Token,
  _ actual: Token,
  file: StaticString = #file,
  line: UInt = #line
) {
  XCTAssertEqual(
    expected.typeDescription,
    actual.typeDescription,
    "token types don't match",
    file: file,
    line: line
  )

  XCTAssertEqual(
    expected.meta.lexeme,
    actual.meta.lexeme,
    "lexemes don't match",
    file: file,
    line: line
  )

  XCTAssertEqual(
    expected.meta.line,
    actual.meta.line,
    "lines don't match",
    file: file,
    line: line
  )

  XCTAssertEqual(
    expected.meta.column,
    actual.meta.column,
    "columns don't match",
    file: file,
    line: line
  )

  if case .string(_, let expectedString) = expected, case .string(_, let actualString) = actual {
    XCTAssertEqual(
      expectedString,
      actualString,
      "string values don't match",
      file: file,
      line: line
    )
  }
}
