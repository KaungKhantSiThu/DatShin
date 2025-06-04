//
//  FileLogger.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import Foundation

/// A utility class for managing log files
final class FileLogger {
    // MARK: - Properties
    
    /// Shared instance of the file logger
    static let shared = FileLogger()
    
    /// The URL of the log file
    private(set) var logFileURL: URL?
    
    /// The file handle for writing to the log file
    private var fileHandle: FileHandle?
    
    /// Date formatter for log file names
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // MARK: - Initialization
    
    private init() {
        setupLogFile()
    }
    
    // MARK: - Setup
    
    /// Sets up the log file
    func setupLogFile() {
        let fileManager = FileManager.default
        
        // Get the documents directory
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not access documents directory")
            return
        }
        
        // Create a logs directory if it doesn't exist
        let logsDirectory = documentsDirectory.appendingPathComponent("Logs")
        
        if !fileManager.fileExists(atPath: logsDirectory.path) {
            do {
                try fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
            } catch {
                print("Error creating logs directory: \(error.localizedDescription)")
                return
            }
        }
        
        // Create a log file with the current date
        let dateString = dateFormatter.string(from: Date())
        let logFileName = "DatShin_\(dateString).log"
        logFileURL = logsDirectory.appendingPathComponent(logFileName)
        
        guard let logFileURL = logFileURL else { return }
        
        // Create the log file if it doesn't exist
        if !fileManager.fileExists(atPath: logFileURL.path) {
            fileManager.createFile(atPath: logFileURL.path, contents: nil)
        }
        
        // Open the file handle
        do {
            fileHandle = try FileHandle(forWritingTo: logFileURL)
            fileHandle?.seekToEndOfFile()
            
            // Write a header to the log file
            let header = "=== DatShin Log Session Started at \(Date()) ===\n\n"
            writeToFile(header)
        } catch {
            print("Error opening log file: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Public Methods
    
    /// Writes a message to the log file
    /// - Parameter message: The message to write
    func writeToFile(_ message: String) {
        guard let fileHandle = fileHandle else { return }
        
        if let data = (message + "\n").data(using: .utf8) {
            fileHandle.write(data)
        }
    }
    
    /// Closes the log file
    func closeLogFile() {
        guard let fileHandle = fileHandle else { return }
        
        let footer = "\n=== DatShin Log Session Ended at \(Date()) ===\n"
        writeToFile(footer)
        
        fileHandle.closeFile()
        self.fileHandle = nil
    }
    
    /// Returns the contents of the log file
    /// - Returns: The contents of the log file as a string
    func getLogFileContents() -> String? {
        guard let logFileURL = logFileURL else { return nil }
        
        do {
            return try String(contentsOf: logFileURL, encoding: .utf8)
        } catch {
            print("Error reading log file: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Returns the list of available log files
    /// - Returns: An array of log file URLs
    func getAvailableLogFiles() -> [URL] {
        let fileManager = FileManager.default
        
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }
        
        let logsDirectory = documentsDirectory.appendingPathComponent("Logs")
        
        do {
            let logFiles = try fileManager.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: nil)
            return logFiles.filter { $0.pathExtension == "log" }
        } catch {
            print("Error getting log files: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Deletes old log files
    /// - Parameter days: The number of days to keep log files for
    func deleteOldLogFiles(olderThan days: Int) {
        let fileManager = FileManager.default
        let logFiles = getAvailableLogFiles()
        
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date())!
        
        for logFile in logFiles {
            do {
                let attributes = try fileManager.attributesOfItem(atPath: logFile.path)
                if let creationDate = attributes[.creationDate] as? Date {
                    if creationDate < cutoffDate {
                        try fileManager.removeItem(at: logFile)
                    }
                }
            } catch {
                print("Error deleting old log file: \(error.localizedDescription)")
            }
        }
    }
}
