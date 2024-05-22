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
//    var dataSource: DataSource! = nil
//    var currentSnapshot: Snapshot! = nil
    
    var favorites: [WLMovie] = []
    
    let fetcherService: MoviesFetcherService
    
    lazy var coreDataStack = CoreDataStack(modelName: "DatShin")
    
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
//        Task {
//            do {
//                try await store.loadData()
//                self.favorites = store.movies
//                if favorites.isEmpty {
//                    let v = UIView()
//                    v.backgroundColor = .systemGray
//                    v.frame = self.view.frame
//                    self.view.addSubview(v)
//                } else {
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                        self.view.bringSubviewToFront(self.tableView)
//                    }
//                    
//                }
//            } catch {
//                self.presentDSAlertOnMainThread(title: "Something went wrong", message: error.localizedDescription, buttonTitle: "Ok")
//            }
//        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureHierarchy()
//        configureDataSource()
        // Do any additional setup after loading the view.
        
//        applySnapshot()
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
        tableView.rowHeight = 100
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
    
//    func configureDataSource() {
//        
//        dataSource = DataSource(tableView: tableView) {
//            (tableView: UITableView, indexPath: IndexPath, movie: FavoriteMovie) -> UITableViewCell? in
//            // Return the cell.
//            let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCell
//            ImageLoader.shared.downloadImage(from: movie.posterPath, as: .poster) { image in
//                DispatchQueue.main.async {
//                    cell.posterImageView.image = image
//                }
//            }
//            cell.titleLabel.text = movie.title
//            print(cell)
//            return cell
//        }
//    }
    
    func getFavorites() {
//        PersistenceManager.retrieveFavorites { [weak self] result in
//            guard let self = self else { return }
//            
//            switch result {
//                
//            case .success(let favorites):
//                if favorites.isEmpty {
//                    let v = UIView()
//                    v.backgroundColor = .systemGray
//                    v.frame = self.view.frame
//                    self.view.addSubview(v)
//                } else {
//                    self.favorites = favorites
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                        self.view.bringSubviewToFront(self.tableView)
//                    }
//                }
//                
//            case .failure(let error):
//                self.presentDSAlertOnMainThread(title: "Something went wrong", message: error.localizedDescription, buttonTitle: "Ok")
//            }
//        }
        
        let moviesFetch: NSFetchRequest = WLMovie.fetchRequest()
        
        do {
            let results = try coreDataStack.managedContext.fetch(moviesFetch)
            if results.isEmpty {
                self.presentDSAlertOnMainThread(title: "Watchlist is Empty", message: "Go bookmark something", buttonTitle: "Ok")
            } else {
                self.favorites = results
//                    .map {
//                    return Movie(id: Int($0.id), title: $0.title ?? "", posterPath: $0.posterPath)
//                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } catch let error as NSError {
            self.presentDSAlertOnMainThread(title: "Something went wrong", message: error.localizedDescription, buttonTitle: "Ok")
        }
    }
    
//    func applySnapshot() {
//        currentSnapshot = Snapshot()
//        currentSnapshot.appendSections(Category.allCases)
//        currentSnapshot.appendItems(favorites, toSection: .bookmark)
//        dataSource.apply(currentSnapshot, animatingDifferences: true)
//    }
    
    func makeRequest(with url: URL, cellSize: CGSize) -> ImageRequest {
        ImageRequest(url: url)
    }

    func makeImageLoadingOptions() -> ImageLoadingOptions {
        ImageLoadingOptions(transition: .fadeIn(duration: 0.25))
    }
}
