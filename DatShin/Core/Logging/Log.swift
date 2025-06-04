//
//  Log.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import Foundation
import OSLog

/// Global logging utility for easy access to loggers throughout the app
enum Log {
    /// Default logger for general use
    static var `default`: LoggerProtocol {
        return LoggerFactory.shared.defaultLogger
    }
    
    /// Network logger for API requests and responses
    static var network: LoggerProtocol {
        return LoggerFactory.shared.networkLogger
    }
    
    /// UI logger for view controllers and UI events
    static var ui: LoggerProtocol {
        return LoggerFactory.shared.uiLogger
    }
    
    /// Data logger for data operations and persistence
    static var data: LoggerProtocol {
        return LoggerFactory.shared.dataLogger
    }
    
    /// Coordinator logger for navigation and flow
    static var coordinator: LoggerProtocol {
        return LoggerFactory.shared.coordinatorLogger
    }
    
    /// Creates a custom logger with the specified parameters
    static func custom(
        category: String,
        logToFile: Bool = true,
        fileURL: URL? = nil,
        privacy: OSLogPrivacy = .public
    ) -> LoggerProtocol {
        return LoggerFactory.shared.makeCustomLogger(
            category: category,
            logToFile: logToFile,
            fileURL: fileURL,
            privacy: .auto
        )
    }
}
