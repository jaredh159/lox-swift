import LoxAst
import LoxInterpreter
import LoxParser
import LoxScanner
import XCTest

final class InterpreterTests: XCTestCase {

  func testBoundMethods() {
    assertNoRuntimeError("""
    class Person {
      getName() {
        return this.name;
      }
    }

    var jane = Person();
    jane.name = "Jane";

    var bill = Person();
    bill.name = "Bill";

    bill.getName = jane.getName;
    assertEqual(bill.getName(), "Jane");
    """)
  }

  func testWeirdScopeEdgeCase() throws {
    assertNoRuntimeError("""
    var a = "global";
    {
      fun testA() {
        assertEqual(a, "global"); // 👋
      }

      testA();
      var a = "block";
      testA();
    }
    """)
  }

  func testEvaluatingExpressions() throws {
    let cases: [(String, Object)] = [
      ("1", 1),
      ("2", 2),
      ("nil", nil),
      ("3.145", 3.145),
      ("true", true),
      ("false", false),
      ("nil", nil),
      ("(1)", 1),
      ("(true)", true),
      ("-1", -1),
      ("!nil", true),
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
      ("1 < 2", true),
      ("2 < 2", false),
      ("2 <= 2", true),
      ("3 > 2", true),
      ("3 > 4", false),
      ("3 >= 3", true),
      ("3 == 3", true),
      ("nil == nil", true),
      ("nil != nil", false),
      ("3 == 4", false),
      ("3 != 3", false),
      ("3 != 4", true),
      ("3 == \"three\"", false),
      ("3 != \"three\"", true),
    ]
    for (input, expected) in cases {
      XCTAssertEqual(try eval(input + ";").get(), expected)
    }
  }

  func testRuntimeErrors() throws {
    let cases: [(String, RuntimeError.ErrorType)] = [
      ("-true", .invalidUnaryMinusOperand(true)),
      ("-nil", .invalidUnaryMinusOperand(nil)),
      ("-\"foo\"", .invalidUnaryMinusOperand("foo")),
      ("true > false", .invalidBinaryOperands(lhs: true, operator: .greater, rhs: false)),
      ("nil >= \"foo\"", .invalidBinaryOperands(lhs: nil, operator: .greaterEqual, rhs: "foo")),
    ]
    for (input, expected) in cases {
      switch eval(input + ";") {
      case .failure(let error):
        XCTAssertEqual(error.type, expected)
      case .success:
        XCTAssertTrue(false, "Unexpected lack of error for input `\(input)`")
      }
    }
  }

  func testGetSetInstanceFields() throws {
    assertNoRuntimeError("""
    class Foo {}
    var foo = Foo();
    foo.bar = 1;
    assertEqual(foo.bar, 1);
    """)
  }

  func testCallClassMethods() throws {
    assertNoRuntimeError("""
    class Bacon {
      eat() {
        return "crunch crunch";
      }
    } 
    assertEqual(Bacon().eat(), "crunch crunch");
    """)
  }

  func testThisBinding() throws {
    assertNoRuntimeError("""
    class Cake {
      taste() {
        var adjective = "delicious";
        return "The " + this.flavor + " cake is " + adjective + "!";
      }
    }

    var cake = Cake();
    cake.flavor = "German chocolate";
    assertEqual(cake.taste(), "The German chocolate cake is delicious!");
    """)
  }

  func testThisBindingEdgeCase() throws {
    assertNoRuntimeError("""
    class Thing {
      getCallback() {
        fun localFunction() {
          return this.name;
        }

        return localFunction;
      }
    }

    var thing = Thing();
    thing.name = "Bob";
    var callback = thing.getCallback();
    assertEqual(callback(), "Bob");
    """)
  }

  func testClassInitReturnsThis() throws {
    assertNoRuntimeError("""
    class Foo {
      init() {}
    } 
    var foo = Foo();
    foo.bar = "bar";
    assertEqual(foo.init().bar, "bar");
    """)
  }

  func testClassInitCanReturnEarly() throws {
    assertNoRuntimeError("""
    class Foo {
      init() {
        return;
      }
    } 
    var foo = Foo();
    foo.bar = "bar";
    assertEqual(foo.init().bar, "bar");
    """)
  }

  func testNonClassSuperclassIsRuntimeError() throws {
    assertRuntimeError(
      """
      var NotAClass = "I am totally not a class";
      class Subclass < NotAClass {} 
      """,
      .invalidSuperclass("NotAClass")
    )
  }

  func testClassInheritance() throws {
    assertNoRuntimeError("""
    class Parent {
      one() {
        return 1;
      }
    }
    class Child < Parent {}
    assertEqual(Child().one(), 1);
    """)
  }

  func testSuperMethodCall() throws {
    assertNoRuntimeError("""
    class Parent {
      one() {
        return 1;
      }
    }
    class Child < Parent {
      one() {
        return super.one() + 2;
      }
    }
    assertEqual(Child().one(), 3);
    """)
  }

  func testSuperMethodResolutionEdgeCase() throws {
    assertNoRuntimeError("""
    class A {
      method() {
        return "A method";
      }
    }

    class B < A {
      method() {
        return "B method";
      }

      test() {
        return super.method();
      }
    }

    class C < B {}

    assertEqual(C().test(), "A method");
    """)
  }
}

private func interpret(_ input: String, testCase: StaticString = #fileID) -> RuntimeError? {
  let interpreter = Interpreter()
  let resolver = Resolver(interpreter: interpreter, errorHandler: { err in
    fatalError(
      "\(testCase) Resolver error for input:\n\n```\n\(input)\n```\n\n\(String(describing: err))\n\n"
    )
  })
  let statements = statements(from: input)
  try! resolver.resolve(statements)
  return interpreter.interpret(statements)
}

private func eval(_ input: String) -> Result<Object, RuntimeError> {
  let statements = statements(from: input)
  let interpreter = Interpreter()
  let resolver = Resolver(interpreter: interpreter, errorHandler: { print($0) })
  try! resolver.resolve(statements)
  let exprStatement = statements[0] as! Ast.Statement.Expression
  let expr = exprStatement.expression
  do {
    return .success(try interpreter.evaluate(expr))
  } catch {
    return .failure(error as! RuntimeError)
  }
}

private func assertRuntimeError(_ input: String, _ expectedError: RuntimeError.ErrorType) {
  XCTAssertEqual(interpret(input)?.type, expectedError)
}

private func assertNoRuntimeError(_ input: String) {
  XCTAssertNil(interpret(input))
}
