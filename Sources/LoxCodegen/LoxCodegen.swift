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
      .init("Assignment", ("name", "Token"), ("value", "Expr")),
      .init("Binary", ("left", "Expr"), ("operator", "Token"), ("right", "Expr")),
      .init("Grouping", ("expression", "Expr")),
      .init("Literal", ("value", "Ast.Literal")),
      .init("Unary", ("operator", "Token"), ("right", "Expr")),
      .init("Variable", ("name", "Token")),
    ])
    defineAst(baseName: "Stmt", types: [
      .init("Block", ("statements", "[Stmt]")),
      .init("Expression", ("expression", "Expr")),
      .init("Print", ("expression", "Expr")),
      .init("Var", ("name", "Token"), ("initializer", "Expr?")),
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
    return types
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
