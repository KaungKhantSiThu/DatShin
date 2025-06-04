//
//  LogViewer.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import UIKit

/// A view controller for viewing and sharing logs
final class LogViewerViewController: UIViewController {
    // MARK: - Properties
    
    private let textView = UITextView()
    private let refreshButton = UIBarButtonItem(systemItem: .refresh)
    private let shareButton = UIBarButtonItem(systemItem: .action)
    private let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: nil, action: nil)
    private let fileLogger = FileLogger.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupActions()
        loadLogContents()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Logs"
        view.backgroundColor = .systemBackground
        
        // Configure text view
        textView.isEditable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = .systemBackground
        textView.textColor = .label
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.showsVerticalScrollIndicator = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        // Configure navigation bar buttons
        navigationItem.rightBarButtonItems = [shareButton, refreshButton, clearButton]
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupActions() {
        refreshButton.target = self
        refreshButton.action = #selector(refreshButtonTapped)
        
        shareButton.target = self
        shareButton.action = #selector(shareButtonTapped)
        
        clearButton.target = self
        clearButton.action = #selector(clearButtonTapped)
    }
    
    // MARK: - Actions
    
    @objc private func refreshButtonTapped() {
        logger.debug("Refresh button tapped")
        loadLogContents()
    }
    
    @objc private func shareButtonTapped() {
        logger.debug("Share button tapped")
        shareLogFile()
    }
    
    @objc private func clearButtonTapped() {
        logger.debug("Clear button tapped")
        showClearConfirmation()
    }
    
    // MARK: - Private Methods
    
    private func loadLogContents() {
        logger.debug("Loading log contents")
        
        if let logContents = fileLogger.getLogFileContents() {
            textView.text = logContents
            
            // Scroll to bottom
            if !logContents.isEmpty {
                let bottom = NSRange(location: logContents.count - 1, length: 1)
                textView.scrollRangeToVisible(bottom)
            }
        } else {
            textView.text = "No logs available."
        }
    }
    
    private func shareLogFile() {
        guard let logFileURL = fileLogger.logFileURL else {
            logger.error("No log file URL available")
            showAlert(title: "Error", message: "No log file available to share.")
            return
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: [logFileURL],
            applicationActivities: nil
        )
        
        // Present the activity view controller
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.barButtonItem = shareButton
        }
        
        present(activityViewController, animated: true)
    }
    
    private func showClearConfirmation() {
        let alertController = UIAlertController(
            title: "Clear Logs",
            message: "Are you sure you want to clear the log file? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let clearAction = UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            self?.clearLogFile()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(clearAction)
        
        present(alertController, animated: true)
    }
    
    private func clearLogFile() {
        logger.debug("Clearing log file")
        
        // Close the current log file
        fileLogger.closeLogFile()
        
        // Delete the log file
        if let logFileURL = fileLogger.logFileURL {
            do {
                try FileManager.default.removeItem(at: logFileURL)
                logger.info("Log file cleared successfully")
                
                // Setup a new log file
                fileLogger.setupLogFile()
                
                // Reload the log contents
                loadLogContents()
            } catch {
                logger.error("Failed to clear log file: \(error.localizedDescription)")
                showAlert(title: "Error", message: "Failed to clear log file: \(error.localizedDescription)")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
}

// MARK: - Factory Extension

extension ViewControllerFactory {
    /// Creates a log viewer view controller
    func makeLogViewerViewController() -> UIViewController {
        logger.debug("Creating LogViewerViewController")
        let logViewerVC = LogViewerViewController()
        return logViewerVC
    }
}
