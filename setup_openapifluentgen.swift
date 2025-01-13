import Foundation

// MARK: - Helper Functions

/// Logs messages to the console.
func log(_ message: String) {
    print("[INFO] \(message)")
}

/// Ensures a directory exists and creates it if necessary.
func ensureDirectoryExists(at path: String) {
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: path) {
        try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        log("Created directory: \(path)")
    } else {
        log("Directory already exists: \(path)")
    }
}

/// Deletes a file if it exists.
func deleteFile(at path: String) {
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: path) {
        do {
            try fileManager.removeItem(atPath: path)
            log("Deleted file: \(path)")
        } catch {
            log("[ERROR] Failed to delete file: \(path) - \(error.localizedDescription)")
        }
    }
}

/// Deletes all `.log` files in the specified directory while preserving `.gitkeep`.
func deleteLogFiles(in directory: String) {
    let fileManager = FileManager.default
    guard let files = try? fileManager.contentsOfDirectory(atPath: directory) else {
        log("[ERROR] Failed to list contents of directory: \(directory)")
        return
    }
    for file in files {
        let filePath = "\(directory)/\(file)"
        if file.hasSuffix(".log") {
            deleteFile(at: filePath)
        }
    }
}

/// Deletes a directory and its contents.
func deleteDirectory(at path: String) {
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: path) {
        do {
            try fileManager.removeItem(atPath: path)
            log("Deleted directory: \(path)")
        } catch {
            log("[ERROR] Failed to delete directory: \(path) - \(error.localizedDescription)")
        }
    }
}

/// Replaces text in a file.
func replaceText(in filePath: String, from oldText: String, to newText: String) {
    guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
        log("[ERROR] Failed to read file: \(filePath)")
        return
    }
    let updatedContent = content.replacingOccurrences(of: oldText, with: newText)
    try? updatedContent.write(toFile: filePath, atomically: true, encoding: .utf8)
    log("Updated \(filePath): \(oldText) -> \(newText)")
}

// MARK: - Main Script

let newProjectName = "OpenAPIFluentGen"
let oldProjectName = "OpenAPIHandlerGen"
let fileManager = FileManager.default

// Locate the repository root
guard let repoRoot = fileManager.currentDirectoryPath as String? else {
    log("[ERROR] Failed to locate the repository root.")
    exit(1)
}

// Step 1: Rename OpenAPIHandlerGen to OpenAPIFluentGen
let oldSourceRoot = "\(repoRoot)/\(oldProjectName)"
let newSourceRoot = "\(repoRoot)/\(newProjectName)"
if fileManager.fileExists(atPath: oldSourceRoot) {
    do {
        try fileManager.moveItem(atPath: oldSourceRoot, toPath: newSourceRoot)
        log("Renamed \(oldProjectName) to \(newProjectName)")
    } catch {
        log("[ERROR] Failed to rename \(oldProjectName) to \(newProjectName) - \(error.localizedDescription)")
    }
}

// Step 2: Update Package.swift
let packagePath = "\(repoRoot)/Package.swift"
replaceText(in: packagePath, from: oldProjectName, to: newProjectName)

// Step 3: Delete marked files and directories
// Docs directory
deleteDirectory(at: "\(repoRoot)/Docs")

// Generated directory files
deleteFile(at: "\(newSourceRoot)/TestOutput/Handlers/getUsersHandler.swift")

// Delete output.swift handlers
let outputHandlers = [
    "\(newSourceRoot)/output.swift/Handlers/Handler.swift",
    "\(newSourceRoot)/output.swift/Handlers/getHandler.swift",
    "\(newSourceRoot)/output.swift/Handlers/postHandler.swift"
]
for file in outputHandlers {
    deleteFile(at: file)
}

// Delete redundant tests
let testsToDelete = [
    "\(newSourceRoot)/Tests/GeneratedFilesPresenceTests.swift",
    "\(newSourceRoot)/Tests/HandlerGeneratorTests.swift",
    "\(newSourceRoot)/Tests/TemplateVerificationTests.swift"
]
for test in testsToDelete {
    deleteFile(at: test)
}

// Core generator files
deleteFile(at: "\(newSourceRoot)/Sources/Core/OpenAPIHandlerGen.swift")

// Generators directory
let generatorFilesToDelete = [
    "\(newSourceRoot)/Sources/Generators/HandlerGenerator.swift",
    "\(newSourceRoot)/Sources/Generators/ServiceGenerator.swift"
]
for file in generatorFilesToDelete {
    deleteFile(at: file)
}

// Step 4: Clean up TestLogs directory (delete `.log` files, keep `.gitkeep`)
deleteLogFiles(in: "\(repoRoot)/TestLogs")

// Step 5: Finalize
log("Restructuring completed successfully!")
