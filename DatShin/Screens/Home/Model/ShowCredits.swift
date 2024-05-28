//
//  ShowCredits.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 26/05/2024.
//

import Foundation

///
/// A model representing a show's (movie or TV series) credits.
///
/// A person can be both a cast member and crew member of the same show.
///
struct ShowCredits: Identifiable, Codable, Equatable, Hashable, Sendable {

    ///
    /// Movie or TV series identifier.
    ///
    let id: Int

    ///
    /// Cast members of the show.
    ///
    let cast: [CastMember]

    ///
    /// Crew members of the show.
    ///
    let crew: [CrewMember]

    ///
    /// Creates a show credits object.
    ///
    /// - Parameters:
    ///    - id: Movie or TV series identifier.
    ///    - cast: Cast members of the show.
    ///    - crew: Crew members of the show.
    ///
    init(id: Int, cast: [CastMember], crew: [CrewMember]) {
        self.id = id
        self.cast = cast
        self.crew = crew
    }

}
