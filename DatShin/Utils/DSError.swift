//
//  DSError.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 14/05/2024.
//

import Foundation

enum DSError: LocalizedError {
    case unableToBookmark
    case alreadyBookmarked
    case unableToRetrieve
    
    var errorDescription: String? {
        switch self {
        case .unableToBookmark:
            "There was an error bookmarking this movie"
            
        case .alreadyBookmarked:
            "You've already bookmarked this movie"
            
        case .unableToRetrieve:
            "There was an error retrieving the bookmarked movies"
        }
    }
}
