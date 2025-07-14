// swiftlint:disable all
// Generated using TuistBundle

import Foundation

// MARK: - Bundle Extension

public extension Bundle {
    /// The resource bundle for the Leavn module.
    /// This provides access to all resources including assets, strings, and other bundled files.
    static var module: Bundle = {
        let bundleName = "Leavn_Leavn"
        
        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,
            
            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: BundleToken.self).resourceURL,
            
            // For command-line tools.
            Bundle.main.bundleURL,
            
            // For Swift Package Manager resources
            Bundle.module.bundleURL,
        ]
        
        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        
        // If we can't find the resource bundle, fall back to the main bundle
        return Bundle(for: BundleToken.self)
    }()
    
    /// Convenience accessor for the module bundle
    static var leavn: Bundle {
        return .module
    }
}

// MARK: - Resource Accessors

public extension Bundle {
    /// Returns the URL for a resource with the given name and extension in the bundle.
    /// - Parameters:
    ///   - name: The name of the resource file.
    ///   - ext: The extension of the resource file.
    /// - Returns: The URL for the resource, or nil if not found.
    func urlForResource(name: String, ext: String) -> URL? {
        return self.url(forResource: name, withExtension: ext)
    }
    
    /// Returns the path for a resource with the given name and extension in the bundle.
    /// - Parameters:
    ///   - name: The name of the resource file.
    ///   - ext: The extension of the resource file.
    /// - Returns: The path for the resource, or nil if not found.
    func pathForResource(name: String, ext: String) -> String? {
        return self.path(forResource: name, ofType: ext)
    }
    
    /// Loads data from a resource file in the bundle.
    /// - Parameters:
    ///   - name: The name of the resource file.
    ///   - ext: The extension of the resource file.
    /// - Returns: The data from the resource file, or nil if not found or cannot be loaded.
    func dataForResource(name: String, ext: String) -> Data? {
        guard let url = urlForResource(name: name, ext: ext) else { return nil }
        return try? Data(contentsOf: url)
    }
    
    /// Loads a string from a resource file in the bundle.
    /// - Parameters:
    ///   - name: The name of the resource file.
    ///   - ext: The extension of the resource file.
    ///   - encoding: The string encoding to use (default is .utf8).
    /// - Returns: The string from the resource file, or nil if not found or cannot be loaded.
    func stringForResource(name: String, ext: String, encoding: String.Encoding = .utf8) -> String? {
        guard let data = dataForResource(name: name, ext: ext) else { return nil }
        return String(data: data, encoding: encoding)
    }
}

// MARK: - Localization Support

public extension Bundle {
    /// Returns a localized string for the given key.
    /// - Parameters:
    ///   - key: The key for the localized string.
    ///   - tableName: The name of the strings file (default is nil, which uses Localizable.strings).
    ///   - value: The default value to return if the key is not found.
    ///   - comment: A comment to help translators understand the context.
    /// - Returns: The localized string.
    func localizedString(for key: String, tableName: String? = nil, value: String? = nil, comment: String = "") -> String {
        return NSLocalizedString(key, tableName: tableName, bundle: self, value: value ?? key, comment: comment)
    }
}

// MARK: - Private Token

private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }()
}

// swiftlint:enable all