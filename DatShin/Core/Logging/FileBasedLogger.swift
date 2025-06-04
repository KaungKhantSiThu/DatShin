//
//  FileBasedLogger.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import Foundation
import OSLog

/// A logger implementation that logs to both console and file using Apple's unified logging system
final class FileBasedLogger: LoggerProtocol {
    // MARK: - Properties
    
    /// The native logger instance
    private let logger: os.Logger
    
    /// Whether to log to file
    private let logToFile: Bool
    
    /// The category within the subsystem
    private let category: String
    
    /// File logger for writing to log file
    private let fileLogger = FileLogger.shared
    
    /// Date formatter for log timestamps
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    /// Privacy level for logging
    private let privacy: OSLogPrivacy
    
    // MARK: - Initialization
    
    /// Initialize a new logger
    /// - Parameters:
    ///   - subsystem: The subsystem identifier (typically bundle ID)
    ///   - category: The category within the subsystem
    ///   - logToFile: Whether to log to file
    ///   - privacy: The privacy level for logging
    init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "com.datshin",
        category: String = "default",
        logToFile: Bool = true,
        privacy: OSLogPrivacy = .auto
    ) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
        self.category = category
        self.logToFile = logToFile
        self.privacy = privacy
    }
    
    // MARK: - Private Methods
    
    private func formatLogMessage(
        _ message: String,
        level: String,
        file: String,
        function: String,
        line: Int
    ) -> String {
        let timestamp = dateFormatter.string(from: Date())
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        
        return "[\(timestamp)] [\(level)] [\(category)] [\(fileName):\(line) \(function)] \(message)"
    }
    
    // MARK: - LoggerProtocol Implementation
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formattedMessage = formatLogMessage(message, level: "DEBUG", file: file, function: function, line: line)
        logger.debug("\(message, privacy: .auto)")
        
        if logToFile {
            fileLogger.writeToFile(formattedMessage)
        }
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formattedMessage = formatLogMessage(message, level: "INFO", file: file, function: function, line: line)
        logger.info("\(message, privacy: .auto)")
        
        if logToFile {
            fileLogger.writeToFile(formattedMessage)
        }
    }
    
    func notice(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formattedMessage = formatLogMessage(message, level: "NOTICE", file: file, function: function, line: line)
        logger.notice("\(message, privacy: .auto)")
        
        if logToFile {
            fileLogger.writeToFile(formattedMessage)
        }
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formattedMessage = formatLogMessage(message, level: "WARNING", file: file, function: function, line: line)
        logger.warning("\(message, privacy: .auto)")
        
        if logToFile {
            fileLogger.writeToFile(formattedMessage)
        }
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formattedMessage = formatLogMessage(message, level: "ERROR", file: file, function: function, line: line)
        logger.error("\(message, privacy: .auto)")
        
        if logToFile {
            fileLogger.writeToFile(formattedMessage)
        }
    }
    
    func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formattedMessage = formatLogMessage(message, level: "CRITICAL", file: file, function: function, line: line)
        logger.critical("\(message, privacy: .auto)")
        
        if logToFile {
            fileLogger.writeToFile(formattedMessage)
        }
    }
    
    func fault(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formattedMessage = formatLogMessage(message, level: "FAULT", file: file, function: function, line: line)
        logger.fault("\(message, privacy: .auto)")
        
        if logToFile {
            fileLogger.writeToFile(formattedMessage)
        }
    }
    
    func log(error: Error, file: String = #file, function: String = #function, line: Int = #line) {
//        if let nsError = error as NSError? {
//            error("Error: \(nsError.localizedDescription) (Domain: \(nsError.domain), Code: \(nsError.code))", file: file, function: function, line: line)
//        } else {
//            error("Error: \(error.localizedDescription)", file: file, function: function, line: line)
//        }
        let formattedMessage = formatLogMessage(error.localizedDescription, level: "ERROR", file: file, function: function, line: line)
        logger.fault("\(error.localizedDescription, privacy: .auto)")
        if logToFile {
            fileLogger.writeToFile(formattedMessage)
        }
    }
}
