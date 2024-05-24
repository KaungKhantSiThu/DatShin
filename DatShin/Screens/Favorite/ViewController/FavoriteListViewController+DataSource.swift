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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell")  as! FavoriteCell
        let movie = favorites[indexPath.row]
        
        cell.titleLabel.text = movie.title

        if let genres = movie.genres.allObjects as? [WLGenre] {
            cell.genresLabel.text = genres.map { $0.name }.joined(separator: " ")
        }
        let imageURL = ImageLoader.shared.generateFullURL(from: movie.posterPath, as: .poster, idealWidth: 60)
        let request = self.makeRequest(with: imageURL, cellSize: cell.bounds.size)
        let options = self.makeImageLoadingOptions()
        NukeExtensions.loadImage(with: request, options: options, into: cell.posterImageView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let wlMovie = favorites[indexPath.row]
        

        
        coreDataStack.managedContext.delete(wlMovie)
        
        
        coreDataStack.saveContext()
        
        favorites.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        if favorites.isEmpty {
            self.presentDSAlertOnMainThread(title: "Watchlist is Empty", message: "Go bookmark something", buttonTitle: "Ok")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = favorites[indexPath.row]
        let id = Int(movie.id)
        let destinationVC = MovieDetailViewController(viewModel: .init(id: id, fetcherService: fetcherService))

        navigationController?.pushViewController(destinationVC, animated: true)
    }
}
