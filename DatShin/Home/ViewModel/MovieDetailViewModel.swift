//
//  MovieDetailViewModel.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 13/05/2024.
//

import Foundation
import UIKit

class MovieDetailViewModel {
    
    // MARK: - Properties
    let fetcherService: MoviesFetcherService
    let id: Movie.ID
    private var movie: Movie? = nil
    
    @Published var title = ""
    @Published var tagline = ""
    @Published var overview = ""
    @Published var image: UIImage? = UIImage(systemName: "photo")
    
    @Published var error: Error?
    
    init(id: Movie.ID, fetcherService: MoviesFetcherService) {
        self.id = id
        self.fetcherService = fetcherService
    }
    
    func fetch() async throws {
        do {
            movie = try await fetcherService.fetchDetail(forMovie: id)
            guard let movie = movie else { return }
            title = movie.title
            tagline = movie.tagline ?? "No tagline"
            overview = movie.overview ?? "No overview"
            ImageLoader.shared.downloadImage(from: movie.backdropPath, as: .backdrop) { [weak self] image in
                self?.image = image
            }
        } catch {
            throw error
        }
    }
    
    func addToBookmark() {
        guard let movie = movie else { return }
        PersistenceManager.updateWith(favorite: FavoriteMovie(id: movie.id, title: title, posterPath: movie.posterPath), actionType: .add) { [weak self] error in
            if let error = error {
                self?.error = error
            }
        }
    }
}
