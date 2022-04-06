import XCTest

@testable import LoxScanner

final class ScannerTests: XCTestCase {
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

  func testLessThan() {
    assertTokens(
      getTokens("1 < 2"),
      [
        .number(.init(lexeme: "1", line: 1, column: 1), 1),
        .less(.init(lexeme: "<", line: 1, column: 3)),
        .number(.init(lexeme: "2", line: 1, column: 5), 2),
        .eof(.init(lexeme: "", line: 1, column: 6)),
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

  func testNumber() {
    assertTokens(
      input: "123",
      [
        .number(.init(lexeme: "123", line: 1, column: 1), 123),
        .eof(.init(lexeme: "", line: 1, column: 4)),
      ]
    )
    assertTokens(
      input: "123.456",
      [
        .number(.init(lexeme: "123.456", line: 1, column: 1), 123.456),
        .eof(.init(lexeme: "", line: 1, column: 8)),
      ]
    )
  }

  func testIdentifiers() {
    assertTokens(
      input: "foobar",
      [
        .identifier(.init(lexeme: "foobar", line: 1, column: 1)),
        .eof(.init(lexeme: "", line: 1, column: 7)),
      ]
    )
  }

  func testKeywords() {
    assertTokens(
      input: [
        "and",
        "class",
        "else",
        "false",
        "for",
        "fun",
        "if",
        "nil",
        "or",
        "print",
        "return",
        "super",
        "this",
        "true",
        "var",
        "while",
      ].joined(separator: "\n"),
      [
        .and(.init(lexeme: "and", line: 1, column: 1)),
        .class(.init(lexeme: "class", line: 2, column: 1)),
        .else(.init(lexeme: "else", line: 3, column: 1)),
        .false(.init(lexeme: "false", line: 4, column: 1)),
        .for(.init(lexeme: "for", line: 5, column: 1)),
        .fun(.init(lexeme: "fun", line: 6, column: 1)),
        .if(.init(lexeme: "if", line: 7, column: 1)),
        .nil(.init(lexeme: "nil", line: 8, column: 1)),
        .or(.init(lexeme: "or", line: 9, column: 1)),
        .print(.init(lexeme: "print", line: 10, column: 1)),
        .return(.init(lexeme: "return", line: 11, column: 1)),
        .super(.init(lexeme: "super", line: 12, column: 1)),
        .this(.init(lexeme: "this", line: 13, column: 1)),
        .true(.init(lexeme: "true", line: 14, column: 1)),
        .var(.init(lexeme: "var", line: 15, column: 1)),
        .while(.init(lexeme: "while", line: 16, column: 1)),
        .eof(.init(lexeme: "", line: 16, column: 6)),
      ]
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
    expected.type,
    actual.type,
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
    expected.line,
    actual.line,
    "lines don't match",
    file: file,
    line: line
  )

  XCTAssertEqual(
    expected.column,
    actual.column,
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
