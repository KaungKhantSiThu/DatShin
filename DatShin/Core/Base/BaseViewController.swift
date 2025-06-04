//
//  BaseViewController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import UIKit

/// Base view controller class that includes logging capabilities
class BaseViewController: UIViewController {
    // MARK: - Properties
    
    /// Logger for this view controller
    let logger: LoggerProtocol
    
    // MARK: - Initialization
    
    /// Initialize with a logger
    /// - Parameter logger: The logger to use (defaults to UI logger)
    init(logger: LoggerProtocol = Log.ui) {
        self.logger = logger
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.logger = Log.ui
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logger.debug("\(type(of: self)) - viewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logger.debug("\(type(of: self)) - viewWillAppear(\(animated))")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logger.debug("\(type(of: self)) - viewDidAppear(\(animated))")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logger.debug("\(type(of: self)) - viewWillDisappear(\(animated))")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logger.debug("\(type(of: self)) - viewDidDisappear(\(animated))")
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        logger.warning("\(type(of: self)) - didReceiveMemoryWarning")
    }
}
