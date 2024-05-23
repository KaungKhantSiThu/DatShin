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
    
    var filteredMovies: [Movie] = []
    var dataSource: DataSource! = nil
    
    enum Section: CaseIterable {
        case movie
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(SearchCell.self, forCellReuseIdentifier: SearchCell.reuseIdentifier)
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
    
    func update(with movies: [Movie]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.movie])
        snapshot.appendItems(movies, toSection: .movie)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

}
