import Foundation
import os.log

// Logger cache actor to handle the dictionary in a thread-safe way
private actor LoggerCache {
    private var loggers: [LogCategory: OSLog] = [:]
    private let subsystem: String
    
    init(subsystem: String) {
        self.subsystem = subsystem
    }
    
    func logger(for category: LogCategory) -> OSLog {
        if let existing = loggers[category] {
            return existing
        }
        let newLogger = OSLog(subsystem: subsystem, category: category.rawValue)
        loggers[category] = newLogger
        return newLogger
    }
}

public final class Logger: Sendable {
    public static let shared = Logger()
    
    private let subsystem = Bundle.main.bundleIdentifier ?? "com.leavn.app"
    private let loggerCache: LoggerCache
    
    private init() {
        self.loggerCache = LoggerCache(subsystem: subsystem)
    }
    
    // MARK: - Public Logging Methods
    public func debug(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, message: message, category: category, file: file, function: function, line: line)
    }
    
    public func info(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, category: category, file: file, function: function, line: line)
    }
    
    public func warning(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .default, message: message, category: category, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, error: Error? = nil, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        let errorMessage = error != nil ? "\(message) - Error: \(error!.localizedDescription)" : message
        log(level: .error, message: errorMessage, category: category, file: file, function: function, line: line)
    }
    
    public func fault(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .fault, message: message, category: category, file: file, function: function, line: line)
    }
    
    // MARK: - Performance Logging
    public func performance<T>(_ message: String, category: LogCategory = .performance, operation: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            info("\(message) - Completed in \(String(format: "%.3f", timeElapsed))s", category: category)
        }
        return try operation()
    }
    
    public func performanceAsync<T>(_ message: String, category: LogCategory = .performance, operation: () async throws -> T) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            info("\(message) - Completed in \(String(format: "%.3f", timeElapsed))s", category: category)
        }
        return try await operation()
    }
    
    // MARK: - Private Methods
    private func log(level: OSLogType, message: String, category: LogCategory, file: String, function: String, line: Int) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "[\(fileName):\(line)] \(function) - \(message)"
        
        Task {
            let logger = await loggerCache.logger(for: category)
            os_log("%{public}@", log: logger, type: level, logMessage)
        }
        
        #if DEBUG
        print("\(timestamp()) [\(category.rawValue.uppercased())] \(logMessage)")
        #endif
    }
    
    private func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
}

// MARK: - Log Categories
public enum LogCategory: String, CaseIterable, Sendable {
    case general = "general"
    case network = "network"
    case database = "database"
    case ui = "ui"
    case authentication = "auth"
    case sync = "sync"
    case performance = "performance"
    case analytics = "analytics"
    case cache = "cache"
}

// MARK: - Convenience Methods
public func logDebug(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.debug(message, category: category, file: file, function: function, line: line)
}

public func logInfo(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.info(message, category: category, file: file, function: function, line: line)
}

public func logWarning(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.warning(message, category: category, file: file, function: function, line: line)
}

public func logError(_ message: String, error: Error? = nil, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.error(message, error: error, category: category, file: file, function: function, line: line)
}
