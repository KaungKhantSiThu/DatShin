//
//  HomeViewController+ImagePrefetching.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 11/05/2024.
//

import UIKit

private var loggingEnabled = true

extension HomeViewController: UICollectionViewDataSourcePrefetching {
    // MARK: UICollectionViewDataSourcePrefetching

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let imageURLs = getImageURLs(for: indexPaths)
        prefetcher.startPrefetching(with: imageURLs)
        if loggingEnabled {
            print("prefetchItemsAt: \(stringForIndexPaths(indexPaths))")
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let imageURLs = getImageURLs(for: indexPaths)
        prefetcher.stopPrefetching(with: imageURLs)
        if loggingEnabled {
            print("cancelPrefetchingForItemsAt: \(stringForIndexPaths(indexPaths))")
        }
    }
    
    func getImageURLs(for indexPaths: [IndexPath]) -> [URL] {
//        return indexPaths.compactMap {
//              $0.row < collections.endIndex ? collections[$0.row] : nil
//            }.flatMap(getImages)
        return indexPaths.compactMap {
            sectionsStore.fetchByIndexPath($0)?.id ?? nil
        }.flatMap(getImages)
    }
    
    func getImages(for id: Section.ID) -> [URL] {
        return sectionsStore.fetchMovieIDs(by: id)
            .map {
                let movie = moviesStore.fetchByID($0)
                return ImageLoader.shared.generateFullURL(from: movie.posterPath, as: .poster, idealWidth: 100)
            }
    }
}

private func stringForIndexPaths(_ indexPaths: [IndexPath]) -> String {
    guard indexPaths.count > 0 else {
        return "[]"
    }
    let items = indexPaths
        .map { return "\(($0 as NSIndexPath).item)" }
        .joined(separator: " ")
    return "[\(items)]"
}
