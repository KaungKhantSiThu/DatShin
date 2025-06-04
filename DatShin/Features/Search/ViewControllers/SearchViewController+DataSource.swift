//
//  SearchViewController+DataSource.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 20/05/2024.
//

import UIKit

extension SearchViewController {
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, AnyHashable>(
            collectionView: collectionView
        ) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let self = self, let sectionKind = SectionLayoutKind(rawValue: indexPath.section) else {
                // This should ideally not happen with a valid snapshot.
                // Register a fallback cell or log an error.
                print("ERROR: Could not determine section kind or self was nil in dataSource closure. IndexPath: \(indexPath), Item: \(item)")
                // Attempt to dequeue an EmptyStateCell as a fallback.
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyStateCell.reuseIdentifier, for: indexPath) as! EmptyStateCell
                cell.setMessage("Error displaying content.")
                return cell
            }

            let isLoadingSection:
            Bool
            switch sectionKind {
            case .trendingMovies:    isLoadingSection = self.viewModel.isLoadingTrending && self.viewModel.trendingMovies.isEmpty
            case .popularMovies:     isLoadingSection = self.viewModel.isLoadingPopular && self.viewModel.popularMovies.isEmpty
            case .topRatedMovies:    isLoadingSection = self.viewModel.isLoadingTopRated && self.viewModel.topRatedMovies.isEmpty
            case .nowPlayingMovies:  isLoadingSection = self.viewModel.isLoadingNowPlaying && self.viewModel.nowPlayingMovies.isEmpty
            case .upcomingMovies:    isLoadingSection = self.viewModel.isLoadingUpcoming && self.viewModel.upcomingMovies.isEmpty
            case .genres:            isLoadingSection = self.viewModel.isLoadingGenres && self.viewModel.movieGenres.isEmpty
            case .searchResults:     isLoadingSection = self.viewModel.isLoadingSearchResults && self.viewModel.searchResults.isEmpty
            }

            if isLoadingSection {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SkeletonCell.reuseIdentifier, for: indexPath) as! SkeletonCell
                return cell
            }
            
            if let movieItem = item as? MovieListItem {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
                cell.configure(with: movieItem)
                return cell
            } else if let genreItem = item as? Genre {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCell.reuseIdentifier, for: indexPath) as! GenreCell
                cell.configure(with: genreItem)
                return cell
            } else if item is PlaceholderItem {
                 let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SkeletonCell.reuseIdentifier, for: indexPath) as! SkeletonCell
                 return cell
            }
            
            print("Warning: Unhandled item type in dataSource: \(type(of: item)) at indexPath: \(indexPath)")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyStateCell.reuseIdentifier, for: indexPath) as! EmptyStateCell
            cell.setMessage("No content available for this item.")
            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard let self = self, kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HeaderSupplementaryView.reuseIdentifier,
                for: indexPath) as! HeaderSupplementaryView
            
            if let sectionKind = SectionLayoutKind(rawValue: indexPath.section) {
                if (!self.viewModel.currentSearchQuery.isEmpty && sectionKind != .searchResults) ||
                   (self.viewModel.currentSearchQuery.isEmpty && sectionKind == .searchResults) {
                    header.isHidden = true
                    header.titleLabel.text = nil
                } else {
                    header.isHidden = false
                    header.titleLabel.text = sectionKind.title
                    // TODO: Implement 'See All' button logic if applicable for the section
                }
            }
            return header
        }
        // Register a generic cell for fallback in the cell provider closure to prevent crashes.
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
    }

    func applyAllSectionsSnapshot(animatingDifferences: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, AnyHashable>()
        snapshot.appendSections(SectionLayoutKind.allCases)
        SectionLayoutKind.allCases.forEach { sectionKind in
            applyItems(for: sectionKind, to: &snapshot, isFullSnapshot: true)
        }
        if dataSource != nil {
            dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        } else {
            print("ERROR: DataSource is nil when trying to applyAllSectionsSnapshot")
        }
    }

    // Helper to apply items for a specific section to a snapshot
    // Added isFullSnapshot flag to differentiate behavior if needed, though current logic is similar.
    internal func applyItems(for sectionKind: SectionLayoutKind, to snapshot: inout NSDiffableDataSourceSnapshot<SectionLayoutKind, AnyHashable>, isFullSnapshot: Bool = false) {
        let placeholders = (0..<skeletonCellCount).map { _ in PlaceholderItem() }
        var itemsToAdd: [AnyHashable] = []

        let isLoading: Bool
        let currentData: [AnyHashable]

        switch sectionKind {
        case .trendingMovies:    isLoading = viewModel.isLoadingTrending; currentData = viewModel.trendingMovies
        case .popularMovies:     isLoading = viewModel.isLoadingPopular;  currentData = viewModel.popularMovies
        case .topRatedMovies:    isLoading = viewModel.isLoadingTopRated; currentData = viewModel.topRatedMovies
        case .nowPlayingMovies:  isLoading = viewModel.isLoadingNowPlaying; currentData = viewModel.nowPlayingMovies
        case .upcomingMovies:    isLoading = viewModel.isLoadingUpcoming; currentData = viewModel.upcomingMovies
        case .genres:            isLoading = viewModel.isLoadingGenres;     currentData = viewModel.movieGenres
        case .searchResults:     isLoading = viewModel.isLoadingSearchResults; currentData = viewModel.searchResults
        }

        if isLoading && currentData.isEmpty {
            itemsToAdd = placeholders
        } else if !currentData.isEmpty {
            itemsToAdd = currentData
        } else {
            // Not loading and no data. Section will be empty unless an EmptyStateItem is desired.
            // itemsToAdd remains empty.
        }
        
        let isSearchActive = !viewModel.currentSearchQuery.isEmpty
        if (isSearchActive && sectionKind != .searchResults) || (!isSearchActive && sectionKind == .searchResults) {
            // If section should be hidden, provide no items.
            // If snapshot already has items for this section (e.g. from a previous state), they will be replaced by an empty array.
            if isFullSnapshot || snapshot.sectionIdentifiers.contains(sectionKind) {
                 snapshot.deleteItems(snapshot.itemIdentifiers(inSection: sectionKind)) // Clear existing items if any
                 snapshot.appendItems([], toSection: sectionKind) // Append empty array to effectively hide content
            }
        } else {
            if isFullSnapshot || snapshot.sectionIdentifiers.contains(sectionKind) {
                snapshot.deleteItems(snapshot.itemIdentifiers(inSection: sectionKind)) // Clear existing items before adding new ones
                snapshot.appendItems(itemsToAdd, toSection: sectionKind)
            }
        }
    }

    func applySnapshot(for section: SectionLayoutKind, animatingDifferences: Bool) {
        guard dataSource != nil else {
            print("ERROR: DataSource is nil when trying to applySnapshot for section \(section)")
            return
        }
        var snapshot = dataSource.snapshot()

        guard snapshot.sectionIdentifiers.contains(section) else {
            print("Warning: Attempted to apply snapshot to a non-existent section: \(section). Re-applying all sections as a fallback.")
            applyAllSectionsSnapshot(animatingDifferences: animatingDifferences)
            return
        }
        
        // No need to delete items first if applyItems handles replacing them, 
        // but explicit deletion ensures the section is clean before adding new items.
        // applyItems now handles deletion/replacement internally based on fullSnapshot logic.
        // For a single section update, we want to replace its content.
        
        // Re-fetch items for this specific section and apply them.
        // The applyItems helper can be used here too, but it needs the overall snapshot to modify.
        // Let's refine applyItems or create a specific version for single section updates if needed.
        // For now, let's ensure applyItems correctly replaces items in the given section.

        // The current applyItems logic is designed for building a full snapshot.
        // For a single section update, we need to be careful.
        // A simpler approach for single section update:
        let placeholders = (0..<skeletonCellCount).map { _ in PlaceholderItem() }
        var itemsToApply: [AnyHashable] = []
        let isLoading: Bool
        let currentData: [AnyHashable]

        switch section {
        case .trendingMovies:    isLoading = viewModel.isLoadingTrending; currentData = viewModel.trendingMovies
        case .popularMovies:     isLoading = viewModel.isLoadingPopular;  currentData = viewModel.popularMovies
        case .topRatedMovies:    isLoading = viewModel.isLoadingTopRated; currentData = viewModel.topRatedMovies
        case .nowPlayingMovies:  isLoading = viewModel.isLoadingNowPlaying; currentData = viewModel.nowPlayingMovies
        case .upcomingMovies:    isLoading = viewModel.isLoadingUpcoming; currentData = viewModel.upcomingMovies
        case .genres:            isLoading = viewModel.isLoadingGenres;     currentData = viewModel.movieGenres
        case .searchResults:     isLoading = viewModel.isLoadingSearchResults; currentData = viewModel.searchResults
        }

        if isLoading && currentData.isEmpty {
            itemsToApply = placeholders
        } else if !currentData.isEmpty {
            itemsToApply = currentData
        } // Else, itemsToApply remains empty for no data & not loading.

        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: section))
        snapshot.appendItems(itemsToApply, toSection: section)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

