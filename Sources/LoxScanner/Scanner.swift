public struct Scanner {
  let source: String

  public init(source: String) {
    self.source = source
  }

  public func tokens() -> [String] {
    ["Hello from the scanner"]
  }
}
