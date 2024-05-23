//
//  SearchViewController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 19/05/2024.
//

import UIKit

class SearchViewController: DSDataLoadingViewController {
        
    var tableView: UITableView! = nil
    var dataSource: DataSource! = nil

//    var collectionViewDataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
//    var collectionView: UICollectionView! = nil
    
    lazy var searchController = UISearchController()
    
    let service: SearchService
    
    var movies: [Movie] = []
    
    private var loadingTask: Task<Void, Never>?
    
    init(service: SearchService) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        configureViewController()
        configureHierarchy()
        setUpDataSource()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadingTask?.cancel()
    }
    
}

extension SearchViewController {
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureHierarchy() {
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.placeholder = "Movies"
        searchController.searchResultsUpdater = self
        
        navigationItem.searchController = searchController
        
        tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
//        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.register(SearchCell.self, forCellReuseIdentifier: SearchCell.reuseIdentifier)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setUpDataSource() {
        dataSource = DataSource(tableView: tableView) { (tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.reuseIdentifier, for: indexPath)
            
            if let cell = cell as? SearchCell {
                cell.configure(with: item)
            }
            return cell
        }
    }
    
    func updateDataSource() {
        guard let dataSource = tableView.dataSource as? DataSource else { return }
        
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(movies, toSection: .movie)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        loadingTask?.cancel()
        loadingTask = Task {
            // Simulate network delay
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Check for cancellation
            guard !Task.isCancelled else { return }
            
            do {
                print("Fetching Search Results (Movie)")
                movies = try await service.fetchMovies(query: text)
                updateDataSource()
            } catch {
                presentDSAlertOnMainThread(title: "Search failed", message: error.localizedDescription, buttonTitle: "Ok")
            }
        }
    }
}
