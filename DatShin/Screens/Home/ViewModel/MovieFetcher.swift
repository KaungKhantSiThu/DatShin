//
//  MovieFetcher.swift
//  Yote Shin
//
//  Created by Kaung Khant Si Thu on 12/04/2024.
//

import Foundation

protocol MoviesFetcher {
    func fetchMovies(page: Int, section: Identifier) async throws -> [Movie]
    func fetchDetail(forMovie movieID: Movie.ID) async throws -> Movie
//    func fetchCastAndCrew(forMovie movieID: Movie.ID) async throws -> ShowCredits
    func fetchSimilar(toMovie movieID: Movie.ID, page: Int?) async throws -> [Movie]
}
