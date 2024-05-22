//
//  SearchViewController+DataSource.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 20/05/2024.
//

import UIKit

extension SearchViewController: UITableViewDelegate {
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Movie>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Movie>
    
    enum Section: CaseIterable {
        case movie
    }
}
