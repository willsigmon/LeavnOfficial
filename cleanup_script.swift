#!/usr/bin/swift
import Foundation

struct Issue {
    let file: String
    let line: Int
    let content: String
    let type: IssueType
}

enum IssueType {
    case todo
    case print
    case commentedCode
}

func scanSwiftFiles(in directory: String) -> [Issue] {
    var issues: [Issue] = []
    let fileManager = FileManager.default
    
    func scanDirectory(path: String) {
        guard let enumerator = fileManager.enumerator(atPath: path) else { return }
        
        while let element = enumerator.nextObject() as? String {
            let fullPath = (path as NSString).appendingPathComponent(element)
            
            // Skip certain directories
            if element.contains(".git") || element.contains("node_modules") || 
               element.contains(".build") || element.contains("DerivedData") {
                enumerator.skipDescendants()
                continue
            }
            
            if element.hasSuffix(".swift") {
                scanFile(at: fullPath)
            }
        }
    }
    
    func scanFile(at path: String) {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else { return }
        let lines = content.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            let lineNumber = index + 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Check for TODO/FIXME
            if trimmed.contains("TODO") || trimmed.contains("FIXME") {
                issues.append(Issue(file: path, line: lineNumber, content: trimmed, type: .todo))
            }
            
            // Check for print statements (not in comments)
            if line.contains("print(") && !trimmed.hasPrefix("//") {
                issues.append(Issue(file: path, line: lineNumber, content: trimmed, type: .print))
            }
            
            // Check for commented code
            if trimmed.hasPrefix("//") && trimmed.count > 2 {
                let commentContent = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                let codePatterns = ["let ", "var ", "func ", "class ", "struct ", "if ", "for ", 
                                   "while ", ".sink", "import ", "@", "= ", "Task {", "await "]
                
                if codePatterns.contains(where: { commentContent.contains($0) }) {
                    issues.append(Issue(file: path, line: lineNumber, content: trimmed, type: .commentedCode))
                }
            }
        }
    }
    
    scanDirectory(path: directory)
    return issues
}

// Main execution
let directory = "/Users/wsig/Cursor Repos/LeavnOfficial"
print("Scanning Swift files in \(directory)...")

let issues = scanSwiftFiles(in: directory)

let todos = issues.filter { $0.type == .todo }
let prints = issues.filter { $0.type == .print }
let commented = issues.filter { $0.type == .commentedCode }

print("\nScan Results:")
print("TODO/FIXME comments: \(todos.count)")
print("Print statements: \(prints.count)")
print("Commented code blocks: \(commented.count)")

// Write report
var report = "=== CODE CLEANUP REPORT ===\n\n"
report += "TODO/FIXME comments: \(todos.count)\n"
report += "Print statements: \(prints.count)\n"
report += "Commented code blocks: \(commented.count)\n\n"

report += "=== TODO/FIXME COMMENTS ===\n"
for issue in todos {
    report += "\n\(issue.file):\(issue.line)\n"
    report += "  \(issue.content)\n"
}

report += "\n\n=== PRINT STATEMENTS ===\n"
for issue in prints {
    report += "\n\(issue.file):\(issue.line)\n"
    report += "  \(issue.content)\n"
}

report += "\n\n=== COMMENTED CODE (first 50) ===\n"
for issue in commented.prefix(50) {
    report += "\n\(issue.file):\(issue.line)\n"
    report += "  \(issue.content)\n"
}

if commented.count > 50 {
    report += "\n... and \(commented.count - 50) more commented code blocks\n"
}

let reportPath = (directory as NSString).appendingPathComponent("cleanup_report.txt")
try? report.write(toFile: reportPath, atomically: true, encoding: .utf8)

print("\nDetailed report written to cleanup_report.txt")