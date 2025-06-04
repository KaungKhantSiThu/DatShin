//
//  DebugMenuViewController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import UIKit

/// A view controller for displaying debug options
final class DebugMenuViewController: UIViewController {
    // MARK: - Properties
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: nil)
    
    private weak var appCoordinator: AppCoordinator?
    
    /// Debug menu sections
    private enum Section: Int, CaseIterable {
        case logging
        case network
        case ui
        case app
        
        var title: String {
            switch self {
            case .logging: return "Logging"
            case .network: return "Network"
            case .ui: return "UI"
            case .app: return "App"
            }
        }
    }
    
    /// Debug menu items
    private enum MenuItem: String {
        // Logging section
        case viewLogs = "View Logs"
        case toggleFileLogging = "Toggle File Logging"
        case clearLogs = "Clear Logs"
        
        // Network section
        case networkInfo = "Network Info"
        case mockResponses = "Mock Responses"
        
        // UI section
        case uiInspector = "UI Inspector"
        case slowAnimations = "Slow Animations"
        
        // App section
        case appInfo = "App Info"
        case resetApp = "Reset App"
        
        var image: UIImage? {
            switch self {
            case .viewLogs: return UIImage(systemName: "doc.text.magnifyingglass")
            case .toggleFileLogging: return UIImage(systemName: "arrow.triangle.2.circlepath")
            case .clearLogs: return UIImage(systemName: "trash")
            case .networkInfo: return UIImage(systemName: "network")
            case .mockResponses: return UIImage(systemName: "arrow.left.arrow.right")
            case .uiInspector: return UIImage(systemName: "rectangle.3.group")
            case .slowAnimations: return UIImage(systemName: "tortoise")
            case .appInfo: return UIImage(systemName: "info.circle")
            case .resetApp: return UIImage(systemName: "arrow.counterclockwise")
            }
        }
    }
    
    /// Menu items organized by section
    private let menuItems: [[MenuItem]] = [
        [.viewLogs, .toggleFileLogging, .clearLogs],
        [.networkInfo, .mockResponses],
        [.uiInspector, .slowAnimations],
        [.appInfo, .resetApp]
    ]
    
    // MARK: - Initialization
    
    init(appCoordinator: AppCoordinator, logger: LoggerProtocol = Log.ui) {
        self.appCoordinator = appCoordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupActions()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Debug Menu"
        view.backgroundColor = .systemBackground
        
        // Configure navigation bar
        navigationItem.rightBarButtonItem = closeButton
        
        // Configure table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DebugCell")
    }
    
    private func setupActions() {
        closeButton.target = self
        closeButton.action = #selector(closeButtonTapped)
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        logger.debug("Close button tapped")
        dismiss(animated: true)
    }
    
    // MARK: - Menu Actions
    
    private func handleMenuItemSelection(_ menuItem: MenuItem) {
        logger.debug("Selected menu item: \(menuItem.rawValue)")
        
        switch menuItem {
        case .viewLogs:
            appCoordinator?.showLoggingCoordinator()
            
        case .toggleFileLogging:
            // Toggle file logging
            let isEnabled = UserDefaults.standard.bool(forKey: "FileLoggingEnabled")
            UserDefaults.standard.set(!isEnabled, forKey: "FileLoggingEnabled")
            logger.info("File logging \(!isEnabled ? "enabled" : "disabled")")
            tableView.reloadData()
            
        case .clearLogs:
            showClearLogsConfirmation()
            
        case .networkInfo:
            logger.debug("Network info not implemented yet")
            showNotImplementedAlert()
            
        case .mockResponses:
            logger.debug("Mock responses not implemented yet")
            showNotImplementedAlert()
            
        case .uiInspector:
            logger.debug("UI inspector not implemented yet")
            showNotImplementedAlert()
            
        case .slowAnimations:
            toggleSlowAnimations()
            
        case .appInfo:
            showAppInfo()
            
        case .resetApp:
            showResetAppConfirmation()
        }
    }
    
    // MARK: - Helper Methods
    
    private func showClearLogsConfirmation() {
        let alert = UIAlertController(
            title: "Clear Logs",
            message: "Are you sure you want to clear all logs? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            self?.clearLogs()
        })
        
        present(alert, animated: true)
    }
    
    private func clearLogs() {
        logger.debug("Clearing logs")
        
        // Clear logs using FileLogger
        FileLogger.shared.closeLogFile()
        
        if let logFileURL = FileLogger.shared.logFileURL {
            do {
                try FileManager.default.removeItem(at: logFileURL)
                logger.info("Logs cleared successfully")
                
                // Setup a new log file
                FileLogger.shared.setupLogFile()
                
                showSuccessAlert(message: "Logs cleared successfully")
            } catch {
                logger.error("Failed to clear logs: \(error.localizedDescription)")
                showErrorAlert(message: "Failed to clear logs: \(error.localizedDescription)")
            }
        }
    }
    
    private func toggleSlowAnimations() {
        let currentValue = UIApplication.shared.windows.first?.layer.speed ?? 1.0
        let newValue = currentValue == 1.0 ? 0.3 : 1.0
        
        UIApplication.shared.windows.forEach { window in
            window.layer.speed = Float(newValue)
        }
        
        logger.debug("Animations speed set to: \(newValue)")
        tableView.reloadData()
    }
    
    private func showAppInfo() {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            return
        }
        
        let message = """
        App Version: \(appVersion) (\(buildNumber))
        Device: \(UIDevice.current.model)
        OS Version: \(UIDevice.current.systemVersion)
        Screen: \(UIScreen.main.bounds.size.width) x \(UIScreen.main.bounds.size.height)
        """
        
        let alert = UIAlertController(
            title: "App Info",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Copy", style: .default) { _ in
            UIPasteboard.general.string = message
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
    
    private func showResetAppConfirmation() {
        let alert = UIAlertController(
            title: "Reset App",
            message: "Are you sure you want to reset the app? This will clear all data and restart the app.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.resetApp()
        })
        
        present(alert, animated: true)
    }
    
    private func resetApp() {
        logger.warning("Resetting app")
        
        // Clear UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
        
        // Clear document directory
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
                for fileURL in contents {
                    try FileManager.default.removeItem(at: fileURL)
                }
                logger.info("Document directory cleared")
            } catch {
                logger.error("Failed to clear document directory: \(error.localizedDescription)")
            }
        }
        
        // Restart app (simulate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
    
    private func showNotImplementedAlert() {
        let alert = UIAlertController(
            title: "Not Implemented",
            message: "This feature is not implemented yet.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(
            title: "Success",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension DebugMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        return menuItems[section.rawValue].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DebugCell", for: indexPath)
        
        guard let section = Section(rawValue: indexPath.section),
              indexPath.row < menuItems[section.rawValue].count else {
            return cell
        }
        
        let menuItem = menuItems[section.rawValue][indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = menuItem.rawValue
        content.image = menuItem.image
        
        // Add checkmark for toggle options
        if menuItem == .toggleFileLogging {
            let isEnabled = UserDefaults.standard.bool(forKey: "FileLoggingEnabled")
            cell.accessoryType = isEnabled ? .checkmark : .none
        } else if menuItem == .slowAnimations {
            let isSlowed = UIApplication.shared.windows.first?.layer.speed ?? 1.0 < 1.0
            cell.accessoryType = isSlowed ? .checkmark : .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return nil }
        return section.title
    }
}

// MARK: - UITableViewDelegate

extension DebugMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = Section(rawValue: indexPath.section),
              indexPath.row < menuItems[section.rawValue].count else {
            return
        }
        
        let menuItem = menuItems[section.rawValue][indexPath.row]
        handleMenuItemSelection(menuItem)
    }
}

// MARK: - Factory Extension

extension ViewControllerFactory {
    /// Creates a debug menu view controller
    func makeDebugMenuViewController() -> UIViewController {
        logger.debug("Creating DebugMenuViewController")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let appCoordinator = appDelegate.appCoordinator else {
            fatalError("AppCoordinator not found")
        }
        
        let debugMenuVC = DebugMenuViewController(appCoordinator: appCoordinator)
        return debugMenuVC
    }
}
