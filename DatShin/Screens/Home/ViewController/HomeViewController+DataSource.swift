//
//  HomeViewController+DataSource.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 10/05/2024.
//

import UIKit

extension HomeViewController {
    // MARK: - Value Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section.ID, MovieWrapper>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section.ID, MovieWrapper>
    
    func setMovieNeedsUpdate(_ movie: MovieWrapper) {
        var snapshot = self.dataSource.snapshot()
        snapshot.reconfigureItems([movie])
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func setInitialData() {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.ID.allCases)
        for sectionID in Section.ID.allCases {
            let movies = self.sectionsStore.fetchByID(sectionID).movies
            let movieWrapper = movies.map { MovieWrapper(movieID: $0, sectionID: sectionID)}
            snapshot.appendItems(movieWrapper, toSection: sectionID)
        }
        
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }

}

