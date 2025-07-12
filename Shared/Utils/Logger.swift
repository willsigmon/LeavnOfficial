import os.log
import Foundation

public enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

public final class Logger {
    private let subsystem: String
    private let category: String
    private let logger: os.Logger
    
    public init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }
    
    public func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "[\(level.rawValue)] \(fileName):\(line) - \(function) - \(message)"
        
        switch level {
        case .debug:
            logger.debug("\(logMessage)")
        case .info:
            logger.info("\(logMessage)")
        case .warning:
            logger.warning("\(logMessage)")
        case .error:
            logger.error("\(logMessage)")
        }
    }
    
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
}

// MARK: - Shared Logger Instance

public extension Logger {
    static let shared = Logger(subsystem: "com.leavn.app", category: "general")
    static let ui = Logger(subsystem: "com.leavn.app", category: "ui")
    static let network = Logger(subsystem: "com.leavn.app", category: "network")
    static let data = Logger(subsystem: "com.leavn.app", category: "data")
}