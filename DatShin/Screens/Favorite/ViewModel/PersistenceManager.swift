//
//  PersistenceManager.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 14/05/2024.
//

import Foundation
import OSLog

enum PersistenceActionType {
    case add, remove
}

let logger = Logger(subsystem: "DatShin", category: "Persistance")

struct FavoriteMovie: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let title: String
    let posterPath: URL?
}

enum PersistenceManager {
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let movies = "favorite_movies"
    }
    
    static func updateWith(favorite: FavoriteMovie, actionType: PersistenceActionType, completed: @escaping (DSError?) -> Void) {
        retrieveFavorites { result in
            switch result {
            case .success(var favorites):
                
                switch actionType {
                case .add:
                    guard !favorites.contains(favorite) else {
                        completed(.alreadyBookmarked)
                        return
                    }
                    
                    favorites.append(favorite)
                case .remove:
                    favorites.removeAll { $0.id == favorite.id }
                }
                
                completed(save(favorites: favorites))
                
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    static func retrieveFavorites(completed: @escaping (Result<[FavoriteMovie], DSError>) -> Void) {
        guard let favoriteData = defaults.object(forKey: Keys.movies) as? Data else {
            logger.log("Failed to retrieve favorites data from UserDefaults")
            completed(.success([]))
            return
        }
        logger.log("Retrieved movies data from UserDefaults")
        do {
            logger.log("Decoding movies data to Movie Array")
            
            let decoder = JSONDecoder()            
            let favorites = try decoder.decode([FavoriteMovie].self, from: favoriteData)
            logger.log("Successfully Decoded Movie Array of count \(favorites.count) from movies data")
            completed(.success(favorites))
        } catch {
            logger.log("Failed to decode movies data. \(error.localizedDescription)")
            completed(.failure(.unableToRetrieve))
        }
    }
    
    static func save(favorites: [FavoriteMovie]) -> DSError? {
        logger.log("Saving Movie Array to UserDefaults")
        do {
            logger.log("Encoding movies data to Movie Array")
            let encoder = JSONEncoder()
            let encodedFavorites = try encoder.encode(favorites)
            defaults.set(encodedFavorites, forKey: Keys.movies)
            logger.log("Successfully encoded Movie Array to data")
            return nil
        } catch {
            logger.log("Failed to encode Movie Array to data")
            return .unableToBookmark
        }
    }
}
