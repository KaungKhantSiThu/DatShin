//
//  MovieDetailViewModel.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 13/05/2024.
//

import Foundation
import UIKit
import CoreData

class MovieDetailViewModel {
    
    // MARK: - Properties
    let fetcherService: MoviesFetcherService
    let id: Movie.ID
    private var movie: Movie? = nil
    
    @Published var title = ""
    @Published var tagline = ""
    @Published var overview = ""
    @Published var genres = ""
    @Published var runtime = ""
    @Published var image: UIImage? = UIImage(systemName: "photo")
    
    @Published var error: Error?
    
    
    
    lazy var coreDataStack = CoreDataStack(modelName: "DatShin")
    
    
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
            runtime = "\(movie.runtime ?? 0) minutes"
            genres = movie.genres?.map { $0.name }.joined(separator: " * ") ?? "Not genres"
            ImageLoader.shared.downloadImage(from: movie.backdropPath, as: .backdrop) { [weak self] image in
                self?.image = image
            }
        } catch {
            throw error
        }
    }
    
    func addToWatchlist() {
        guard let movie = movie, !itemExists(movie.id) else { return }

        let wlMovie = WLMovie(context: coreDataStack.managedContext)
        wlMovie.id = Int32(movie.id)
        wlMovie.title = movie.title
        wlMovie.savedAt = Date()
        wlMovie.posterPath = movie.posterPath!
        wlMovie.hasWatched = false
        
        if let genres = movie.genres {
            for genre in genres {
                let wlGenre = WLGenre(context: coreDataStack.managedContext)
                wlGenre.id = Int16(genre.id)
                wlGenre.name = genre.name
                wlMovie.addToGenres(wlGenre)
                wlGenre.addToMovies(wlMovie)
            }
        }
        
        coreDataStack.saveContext()
    }
    
    func itemExists(_ id: Movie.ID) -> Bool {
        let request = WLMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", Int32(id))
        return ((try? coreDataStack.managedContext.count(for: request)) ?? 0) > 0
    }
}
