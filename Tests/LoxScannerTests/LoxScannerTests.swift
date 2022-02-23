import XCTest

@testable import LoxScanner

final class LoxScannerTests: XCTestCase {
  func testBasicTokens() throws {
    assertTokens(
      getTokens("(){},-.+;*!!=;==;>;>=;/"),
      [
        .leftParen(.init(lexeme: "(", offset: 1)),
        .rightParen(.init(lexeme: ")", offset: 2)),
        .leftBrace(.init(lexeme: "{", offset: 3)),
        .rightBrace(.init(lexeme: "}", offset: 4)),
        .comma(.init(lexeme: ",", offset: 5)),
        .minus(.init(lexeme: "-", offset: 6)),
        .dot(.init(lexeme: ".", offset: 7)),
        .plus(.init(lexeme: "+", offset: 8)),
        .semicolon(.init(lexeme: ";", offset: 9)),
        .star(.init(lexeme: "*", offset: 10)),
        .bang(.init(lexeme: "!", offset: 11)),
        .bangEqual(.init(lexeme: "!=", offset: 13)),
        .semicolon(.init(lexeme: ";", offset: 14)),
        .equalEqual(.init(lexeme: "==", offset: 16)),
        .semicolon(.init(lexeme: ";", offset: 17)),
        .greater(.init(lexeme: ">", offset: 18)),
        .semicolon(.init(lexeme: ";", offset: 19)),
        .greaterEqual(.init(lexeme: ">=", offset: 21)),
        .semicolon(.init(lexeme: ";", offset: 22)),
        .slash(.init(lexeme: "/", offset: 23)),
        .eof(.init(lexeme: "", offset: 24)),
      ]
    )
  }

  func testCommentSkipped() {
    assertTokens(
      getTokens(";// foo bar\n;"),
      [
        .semicolon(.init(lexeme: ";", offset: 1)),
        .semicolon(.init(lexeme: ";", offset: 13)),
        .eof(.init(lexeme: "", offset: 14)),
      ]
    )
  }

  func testUnexpectedCharacter() {
    var errorHandlerCalled = false
    assertTokens(
      getTokens(";•;", onError: { line, message in
        errorHandlerCalled = true
        XCTAssertEqual(1, line)
        XCTAssertEqual("Unexpected character.", message)
      }),
      [
        .semicolon(.init(lexeme: ";", offset: 1)),
        .semicolon(.init(lexeme: ";", offset: 3)),
        .eof(.init(lexeme: "", offset: 4)),
      ]
    )
    XCTAssertEqual(errorHandlerCalled, true)
  }

  func getTokens(
    _ input: String,
    onError: ((Int, String) -> Void)? = nil,
    function: StaticString = #function
  ) -> [Token] {
    let scanner = Scanner(
      source: input,
      onError: onError ?? { _, _ in fatalError("Unexpected error in test function: \(function)") }
    )
    return scanner.getTokens()
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
    expected.meta.offset,
    actual.meta.offset,
    "offsets don't match",
    file: file,
    line: line
  )
  XCTAssertEqual(
    expected.meta.trivia,
    actual.meta.trivia,
    "trivia doesn't match",
    file: file,
    line: line
  )
}
