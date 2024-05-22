//
//  SearchEndpoint.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 20/05/2024.
//

import Foundation

enum SearchEndpoint {

    case multi(query: String, page: Int? = nil)
    case movies(query: String, year: Int? = nil, page: Int? = nil)
    case tvSeries(query: String, firstAirDateYear: Int? = nil, page: Int? = nil)
    case people(query: String, page: Int? = nil)

}

extension SearchEndpoint: Endpoint {

    static let basePath = URL(string: "/search")!

    private enum QueryItemName {
        static let query = "query"
    }

    var path: URL {
        switch self {
        case let .multi(query, page):
            Self.basePath
                .appendingPathComponent("multi")
                .appendingQueryItem(name: QueryItemName.query, value: query)
                .appendingPage(page)

        case let .movies(query, year, page):
            Self.basePath
                .appendingPathComponent("movie")
                .appendingQueryItem(name: QueryItemName.query, value: query)
                .appendingYear(year)
                .appendingPage(page)

        case let .tvSeries(query, firstAirDateYear, page):
            Self.basePath
                .appendingPathComponent("tv")
                .appendingQueryItem(name: QueryItemName.query, value: query)
                .appendingFirstAirDateYear(firstAirDateYear)
                .appendingPage(page)

        case let .people(query, page):
            Self.basePath
                .appendingPathComponent("person")
                .appendingQueryItem(name: QueryItemName.query, value: query)
                .appendingPage(page)
        }
    }

}

