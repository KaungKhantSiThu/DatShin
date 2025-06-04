//
//  Logger.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import Foundation
import OSLog

/// Concrete implementation of LoggerProtocol using Apple's unified logging system
final class Logger: LoggerProtocol {
    // MARK: - Properties
    
    /// The native logger instance
    private let logger: os.Logger
    
    /// Whether to log to file
    private let logToFile: Bool
    
    /// The file URL to write logs to
    private let fileURL: URL?
    
    /// File handle for writing to log file
    private var fileHandle: FileHandle?
    
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
    ///   - fileURL: The file URL to write logs to (if nil and logToFile is true, a default location will be used)
    ///   - privacy: The privacy level for logging
    init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "com.datshin",
        category: String = "default",
        logToFile: Bool = false,
        fileURL: URL? = nil,
        privacy: OSLogPrivacy = .auto
    ) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
        self.logToFile = logToFile
        self.privacy = privacy
        
        if logToFile {
            if let providedURL = fileURL {
                self.fileURL = providedURL
            } else {
                // Create a default log file in the Documents directory
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                self.fileURL = documentsDirectory.appendingPathComponent("DatShin.log")
            }
            
            setupLogFile()
        } else {
            self.fileURL = nil
        }
    }
    
    deinit {
        fileHandle?.closeFile()
    }
    
    // MARK: - Private Methods
    
    private func setupLogFile() {
        guard let fileURL = fileURL else { return }
        
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: fileURL.path) {
            fileManager.createFile(atPath: fileURL.path, contents: nil)
        }
        
        do {
            fileHandle = try FileHandle(forWritingTo: fileURL)
            fileHandle?.seekToEndOfFile()
        } catch {
            print("Error opening log file: \(error.localizedDescription)")
        }
    }
    
    private func formatLogMessage(
        _ message: String,
        level: String,
        file: String,
        function: String,
        line: Int
    ) -> String {
        let timestamp = dateFormatter.string(from: Date())
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        
        return "[\(timestamp)] [\(level)] [\(fileName):\(line) \(function)] \(message)"
    }
    
    private func writeToFile(_ formattedMessage: String) {
        guard logToFile, let fileHandle = fileHandle else { return }
        
        if let data = (formattedMessage + "\n").data(using: .utf8) {
            fileHandle.write(data)
        }
    }
    
    // MARK: - LoggerProtocol Implementation
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formattedMessage = formatLogMessage(message, level: "DEBUG", file: file, function: function, line: line)
        logger.debug("\(message, privacy: .auto)")
        writeToFile(formattedMessage)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formattedMessage = formatLogMessage(message, level: "INFO", file: file, function: function, line: line)
        logger.info("\(message, privacy: .auto)")
        writeToFile(formattedMessage)
    }
    
    func notice(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formattedMessage = formatLogMessage(message, level: "NOTICE", file: file, function: function, line: line)
        logger.notice("\(message, privacy: .auto)")
        writeToFile(formattedMessage)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formattedMessage = formatLogMessage(message, level: "WARNING", file: file, function: function, line: line)
        logger.warning("\(message, privacy: .auto)")
        writeToFile(formattedMessage)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formattedMessage = formatLogMessage(message, level: "ERROR", file: file, function: function, line: line)
        logger.error("\(message, privacy: .auto)")
        writeToFile(formattedMessage)
    }
    
    func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formattedMessage = formatLogMessage(message, level: "CRITICAL", file: file, function: function, line: line)
        logger.critical("\(message, privacy: .auto)")
        writeToFile(formattedMessage)
    }
    
    func fault(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formattedMessage = formatLogMessage(message, level: "FAULT", file: file, function: function, line: line)
        logger.fault("\(message, privacy: .auto)")
        writeToFile(formattedMessage)
    }
    
    func log(error: Error, file: String = #file, function: String = #function, line: Int = #line) {
//        if let nsError = error as NSError? {
//            error("Error: \(nsError.localizedDescription) (Domain: \(nsError.domain), Code: \(nsError.code))", file: file, function: function, line: line)
//        } else {
//            error("Error: \(error.localizedDescription)", file: file, function: function, line: line)
//        }
        
        let formattedMessage = formatLogMessage(error.localizedDescription, level: "ERROR", file: file, function: function, line: line)
        logger.fault("\(error.localizedDescription, privacy: .auto)")
        writeToFile(formattedMessage)
    }
}
