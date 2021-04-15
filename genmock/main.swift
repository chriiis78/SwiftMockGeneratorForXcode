import Commander
import Foundation
import SwiftyKit
import MockGenerator

func validateTemplateName(_ templateName: String) throws -> String {
    guard validTemplateNames.contains(templateName) else {
        throw error("You must choose a valid template name: \(formattedValidTemplateNames)")
    }
    return templateName
}

let validTemplateNames = ["customspy", "spy", "stub", "dummy", "partial"]
var formattedValidTemplateNames: String = validTemplateNames.joined(separator: "|")

command(
    Argument<String>(
        "project-directory",
        description: "The project directory will be searched to find all the target types to be mocked."
    ),
    VariadicOption<String>(
        "target-name",
        default: [],
        description: "The name of the protocol or class to mock. You may specify more that one e.g. --target-name MyProtocol --target-name MyClass"
    ),
    VariadicOption<String>(
        "import",
        default: [],
        description: "The name of a module to import. You may specify more than one e.g. --import MyModule --import Foundation"
    ),
    VariadicOption<String>(
        "testable-import",
        default: [],
        description: "The name of a module to import using the @testable attribute. You may specify more than one e.g. --testable-import MyModule --testable-import Foundation"
    ),
    Flag("use-tabs", description: "Include this flag to indent using tabs."),
    Option<Int>(
        "indentation-width",
        default: 4,
        description: "The number of spaces to indent. Ignored if --use-tabs is true."
    ),
    Option<String>(
        "template-name",
        default: "spy",
        description: "Possible values: \(formattedValidTemplateNames)",
        validator: validateTemplateName
    ),
    Option<String>(
        "mock-prefix",
        default: "",
        description: "The string to prepend to the target name when creating the mock class."
    ),
    Option<String>(
        "mock-postfix",
        default: "",
        description: "The string to append to the target name when creating the mock class."
    ),
    Option<String>(
        "out-dir",
        default: ".",
        description: "The directory used to write the mock class to disk."
    ),
    Option<String>(
        "generation-comment",
        default: "// DO NOT EDIT: Generated by https://github.com/seanhenry/SwiftMockGeneratorForXcode",
        description: "The comment displayed at the top of the file to indicate that it is a generated file."
    )
) { directory, targetNames, imports, testableImports, useTabs, indentationWidth, templateName, prefix, postfix, outDir, generationComment in
    if targetNames.isEmpty {
        throw error("You must specify at least one --target-name")
    }
    if prefix.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && postfix.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        throw error("You must specify --mock-prefix and/or --mock-postfix")
    }
    setUpSwifty(
        projectURL: URL(fileURLWithPath: directory),
        useTabs: useTabs,
        indentationWidth: indentationWidth
    )
    try targetNames.forEach { targetName in
        try GenerateMockCommand(
            targetName: targetName,
            importModules: imports,
            testableImportModules: testableImports,
            templateName: templateName,
            mockPrefix: prefix,
            mockPostfix: postfix,
            outDirectory: outDir,
            generationComment: generationComment
        ).execute()
    }
}.run()
