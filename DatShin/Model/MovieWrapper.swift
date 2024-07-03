//
//  MovieWrapper.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/07/2024.
//

import Foundation

struct MovieWrapper: Hashable {
    let movieID: Movie.ID
    let sectionID: Section.ID
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(movieID)
        hasher.combine(sectionID)
    }
    
    static func == (lhs: MovieWrapper, rhs: MovieWrapper) -> Bool {
        return lhs.movieID == rhs.movieID && lhs.sectionID == rhs.sectionID
    }
}
