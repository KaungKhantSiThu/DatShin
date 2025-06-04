//
//  LoggerFactory.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import Foundation
import OSLog

/// Factory for creating loggers
final class LoggerFactory {
    // MARK: - Shared Instance
    
    /// Shared instance of the logger factory
    static let shared = LoggerFactory()
    
    // MARK: - Properties
    
    /// The default logger
    private(set) lazy var defaultLogger: LoggerProtocol = makeDefaultLogger()
    
    /// Network logger for API requests and responses
    private(set) lazy var networkLogger: LoggerProtocol = makeNetworkLogger()
    
    /// UI logger for view controllers and UI events
    private(set) lazy var uiLogger: LoggerProtocol = makeUILogger()
    
    /// Data logger for data operations and persistence
    private(set) lazy var dataLogger: LoggerProtocol = makeDataLogger()
    
    /// Coordinator logger for navigation and flow
    private(set) lazy var coordinatorLogger: LoggerProtocol = makeCoordinatorLogger()
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Factory Methods
    
    /// Whether to use file-based logging
    private let useFileBasedLogging = false
    
    /// Creates a default logger
    func makeDefaultLogger() -> LoggerProtocol {
        if useFileBasedLogging {
            return FileBasedLogger(
                category: "Default",
                logToFile: true,
                privacy: .public
            )
        } else {
            return Logger(
                category: "Default",
                logToFile: true,
                privacy: .public
            )
        }
    }
    
    /// Creates a network logger for API requests and responses
    func makeNetworkLogger() -> LoggerProtocol {
        if useFileBasedLogging {
            return FileBasedLogger(
                category: "Network",
                logToFile: true,
                privacy: .private // Network data is often sensitive
            )
        } else {
            return Logger(
                category: "Network",
                logToFile: true,
                privacy: .private
            )
        }
    }
    
    /// Creates a UI logger for view controllers and UI events
    func makeUILogger() -> LoggerProtocol {
        if useFileBasedLogging {
            return FileBasedLogger(
                category: "UI",
                logToFile: true,
                privacy: .public
            )
        } else {
            return Logger(
                category: "UI",
                logToFile: true,
                privacy: .public
            )
        }
    }
    
    /// Creates a data logger for data operations and persistence
    func makeDataLogger() -> LoggerProtocol {
        if useFileBasedLogging {
            return FileBasedLogger(
                category: "Data",
                logToFile: true,
                privacy: .private // Data operations may contain sensitive information
            )
        } else {
            return Logger(
                category: "Data",
                logToFile: true,
                privacy: .private
            )
        }
    }
    
    /// Creates a coordinator logger for navigation and flow
    func makeCoordinatorLogger() -> LoggerProtocol {
        if useFileBasedLogging {
            return FileBasedLogger(
                category: "Coordinator",
                logToFile: true,
                privacy: .public
            )
        } else {
            return Logger(
                category: "Coordinator",
                logToFile: true,
                privacy: .public
            )
        }
    }
    
    /// Creates a custom logger with the specified parameters
    func makeCustomLogger(
        category: String,
        logToFile: Bool = true,
        fileURL: URL? = nil,
        privacy: OSLogPrivacy = .public
    ) -> LoggerProtocol {
        if useFileBasedLogging {
            return FileBasedLogger(
                category: category,
                logToFile: logToFile,
                privacy: .auto
            )
        } else {
            return Logger(
                category: category,
                logToFile: logToFile,
                fileURL: fileURL,
                privacy: .auto
            )
        }
    }
}
