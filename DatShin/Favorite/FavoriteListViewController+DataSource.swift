//
//  FavoriteListViewController+DataSource.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 14/05/2024.
//

import UIKit
import NukeExtensions
import Nuke

extension FavoriteListViewController: UITableViewDataSource, UITableViewDelegate {
    
    //    enum Category: CaseIterable {
    //        case bookmark
    //    }
    //    // MARK: - Value Types
    //    typealias DataSource = UITableViewDiffableDataSource<Category, FavoriteMovie>
    //    typealias Snapshot = NSDiffableDataSourceSnapshot<Category, FavoriteMovie>
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell")  as! FavoriteCell
//        let cell = UITableViewCell()
//        var content = cell.defaultContentConfiguration()
        let movie = favorites[indexPath.row]
        //        ImageLoader.shared.downloadImage(from: movie.posterPath, as: .poster) { image in
        //            DispatchQueue.main.async {
        //                cell.posterImageView.image = image
        //            }
        //        }
        //        let request = self.makeRequest(with: imageURL, cellSize: cell.bounds.size)
        //        let options = self.makeImageLoadingOptions()
        
//        content.text = movie.title
//        content.image = UIImage(systemName: "popcorn")
        
        cell.titleLabel.text = movie.title
        let imageURL = ImageLoader.shared.generateFullURL(from: movie.posterPath, as: .poster, idealWidth: 60)
        let request = self.makeRequest(with: imageURL, cellSize: cell.bounds.size)
        let options = self.makeImageLoadingOptions()
        NukeExtensions.loadImage(with: request, options: options, into: cell.posterImageView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let favorite = favorites[indexPath.row]
        
        PersistenceManager.updateWith(favorite: favorite, actionType: .remove) { [weak self] error in
            guard let self = self else { return }
            guard let error = error else {
                favorites.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                if favorites.isEmpty {
                    //                    self.showEmptyStateView(with: "No favorites?", in: self.view)
                    
                }
                return
            }
            
            self.presentDSAlertOnMainThread(title: "Unable to remove", message: error.localizedDescription, buttonTitle: "Ok")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = favorites[indexPath.row]
        let destinationVC = MovieDetailViewController(viewModel: .init(id: movie.id, fetcherService: fetcherService))

        navigationController?.pushViewController(destinationVC, animated: true)
    }
}
