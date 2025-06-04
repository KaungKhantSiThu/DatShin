//
//  SearchResultsController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 23/05/2024.
//

import UIKit

class SearchResultsController: UITableViewController {

    typealias DataSource = UITableViewDiffableDataSource<Section, Movie>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Movie>
    
    // MARK: - Properties
    var filteredMovies: [Movie] = []
    var dataSource: DataSource! = nil
    private var isLoading = false
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let emptyStateLabel = UILabel()
    
    enum Section: CaseIterable {
        case movie
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure table view
        tableView.register(SearchCell.self, forCellReuseIdentifier: SearchCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        
        // Configure loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Configure empty state label
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16)
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.text = "No results found"
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        configureDataSource()
    }
    
    func configureDataSource() {
        dataSource = DataSource(tableView: tableView) { (tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.reuseIdentifier, for: indexPath)
            
            if let cell = cell as? SearchCell {
                cell.configure(with: item)
            }
            return cell
        }
        
        var initialSnapshot = Snapshot()
        initialSnapshot.appendSections([.movie])
        dataSource.apply(initialSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Loading State Management
    
    func showLoading() {
        isLoading = true
        emptyStateLabel.isHidden = true
        loadingIndicator.startAnimating()
        
        // Clear previous results while loading
        var snapshot = Snapshot()
        snapshot.appendSections([.movie])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func hideLoading() {
        isLoading = false
        loadingIndicator.stopAnimating()
    }
    
    func update(with movies: [Movie]) {
        filteredMovies = movies
        
        var snapshot = Snapshot()
        snapshot.appendSections([.movie])
        snapshot.appendItems(movies, toSection: .movie)
        dataSource.apply(snapshot, animatingDifferences: true)
        
        // Show empty state if needed
        emptyStateLabel.isHidden = !movies.isEmpty || isLoading
        
        // Scroll to top if we have results
        if !movies.isEmpty && tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Handle movie selection
        if indexPath.row < filteredMovies.count {
            let movie = filteredMovies[indexPath.row]
            // This would typically delegate to a coordinator to show movie details
            // For now, we'll just print the movie title
            print("Selected movie: \(movie.title)")
        }
    }

}
