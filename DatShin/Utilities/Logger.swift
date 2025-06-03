import Foundation
import os.log

enum LogLevel: String {
    case debug = "🔍"
    case info = "ℹ️"
    case warning = "⚠️"
    case error = "❌"
    case critical = "🔥"
}

protocol LoggerProtocol {
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int)
}

class Logger: LoggerProtocol {
    static let shared = Logger()
    private let osLog: OSLog
    
    private init() {
        osLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.datshin", category: "DatShin")
    }
    
    func log(_ message: String, level: LogLevel, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(level.rawValue) [\(fileName):\(line)] \(function): \(message)"
        
        switch level {
        case .debug:
            os_log(.debug, log: osLog, "%{public}@", logMessage)
        case .info:
            os_log(.info, log: osLog, "%{public}@", logMessage)
        case .warning:
            os_log(.default, log: osLog, "%{public}@", logMessage)
        case .error:
            os_log(.error, log: osLog, "%{public}@", logMessage)
        case .critical:
            os_log(.fault, log: osLog, "%{public}@", logMessage)
        }
        
        #if DEBUG
        print(logMessage)
        #endif
    }
}

// Convenience methods
extension Logger {
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .critical, file: file, function: function, line: line)
    }
} 