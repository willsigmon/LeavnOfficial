#!/usr/bin/swift

import Foundation

let projectPath = "/Users/wsig/Cursor Repos/LeavnOfficial/Leavn.xcodeproj/project.pbxproj"

print("🔧 Fixing package references in Xcode project...")

// Read the project file
guard let projectData = try? String(contentsOfFile: projectPath) else {
    print("❌ Failed to read project file")
    exit(1)
}

// Remove package references section
var modifiedProject = projectData

// Remove the packageReferences from the project
let packageRefPattern = #"packageReferences = \([^)]*\);"#
modifiedProject = modifiedProject.replacingOccurrences(
    of: packageRefPattern,
    with: "packageReferences = ();",
    options: .regularExpression
)

// Remove XCLocalSwiftPackageReference sections
let localPackagePattern = #"/\* Begin XCLocalSwiftPackageReference section \*/[\s\S]*?/\* End XCLocalSwiftPackageReference section \*/"#
modifiedProject = modifiedProject.replacingOccurrences(
    of: localPackagePattern,
    with: "/* Begin XCLocalSwiftPackageReference section */\n/* End XCLocalSwiftPackageReference section */",
    options: .regularExpression
)

// Remove XCSwiftPackageProductDependency sections
let productDepPattern = #"/\* Begin XCSwiftPackageProductDependency section \*/[\s\S]*?/\* End XCSwiftPackageProductDependency section \*/"#
modifiedProject = modifiedProject.replacingOccurrences(
    of: productDepPattern,
    with: "/* Begin XCSwiftPackageProductDependency section */\n/* End XCSwiftPackageProductDependency section */",
    options: .regularExpression
)

// Write the modified project back
do {
    try modifiedProject.write(toFile: projectPath, atomically: true, encoding: .utf8)
    print("✅ Removed all package references from project")
    print("")
    print("📋 Next steps:")
    print("1. Open Xcode")
    print("2. You'll see all packages are missing (this is expected)")
    print("3. Click on the project in navigator")
    print("4. Go to Package Dependencies tab")
    print("5. Click '+' and add:")
    print("   - Local package: Packages/LeavnCore")
    print("   - Local package: Modules")
    print("6. For each target, re-add the framework dependencies")
} catch {
    print("❌ Failed to write project file: \(error)")
    exit(1)
}