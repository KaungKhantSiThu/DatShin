//
//  HomeViewController+Delegate.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 26/05/2024.
//

import UIKit

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movieID = dataSource.itemIdentifier(for: indexPath) else { return }
        let detailVC = MovieDetailViewController(viewModel: .init(id: movieID, fetcherService: fetcher))
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
