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
    
    @Published private(set) var movie: Movie?
    
    //    @Published var title = ""
    //    @Published var tagline = ""
    //    @Published var overview = ""
    //    @Published var runtime = ""
    //    @Published var image: UIImage?
    
    @Published private(set) var castMembers: [CastMember] = []
    @Published private(set) var similarMovies: [Movie] = []
    
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    lazy var coreDataStack = CoreDataStack(modelName: "DatShin")
    
    
    init(id: Movie.ID, fetcherService: MoviesFetcherService) {
        self.id = id
        self.fetcherService = fetcherService
    }
    
    struct MovieDetail {
        let movie: Movie
        let showCredits: ShowCredits
        let similarMovies: [Movie]
    }
    
    func fetchData() {
        Task {
            do {
                self.isLoading = true
                async let movieData = fetcherService.fetchDetail(forMovie: id)
                async let showCreditsData = fetcherService.fetchCastAndCrew(forMovie: id)
                async let similarMoviesData = fetcherService.fetchSimilar(toMovie: id)
                
                
                let movieDetail = try await MovieDetail(movie: movieData, showCredits: showCreditsData, similarMovies: similarMoviesData)
                self.isLoading = false
                self.movie = movieDetail.movie
                //                guard let movie = self.movie else { return }
                //                title = movie.title
                //                tagline = movie.tagline ?? "No tagline"
                //                overview = movie.overview ?? "No overview"
                //                runtime = "\(movie.runtime ?? 0) minutes"
                //                ImageLoader.shared.downloadImage(from: movie.backdropPath, as: .backdrop) { [weak self] image in
                //                    self?.image = image
                //                }
                self.castMembers = movieDetail.showCredits.cast
                self.similarMovies = movieDetail.similarMovies
            } catch {
                self.isLoading = false
                self.error = error
            }
        }
    }
    
    func applySnapshot(to dataSource: UICollectionViewDiffableDataSource<MovieDetailRootView.Section, MovieDetailRootView.Item>) {
        print("Checking if movie exist")
        guard let movie = movie else {
            print("movie doesn't exist")
            return
        }
        print("movie exists")
        var snapshot = NSDiffableDataSourceSnapshot<MovieDetailRootView.Section, MovieDetailRootView.Item>()
        snapshot.appendSections(MovieDetailRootView.Section.allCases)
        
        var headerSnapshot = NSDiffableDataSourceSectionSnapshot<MovieDetailRootView.Item>()
        headerSnapshot.append([.header(movie)])
        dataSource.apply(headerSnapshot, to: .header, animatingDifferences: false)
        
        var castMembersSnapshot = NSDiffableDataSourceSectionSnapshot<MovieDetailRootView.Item>()
        castMembersSnapshot.append(castMembers.map { MovieDetailRootView.Item.castMember($0) })
        dataSource.apply(castMembersSnapshot, to: .castMembers, animatingDifferences: false)
        
        print("Applied to Data Source")
    }
    
    @objc
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
