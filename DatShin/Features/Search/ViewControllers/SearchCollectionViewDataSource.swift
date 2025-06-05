//
//  SearchCollectionViewDataSource.swift
//  DatShin
//
//  Created by Cascade on 2025-06-05.
//

import UIKit

@MainActor
final class SearchCollectionViewDataSource: NSObject {
    typealias Section = SectionLayoutKind
    typealias Item = AnyHashable
    
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private weak var collectionView: UICollectionView?
    private unowned let viewModel: SearchViewModel
    
    init(collectionView: UICollectionView, viewModel: SearchViewModel) {
        self.collectionView = collectionView
        self.viewModel = viewModel
        super.init()
        configureDataSource()
    }
    
    private func configureDataSource() {
        guard let collectionView = collectionView else { return }
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            guard let self = self, let sectionKind = SectionLayoutKind(rawValue: indexPath.section) else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyStateCell.reuseIdentifier, for: indexPath) as! EmptyStateCell
                cell.setMessage("Error displaying content.")
                return cell
            }
            return self.configureCell(collectionView: collectionView, indexPath: indexPath, item: item, sectionKind: sectionKind)
        }
    }
    
    private func configureCell(collectionView: UICollectionView, indexPath: IndexPath, item: Item, sectionKind: SectionLayoutKind) -> UICollectionViewCell {
        let isLoadingSection: Bool
        switch sectionKind {
        case .trendingMovies:    isLoadingSection = viewModel.isLoadingTrending && viewModel.trendingMovies.isEmpty
        case .popularMovies:     isLoadingSection = viewModel.isLoadingPopular && viewModel.popularMovies.isEmpty
        case .topRatedMovies:    isLoadingSection = viewModel.isLoadingTopRated && viewModel.topRatedMovies.isEmpty
        case .nowPlayingMovies:  isLoadingSection = viewModel.isLoadingNowPlaying && viewModel.nowPlayingMovies.isEmpty
        case .upcomingMovies:    isLoadingSection = viewModel.isLoadingUpcoming && viewModel.upcomingMovies.isEmpty
        case .genres:            isLoadingSection = viewModel.isLoadingGenres && viewModel.movieGenres.isEmpty
        }
        
        if isLoadingSection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SkeletonCell.reuseIdentifier, for: indexPath) as! SkeletonCell
            return cell
        }
        
        if let movieItem = item as? MovieListItem {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
            if let imagesConfig = viewModel.imagesConfiguration {
                cell.configure(with: movieItem, imagesConfiguration: imagesConfig)
            } else {
                cell.posterImageView.image = UIImage(systemName: "photo")
                cell.showSkeleton(false)
            }
            return cell
        } else if let genreItem = item as? Genre {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCell.reuseIdentifier, for: indexPath) as! GenreCell
            cell.configure(with: genreItem)
            return cell
        } else if item is PlaceholderItem {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SkeletonCell.reuseIdentifier, for: indexPath) as! SkeletonCell
            return cell
        } else if item is EmptyStateItem {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyStateCell.reuseIdentifier, for: indexPath) as! EmptyStateCell
            cell.setMessage("No content available")
            return cell
        }
//        else if item is LoadingMoreItem {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingIndicatorCell.reuseIdentifier, for: indexPath) as! LoadingIndicatorCell
//            cell.startAnimating()
//            return cell
//        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyStateCell.reuseIdentifier, for: indexPath) as! EmptyStateCell
        cell.setMessage("Unknown content type")
        return cell
    }
    
    // Supplementary view provider for section headers
    func configureSupplementaryViews() {
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard let self = self, kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HeaderSupplementaryView.reuseIdentifier,
                for: indexPath) as! HeaderSupplementaryView
            if let sectionKind = SectionLayoutKind(rawValue: indexPath.section) {
                header.isHidden = false
                header.titleLabel.text = sectionKind.title
            }
            return header
        }
    }

    // MARK: - Snapshot Application
    func applyAllSectionsSnapshot(animatingDifferences: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(SectionLayoutKind.allCases)
        SectionLayoutKind.allCases.forEach { sectionKind in
            applyItems(for: sectionKind, to: &snapshot, isFullSnapshot: true)
        }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    func applyItems(for sectionKind: SectionLayoutKind, to snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>, isFullSnapshot: Bool = false) {
        let placeholders = (0..<5).map { _ in PlaceholderItem() }
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
        }
        
        // Loading state: show skeletons
        if isLoading && currentData.isEmpty {
            itemsToAdd = placeholders
        } else if !currentData.isEmpty {
            itemsToAdd = currentData
        } else {
            // Not loading and no data: show empty state cell
            itemsToAdd = [EmptyStateItem()]
        }
        
        // Pagination indicator for popular movies
        if sectionKind == .popularMovies && viewModel.isLoadingMorePopularMovies {
            itemsToAdd.append(LoadingMoreItem())
        }
        
        // Remove items from other sections to avoid duplicate identifier errors
        for item in itemsToAdd {
            if let existingSection = snapshot.sectionIdentifier(containingItem: item), existingSection != sectionKind {
                snapshot.deleteItems([item])
            }
        }
        
        if isFullSnapshot || snapshot.sectionIdentifiers.contains(sectionKind) {
            snapshot.deleteItems(snapshot.itemIdentifiers(inSection: sectionKind))
            snapshot.appendItems(itemsToAdd, toSection: sectionKind)
        }
    }

    func applySnapshot(for section: SectionLayoutKind, animatingDifferences: Bool) {
        var snapshot = dataSource.snapshot()
        guard snapshot.sectionIdentifiers.contains(section) else {
            applyAllSectionsSnapshot(animatingDifferences: animatingDifferences)
            return
        }
        
        let placeholders = (0..<5).map { _ in PlaceholderItem() }
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
        }
        
        if isLoading && currentData.isEmpty {
            itemsToApply = placeholders
        } else if !currentData.isEmpty {
            itemsToApply = currentData
        } else {
            // Not loading and no data: show empty state cell
            itemsToApply = [EmptyStateItem()]
        }
        
        // Pagination indicator for popular movies
        if section == .popularMovies && viewModel.isLoadingMorePopularMovies {
            itemsToApply.append(LoadingMoreItem())
        }
        
        // Remove items from other sections to avoid duplicate identifier errors
        for item in itemsToApply {
            if let existingSection = snapshot.sectionIdentifier(containingItem: item), existingSection != section {
                snapshot.deleteItems([item])
            }
        }
        
        if snapshot.sectionIdentifiers.contains(section) {
            snapshot.deleteItems(snapshot.itemIdentifiers(inSection: section))
            snapshot.appendItems(itemsToApply, toSection: section)
        }
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

