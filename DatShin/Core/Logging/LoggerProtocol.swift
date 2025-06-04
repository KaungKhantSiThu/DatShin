//
//  LoggerProtocol.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import Foundation
import OSLog

/// Protocol defining the interface for a logger
protocol LoggerProtocol {
    /// Log a debug message
    func debug(_ message: String, file: String, function: String, line: Int)
    
    /// Log an info message
    func info(_ message: String, file: String, function: String, line: Int)
    
    /// Log a notice message
    func notice(_ message: String, file: String, function: String, line: Int)
    
    /// Log a warning message
    func warning(_ message: String, file: String, function: String, line: Int)
    
    /// Log an error message
    func error(_ message: String, file: String, function: String, line: Int)
    
    /// Log a critical message
    func critical(_ message: String, file: String, function: String, line: Int)
    
    /// Log a fault message
    func fault(_ message: String, file: String, function: String, line: Int)
    
    /// Log an error object
    func log(error: Error, file: String, function: String, line: Int)
}

// Default implementations for convenience
extension LoggerProtocol {
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        // Implementation provided by concrete types
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        // Implementation provided by concrete types
    }
    
    func notice(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        // Implementation provided by concrete types
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        // Implementation provided by concrete types
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        // Implementation provided by concrete types
    }
    
    func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        // Implementation provided by concrete types
    }
    
    func fault(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        // Implementation provided by concrete types
    }
    
    func log(error: Error, file: String = #file, function: String = #function, line: Int = #line) {
//        if let nsError = error as NSError? {
//            error("Error: \(nsError.localizedDescription) (Domain: \(nsError.domain), Code: \(nsError.code))", file: file, function: function, line: line)
//        } else {
//            error("Error: \(error.localizedDescription)", file: file, function: function, line: line)
//        }
    }
}
