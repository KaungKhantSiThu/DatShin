//
//  SearchViewController+UICollectionViewDelegate.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 04/06/2024.
//

import UIKit

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionKind = SectionLayoutKind(rawValue: indexPath.section) else { return }
        

        switch sectionKind {
        case .trendingMovies:
            if indexPath.item < self.viewModel.trendingMovies.count {
                delegate?.searchViewController(self, didSelectMovie: self.viewModel.trendingMovies[indexPath.item])
            }
        case .popularMovies:
            if indexPath.item < self.viewModel.popularMovies.count {
                delegate?.searchViewController(self, didSelectMovie: self.viewModel.popularMovies[indexPath.item])
            }
        case .topRatedMovies:
            if indexPath.item < self.viewModel.topRatedMovies.count {
                delegate?.searchViewController(self, didSelectMovie: self.viewModel.topRatedMovies[indexPath.item])
            }
        case .nowPlayingMovies:
            if indexPath.item < self.viewModel.nowPlayingMovies.count {
                delegate?.searchViewController(self, didSelectMovie: self.viewModel.nowPlayingMovies[indexPath.item])
            }
        case .upcomingMovies:
            if indexPath.item < self.viewModel.upcomingMovies.count {
                delegate?.searchViewController(self, didSelectMovie: self.viewModel.upcomingMovies[indexPath.item])
            }
        case .genres:
            if indexPath.item < self.viewModel.movieGenres.count {
                delegate?.searchViewController(self, didSelectGenre: self.viewModel.movieGenres[indexPath.item])
            }
        }
    }
}
