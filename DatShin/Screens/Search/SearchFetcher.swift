//
//  SearchFetcher.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 20/05/2024.
//

import Foundation

protocol SearchFetcher {
    func fetchMovies(query: String, year: Int?, page: Int?) async throws -> [Movie]
    /*
    func fetchAll(query: String, page: Int?) async throws -> [Media]
    
    
    func fetchTVSeries(query: String, firstAirDateYear: Int?, page: Int?) async throws -> [TVSeries]
    func fetchPeople(query: String, page: Int?) async throws -> [Person]
    */
}
