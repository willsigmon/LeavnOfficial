#!/usr/bin/swift sh

import Foundation
import XcodeProj // tuist/xcodeproj ~> 8.21.0
import PathKit

guard CommandLine.arguments.count == 2 else {
   let arg0 = Path(CommandLine.arguments[0]).lastComponent
   fputs("usage: \(arg0) <project>\n", stderr)
   exit(1)
}

let productNames = [
    "LeavnCore",
    "DesignSystem",
    "LeavnServices",
    "AuthenticationModule",
    "LeavnBible",
    "LeavnSearch",
    "LeavnLibrary",
    "LeavnSettings",
    "LeavnCommunity"
] // Adjusted for project products.

let projectPath = Path(CommandLine.arguments[1])
let xcodeproj = try XcodeProj(path: projectPath) // Opening project.

// Preparing dependencies in Batch mode.
let packageDependencies = productNames.map { XCSwiftPackageProductDependency(productName: $0) }
packageDependencies.forEach { xcodeproj.pbxproj.add(object: $0) }

// Adding dependencies in Batch mode.
xcodeproj.pbxproj.nativeTargets.forEach {
   print("→ Adding dependencies to `\($0.name)`")
   if $0.packageProductDependencies == nil {
      $0.packageProductDependencies = []
   }
   $0.packageProductDependencies! += packageDependencies
}

try xcodeproj.write(path: projectPath) // Saving project. 