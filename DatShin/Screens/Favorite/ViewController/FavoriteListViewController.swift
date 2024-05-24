//
//  FavoriteListViewController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 14/05/2024.
//

import UIKit
import Nuke
import NukeExtensions
import CoreData

class FavoriteListViewController: DSDataLoadingViewController {
    
    var tableView: UITableView! = nil
    
    var favorites: [WLMovie] = []
    
    let fetcherService: MoviesFetcherService
    
    lazy var coreDataStack = CoreDataStack(modelName: "DatShin")
    
    var spotlightUpdateObserver: NSObjectProtocol?
    
    private lazy var spotlightIndexer: MoviesSpotlightDelegate = {
        return coreDataStack.spotlightIndexer!
    }()

    
    init(fetcherService: MoviesFetcherService) {
        self.fetcherService = fetcherService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
        spotlightIndexing(enabled: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        spotlightIndexing(enabled: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureHierarchy()
    }

}

extension FavoriteListViewController {
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureHierarchy() {
        tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: "FavoriteCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func getFavorites() {
        
        let request = WLMovie.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(WLMovie.savedAt), ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            let results = try coreDataStack.managedContext.fetch(request)
            if results.isEmpty {
                self.presentDSAlertOnMainThread(title: "Watchlist is Empty", message: "Go bookmark something", buttonTitle: "Ok")
            } else {
                self.favorites = results
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } catch let error as NSError {
            self.presentDSAlertOnMainThread(title: "Something went wrong", message: error.localizedDescription, buttonTitle: "Ok")
        }
    }
    
    private func spotlightIndexing(enabled: Bool) {
        if enabled {
            spotlightIndexer.startSpotlightIndexing()
//            startStopIndexingItem.image = UIImage(systemName: "pause")
        } else {
            spotlightIndexer.stopSpotlightIndexing()
//            startStopIndexingItem.image = UIImage(systemName: "play")
        }

        let center = NotificationCenter.default
        if spotlightIndexer.isIndexingEnabled && spotlightUpdateObserver == nil {
            let queue = OperationQueue.main
            spotlightUpdateObserver = center.addObserver(forName: NSCoreDataCoreSpotlightDelegate.indexDidUpdateNotification,
                                                         object: nil,
                                                         queue: queue) { (notification) in
                let userInfo = notification.userInfo
                let storeID = userInfo?[NSStoreUUIDKey] as? String
                let token = userInfo?[NSPersistentHistoryTokenKey] as? NSPersistentHistoryToken
                if let storeID = storeID, let token = token {
                    print("Store with identifier \(storeID) has completed ",
                          "indexing and has processed history token up through \(String(describing: token)).")
                }
            }
        } else {
            if spotlightUpdateObserver == nil {
                return
            }
            center.removeObserver(spotlightUpdateObserver as Any)
        }
    }
    
    func makeRequest(with url: URL, cellSize: CGSize) -> ImageRequest {
        ImageRequest(url: url)
    }

    func makeImageLoadingOptions() -> ImageLoadingOptions {
        ImageLoadingOptions(transition: .fadeIn(duration: 0.25))
    }
}
