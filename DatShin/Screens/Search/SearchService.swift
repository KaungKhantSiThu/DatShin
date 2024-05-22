//
//  SearchService.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 20/05/2024.
//

import Foundation

actor SearchService {
  private let requestManager: RequestManagerProtocol

  init(requestManager: RequestManagerProtocol) {
    self.requestManager = requestManager
  }
}

extension SearchService: SearchFetcher {
//    func fetchAll(query: String, page: Int? = nil) async throws -> [Media] {
//        let pageableList: MediaPageableList = try await requestManager.get(endpoint: SearchEndpoint.multi(query: query, page: page))
//        return pageableList.results
//    }
    

    
    func fetchMovies(query: String, year: Int? = nil, page: Int? = nil) async throws -> [Movie] {
        let pageableList: MoviePageableList = try await requestManager.get(endpoint: SearchEndpoint.movies(query: query, year: year, page: page))
        return pageableList.results
    }
    
    /*
    func fetchTVSeries(query: String, firstAirDateYear: Int? = nil, page: Int? = nil) async throws -> [TVSeries] {
        let pageableList: TVSeriesPageableList = try await requestManager.get(endpoint: SearchEndpoint.tvSeries(query: query, firstAirDateYear: firstAirDateYear, page: page))
        return pageableList.results
    }
    
    func fetchPeople(query: String, page: Int? = nil) async throws -> [Person] {
        let pageableList: PersonPageableList = try await requestManager.get(endpoint: SearchEndpoint.people(query: query, page: page))
        return pageableList.results
    }
    */
    
}
