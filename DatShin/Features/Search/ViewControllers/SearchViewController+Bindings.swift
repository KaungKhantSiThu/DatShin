//
//  SearchViewController+Bindings.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 04/06/2024.
//

import UIKit
import Combine

extension SearchViewController {
    
    func setupBindings() {
        // Bindings for data arrays to reload collection view
        let dataChangedPublisher = Publishers.MergeMany(
            viewModel.$popularMovies.map { _ in SectionLayoutKind.popularMovies }.eraseToAnyPublisher(),
            viewModel.$topRatedMovies.map { _ in SectionLayoutKind.topRatedMovies }.eraseToAnyPublisher(),
            viewModel.$nowPlayingMovies.map { _ in SectionLayoutKind.nowPlayingMovies }.eraseToAnyPublisher(),
            viewModel.$upcomingMovies.map { _ in SectionLayoutKind.upcomingMovies }.eraseToAnyPublisher(),
            viewModel.$trendingMovies.map { _ in SectionLayoutKind.trendingMovies }.eraseToAnyPublisher(),
            viewModel.$movieGenres.map { _ in SectionLayoutKind.genres }.eraseToAnyPublisher(),
            viewModel.$searchResults.map { _ in SectionLayoutKind.searchResults }.eraseToAnyPublisher()
        ).eraseToAnyPublisher()

        let loadingStateChangedPublisher = Publishers.MergeMany(
            viewModel.$isLoadingPopular.map { _ in SectionLayoutKind.popularMovies },
            viewModel.$isLoadingTopRated.map { _ in SectionLayoutKind.topRatedMovies },
            viewModel.$isLoadingNowPlaying.map { _ in SectionLayoutKind.nowPlayingMovies },
            viewModel.$isLoadingUpcoming.map { _ in SectionLayoutKind.upcomingMovies },
            viewModel.$isLoadingTrending.map { _ in SectionLayoutKind.trendingMovies },
            viewModel.$isLoadingGenres.map { _ in SectionLayoutKind.genres },
            viewModel.$isLoadingSearchResults.map { _ in SectionLayoutKind.searchResults }
        ).eraseToAnyPublisher()

        Publishers.Merge(dataChangedPublisher, loadingStateChangedPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sectionKindToUpdate in
                guard let self = self else { return }
                if self.isViewLoaded && self.dataSource != nil {
                    self.applySnapshot(for: sectionKindToUpdate, animatingDifferences: true)
                }
            }
            .store(in: &cancellables)

        viewModel.$currentSearchQuery
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.isViewLoaded && self.dataSource != nil {
                    self.applyAllSectionsSnapshot(animatingDifferences: true)
                }
            }
            .store(in: &cancellables)

        viewModel.$isLoadingPopular
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                // TODO: Show/hide loading indicator for popular section or globally
                print("Popular movies loading state: \(isLoading)")
            }
            .store(in: &cancellables)
        
        // TODO: Add similar bindings for other isLoading properties

        viewModel.$currentSearchQuery
            .receive(on: DispatchQueue.main)
            .map { $0 as String? }
            .assign(to: \.searchBar.text, on: navigationItem.searchController!)
            .store(in: &cancellables)
    }
}
