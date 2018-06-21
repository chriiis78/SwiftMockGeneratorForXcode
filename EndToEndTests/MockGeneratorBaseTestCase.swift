import XCTest
import XcodeKit
@testable import XcodePluginProxy

class MockGeneratorBaseTestCase: XCTestCase {

    override class func setUp() {
        super.setUp()
        let prefs = Preferences()
        prefs.automaticallyDetectProjectPath = false
        prefs.projectPath = URL(fileURLWithPath: testProject)
        XPCManager.setUpConnection()
    }

    override class func tearDown() {
        let prefs = Preferences()
        prefs.automaticallyDetectProjectPath = true
        XPCManager.connection.connection.invalidate()
        super.tearDown()
    }

    func assertMockGeneratesExpected(_ fileName: String, file: StaticString = #file, line: UInt = #line) {
        let command = TestCommand()
        let invocation = createCommandInvocation(fileName)
        let expected = getExpected(fileName)
        let e = expectation(description: #function)
        command.perform(with: invocation) { (error) in
            XCTAssertNil(error, file: file, line: line)
            XCTAssertEqual(invocation.sourceTextBuffer.completeBuffer, expected, file: file, line: line)
            e.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    private func getExpected(_ fileName: String) -> String {
        return readFile(named: fileName + "_expected.swift")
    }

    private func createCommandInvocation(_ fileName: String) -> SourceEditorCommandInvocation {
        let contents = readFile(named: fileName + ".swift")
        let contentsLineColumn = CaretTestHelper.findCaretLineColumn(contents)
        let (line, column) = contentsLineColumn.lineColumn!
        let selection = XCSourceTextRange(start: XCSourceTextPosition(line: line - 1, column: column), end: XCSourceTextPosition(line: line, column: column))
        let buffer = SourceTextBufferStub(buffer: contentsLineColumn.contents, selections: NSMutableArray(object: selection))
        let stub = CommandInvocationStub(buffer: buffer)
        return stub
    }

    private func readFile(named fileName: String) -> String {
        return try! String(contentsOfFile: testProject + "/" + fileName)
    }

    class TestCommand: BaseCommand {
        override var templateName: String {
            return "spy"
        }
    }

    class SourceTextBufferStub: SourceTextBuffer {
        var selections: NSMutableArray = NSMutableArray()
        var completeBuffer: String = ""

        init(buffer: String, selections: NSMutableArray) {
            self.completeBuffer = buffer
            self.selections = selections
        }
    }

    class CommandInvocationStub: SourceEditorCommandInvocation {
        var commandIdentifier: String = "test"
        var sourceTextBuffer: SourceTextBuffer
        var cancellationHandler: () -> () = {}

        init(buffer: SourceTextBuffer) {
            self.sourceTextBuffer = buffer
        }
    }
}
