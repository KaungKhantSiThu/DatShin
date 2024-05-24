//
//  MoviesSpotlightDelegate.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 24/05/2024.
//

import Foundation
import CoreData
import CoreSpotlight

class MoviesSpotlightDelegate: NSCoreDataCoreSpotlightDelegate {
    override func domainIdentifier() -> String {
        return "com.kkst.DatShin.movies"
    }

    override func indexName() -> String? {
        return "movies-index"
    }
    
    override func attributeSet(for object: NSManagedObject) -> CSSearchableItemAttributeSet? {
        if let movie = object as? WLMovie {
            let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
            attributeSet.displayName = movie.title
            
            for case let genre as WLGenre in movie.genres {
                if attributeSet.keywords != nil {
                    attributeSet.keywords?.append(genre.name)
                } else {
                    attributeSet.keywords = [genre.name]
                }
            }
            
            return attributeSet
        }

        return nil
    }
}
