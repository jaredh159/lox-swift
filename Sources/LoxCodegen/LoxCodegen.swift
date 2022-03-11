import Foundation

@main enum Codegen {
  struct AstType {
    let name: String
    let props: [(String, String)]

    init(_ name: String, _ props: (String, String)...) {
      self.name = name
      self.props = props
    }
  }

  static func main() {
    defineAst(baseName: "Expression", types: [
      .init("Binary", ("left", "Expr"), ("operator", "Operator"), ("right", "Expr")),
      .init("Grouping", ("expression", "Expr")),
      .init("Literal", ("value", "Ast.Literal")),
      .init("Unary", ("operator", "Operator"), ("right", "Expr")),
    ])
  }

  private static func defineAst(
    baseName: String,
    types: [AstType]
  ) {
    let cwd = FileManager.default.currentDirectoryPath
    let path = "\(cwd)/Sources/LoxAst/Ast+Generated.swift"

    let structs = types
      .map { defineType(baseName: baseName, type: $0) }
      .joined(separator: "\n\n  ")

    let code = """
    // auto-generated, do not edit
    import LoxScanner

    public protocol ExprVisitor {
      associatedtype R
      \(visitorFuncs(for: types))
    }

    public enum Ast {
      public enum \(baseName) {
      \(structs)
      }
    }

    """

    try! code.write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
  }

  private static func visitorFuncs(for types: [AstType]) -> String {
    return types
      .map { "func visit\($0.name)(_ expr: Ast.Expression.\($0.name)) -> R" }
      .joined(separator: "\n  ")
  }

  private static func defineType(baseName: String, type: AstType) -> String {
    let assignments = type.props
      .map { name, _ in "self.\(name) = \(backtick(name))" }
      .joined(separator: "\n        ")

    let propDecls = type.props
      .map { name, type in "public let \(backtick(name)): \(type)" }
      .joined(separator: "\n      ")

    let initParams = type.props
      .map { name, type in "\(name): \(type)" }
      .joined(separator: ", ")

    return """
      public struct \(type.name): Expr {
          \(propDecls)

          public init(\(initParams)) {
            \(assignments)
          }

          public func accept<V: ExprVisitor>(visitor: V) -> V.R {
            return visitor.visit\(type.name)(self)
          }
        }
    """
  }
}

private func backtick(_ identifier: String) -> String {
  switch identifier {
  case "operator":
    return "`operator`"
  default:
    return identifier
  }
}
