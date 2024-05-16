//
//  MovieStoreService.swift
//  Yote Shin
//
//  Created by Kaung Khant Si Thu on 09/04/2024.
//

import Foundation

@MainActor
final class DataStore: ObservableObject {
    
    var movies: [Movie] = []

    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("datshin.data")
    }
    
    func loadData() async throws {
        let task = Task<[Movie], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else { return [] }
            
            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            decoder.dateDecodingStrategy = .formatted(.theMovieDatabase)
            return try decoder.decode([Movie].self, from: data)
        }
        
        let movies = try await task.value
        self.movies = movies
    }
    
    func save(movies: [Movie]) async throws {
        let task = Task {
            
            let data = try JSONEncoder().encode(movies)
            
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        
        _ = try await task.value
    }
}

//actor MovieStoreService {
//  private let context: NSManagedObjectContext
//
//  init(context: NSManagedObjectContext) {
//    self.context = context
//  }
//}
//
//// MARK: - AnimalStore
//extension MovieStoreService: MovieStore {
//
//    func save(movies: [Movie]) async throws {
//        for var movie in movies {
//          movie.toManagedObject(context: context)
//        }
//        try context.save()
//    }
//}
