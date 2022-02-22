import XCTest

@testable import LoxScanner

final class LoxScannerTests: XCTestCase {
  func testSimple() throws {
    let scanner = Scanner(source: "(")
    let tokens = scanner.getTokens()
    assertTokens(
      tokens,
      [
        .leftParen(.init(lexeme: "(", offset: 0)),
        .eof(.init(lexeme: "", offset: 1)),
      ]
    )
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
