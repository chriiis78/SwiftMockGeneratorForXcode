import XCTest
import TestHelper
import AST
import Resolver
@testable import MockGenerator

class VariableTypeResolverTests: XCTestCase {
  func test_shouldResolveTypeAnnotation() {
    assertResolve("var a: A", "A")
  }

  func test_shouldResolveInitializerWithLiteral() {
    assertResolve("var a = \"\"", "String")
    assertResolve("var a = 0", "Int")
    assertResolve("var a = true", "Bool")
    assertResolve("var a = 0.1", "Double")
  }

  func test_shouldResolveInitializerWithArrayLiteral() {
    assertResolve("var a = [\"abc\"]", "[String]")
    assertResolve("var a = [0, 1]", "[Int]")
    assertResolve("var a = [true]", "[Bool]")
    assertResolve("var a = [0.1]", "[Double]")
    assertResolveNil("var a = []")
  }

  func test_shouldResolveInitializerWithDictionaryLiteral() {
    assertResolve("var a = [\"abc\": 0]", "[String: Int]")
    assertResolveNil("var a = [:]")
  }

  func test_shouldResolveInitializerWithArrayFunctionCall() {
    assertResolve("var a = [Int]()", "[Int]")
  }

  func test_shouldResolveInitializerWithDictionaryFunctionCall() {
    assertResolve("var a = [Int: String]()", "[Int: String]")
  }

  func test_shouldResolveInitializerWithFunctionCallResolvingToMethod() {
    assertResolve("var a = returnMethod()", "ReturnMethodType")
  }

  private func assertResolve(_ text: String, _ expected: String, line: UInt = #line) {
    let fullText = """
    \(text)
    func returnMethod() -> ReturnMethodType {}
    """
    XCTAssertEqual(try resolve(fullText), expected, line: line)
  }

  private func assertResolveNil(_ text: String, line: UInt = #line) {
    XCTAssertNil(try resolve(text), line: line)
  }

  private func resolve(_ text: String) throws -> String? {
    return VariableTypeResolver.resolve(try parse(text), resolver: ResolverFactory.createResolver(filePaths: []))
  }

  private func parse(_ text: String) throws -> Element {
    return try ParserTestHelper.parseFile(from: text).children[0]
  }
}