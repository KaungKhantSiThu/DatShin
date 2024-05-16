//
//  HomeViewController+DataSource.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 10/05/2024.
//

import UIKit

extension HomeViewController {
    // MARK: - Value Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section.ID, Movie.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section.ID, Movie.ID>
    
    func setPostNeedsUpdate(_ id: Movie.ID) {
        var snapshot = self.dataSource.snapshot()
        snapshot.reconfigureItems([id])
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func setInitialData() {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.ID.allCases)
        for sectionType in Section.ID.allCases {
            let movies = self.sectionsStore.fetchByID(sectionType).movies
            snapshot.appendItems(movies, toSection: sectionType)
        }
        
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }

}

