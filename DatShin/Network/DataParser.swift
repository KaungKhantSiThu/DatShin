//
//  DataParser.swift
//  Yote Shin
//
//  Created by Kaung Khant Si Thu on 08/04/2024.
//

import Foundation

protocol DataParserProtocol {
    func parse<T: Decodable>(data: Data) throws -> T
    func decode<T: Decodable>(_ type: T.Type, from data: Data) async throws -> T
}

final class DataParser: DataParserProtocol {
    private var jsonDecoder: JSONDecoder
    
    init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        self.jsonDecoder.dateDecodingStrategy = .formatted(.theMovieDatabase)
    }
    
    func parse<T: Decodable>(data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
    
    func decode<T: Decodable>(_ type: T.Type, from data: Data) async throws -> T {
        let decoder = JSONDecoder.theMovieDatabase
        
        return try decoder.decode(type, from: data)
    }
}
