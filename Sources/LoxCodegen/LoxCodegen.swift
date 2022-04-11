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
      .init("Assign", ("name", "Token"), ("value", "Expr")),
      .init("Binary", ("left", "Expr"), ("operator", "Token"), ("right", "Expr")),
      .init("Call", ("callee", "Expr"), ("paren", "Token"), ("arguments", "[Expr]")),
      .init("Get", ("object", "Expr"), ("name", "Token")),
      .init("Grouping", ("expression", "Expr")),
      .init("Literal", ("value", "Ast.Literal")),
      .init("Logical", ("left", "Expr"), ("operator", "Token"), ("right", "Expr")),
      .init("Set", ("object", "Expr"), ("name", "Token"), ("value", "Expr")),
      .init("Super", ("keyword", "Token"), ("method", "Token")),
      .init("This", ("keyword", "Token")),
      .init("Unary", ("operator", "Token"), ("right", "Expr")),
      .init("Variable", ("name", "Token")),
    ])
    defineAst(baseName: "Stmt", types: [
      .init("Block", ("statements", "[Stmt]")),
      .init(
        "Class",
        ("name", "Token"),
        ("superclass", "Ast.Expression.Variable?"),
        ("methods", "[Ast.Statement.Function]")
      ),
      .init("Expression", ("expression", "Expr")),
      .init("Function", ("name", "Token"), ("params", "[Token]"), ("body", "[Stmt]")),
      .init("If", ("condition", "Expr"), ("thenBranch", "Stmt"), ("elseBranch", "Stmt?")),
      .init("Print", ("expression", "Expr")),
      .init("Return", ("keyword", "Token"), ("value", "Expr?")),
      .init("Var", ("name", "Token"), ("initializer", "Expr?")),
      .init("While", ("condition", "Expr"), ("body", "Stmt")),
    ])
  }

  private static func defineAst(
    baseName: String,
    types: [AstType]
  ) {
    let cwd = FileManager.default.currentDirectoryPath
    let path = "\(cwd)/Sources/LoxAst/Ast\(baseName)+Generated.swift"

    let structs = types
      .map { defineType(baseName: baseName, type: $0) }
      .joined(separator: "\n\n  ")

    let code = """
    // auto-generated, do not edit
    import Foundation
    import LoxScanner

    public protocol \(proto(from: baseName))Visitor {
      associatedtype \(visitorAssociatedType(from: baseName))
      \(visitorFuncs(for: types, baseName: baseName))
    }

    public extension Ast.\(astSubType(from: baseName)) {
      \(structs)
    } 

    """

    try! code.write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
  }

  private static func visitorFuncs(for types: [AstType], baseName: String) -> String {
    types
      .map {
        "func visit\($0.name)\(proto(from: baseName))(_ \(proto(from: baseName).lowercased()): Ast.\(astSubType(from: baseName)).\($0.name)) throws -> \(visitorAssociatedType(from: baseName))"
      }
      .joined(separator: "\n  ")
  }

  private static func defineType(baseName: String, type: AstType) -> String {
    let typeProto = proto(from: baseName)
    let assignments = type.props
      .map { name, _ in "self.\(name) = \(backtick(name))" }
      .joined(separator: "\n      ")

    let propDecls = type.props
      .map { name, type in "public let \(backtick(name)): \(type)" }
      .joined(separator: "\n    ")

    let initParams = type.props
      .map { name, type in "\(name): \(type)" }
      .joined(separator: ", ")

    return """
    struct \(type.name): \(typeProto) {
        public let id = UUID()
        \(propDecls)

        public init(\(initParams)) {
          \(assignments)
        }

        public func accept<V: \(typeProto)Visitor>(visitor: V) throws -> V.\(visitorAssociatedType(from: baseName)) {
          try visitor.visit\(type.name)\(typeProto)(self)
        }
      }
    """
  }
}

// helper fns

private func backtick(_ identifier: String) -> String {
  switch identifier {
  case "operator":
    return "`operator`"
  default:
    return identifier
  }
}

private func proto(from baseName: String) -> String {
  baseName == "Expression" ? "Expr" : "Stmt"
}

private func visitorAssociatedType(from baseName: String) -> String {
  baseName == "Stmt" ? "SR" : "ER"
}

private func astSubType(from baseName: String) -> String {
  baseName == "Stmt" ? "Statement" : "Expression"
}
