//
//  SearchViewController+Layout.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 04/06/2024.
//

import UIKit

extension SearchViewController {
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureHierarchy() {
        // Configure search controller
        // Search results are displayed in the main SearchViewController's collection view,
        // so searchResultsController is nil.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self // Conformance in SearchViewController+UISearchResultsUpdating.swift
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.placeholder = "Search movies, TV shows, people..."
        // searchController.obscuresBackgroundDuringPresentation = true // Set to false if results are in main VC
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false // Keep search bar visible
        definesPresentationContext = true
        
        // Configure collection view
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    
    func configureCollectionView() {
        collectionView.delegate = self // Conformance in SearchViewController+UICollectionViewDelegate.swift
        // Register cell types
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        collectionView.register(GenreCell.self, forCellWithReuseIdentifier: GenreCell.reuseIdentifier)
        collectionView.register(EmptyStateCell.self, forCellWithReuseIdentifier: EmptyStateCell.reuseIdentifier)
        collectionView.register(SkeletonCell.self, forCellWithReuseIdentifier: SkeletonCell.reuseIdentifier)

        // Register supplementary views (headers)
        collectionView.register(
            HeaderSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderSupplementaryView.reuseIdentifier
        )
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self, let sectionKind = SectionLayoutKind(rawValue: sectionIndex) else { return nil }

            if (!self.viewModel.currentSearchQuery.isEmpty && sectionKind != .searchResults) ||
               (self.viewModel.currentSearchQuery.isEmpty && sectionKind == .searchResults) {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0.1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0.1))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                section.interGroupSpacing = 0
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0.1))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [sectionHeader]
                return section
            }

            switch sectionKind {
            case .trendingMovies, .popularMovies, .topRatedMovies, .nowPlayingMovies, .upcomingMovies:
                return self.createMovieSectionLayout(layoutEnvironment: layoutEnvironment)
            case .genres:
                return self.createGenreSectionLayout(layoutEnvironment: layoutEnvironment)
            case .searchResults:
                return self.createSearchResultsSectionLayout(layoutEnvironment: layoutEnvironment)
            }
        }
        return layout
    }

    private func createMovieSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupWidth: CGFloat
        let containerWidth = layoutEnvironment.container.effectiveContentSize.width
        if containerWidth > 500 { 
            groupWidth = 0.25
        } else {
            groupWidth = 0.4
        }
        
        let groupHeight = NSCollectionLayoutDimension.absolute(240)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(groupWidth),
            heightDimension: groupHeight
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }

    private func createGenreSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0)

        let groupWidthFraction: CGFloat = layoutEnvironment.container.effectiveContentSize.width > 500 ? 0.33 : 0.5
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(groupWidthFraction),
            heightDimension: .absolute(60)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: groupWidthFraction == 0.5 ? 2 : 3)
        group.interItemSpacing = .fixed(10)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    private func createSearchResultsSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let columns = layoutEnvironment.traitCollection.horizontalSizeClass == .compact ? 2 : 3
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupHeight = NSCollectionLayoutDimension.absolute(280)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: groupHeight
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
        group.interItemSpacing = .fixed(0)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        section.interGroupSpacing = 0

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
}
