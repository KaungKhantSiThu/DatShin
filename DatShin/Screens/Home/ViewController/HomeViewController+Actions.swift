//
//  HomeViewController+Actions.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 26/05/2024.
//

import Foundation

extension HomeViewController {
    
    func fetchMovies() {
        
        loadingTask = Task {
            
            do {
                async let topRated = try fetcher.fetchMovies(page: 1, section: .topRated)
                async let nowPlaying = try fetcher.fetchMovies(page: 1, section: .nowPlaying)
                async let popular = try fetcher.fetchMovies(page: 1, section: .popular)
                async let upcoming = try fetcher.fetchMovies(page: 1, section: .upcoming)
                
                let movies = try await (topRated, nowPlaying, popular, upcoming)

                moviesStore = AnyModelStore(duplicatedIDs: [movies.0, movies.1, movies.2, movies.3])
                
                sectionsStore = AnyModelStore([
                    .init(id: .upcoming, movies: movies.3.map { $0.id }),
                    .init(id: .nowPlaying, movies: movies.1.map { $0.id }),
                    .init(id: .popular, movies: movies.2.map { $0.id }),
                    .init(id: .topRated, movies: movies.0.map { $0.id })
                ])
                
                setInitialData()
                
            } catch {
                presentDSAlertOnMainThread(title: "Movies fetch failed", message: error.localizedDescription, buttonTitle: "Ok")
            }
        }
    }
}
