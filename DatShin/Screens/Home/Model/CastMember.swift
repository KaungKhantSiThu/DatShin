//
//  CastMember.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 26/05/2024.
//

import Foundation

///
/// A model representing a cast member.
///
struct CastMember: Identifiable, Codable, Equatable, Hashable, Sendable {

    ///
    /// Cast member's identifier.
    ///
    let id: Int

    ///
    /// Cast member's identifier for the particular movie or TV series.
    ///
    let castID: Int?

    ///
    /// Credit identifier for that particular movie or TV series.
    ///
    let creditID: String

    ///
    /// Cast member's real name.
    ///
    let name: String

    ///
    /// Cast member's character name.
    ///
    let character: String

    ///
    /// Cast member's gender.
    ///
    let gender: Gender?

    ///
    /// Cast member's profile image.
    ///
    /// To generate a full URL see <doc:/TMDb/GeneratingImageURLs>.
    ///
    let profilePath: URL?

    ///
    /// Order number in the cast list.
    ///
    let order: Int

    ///
    /// Creates a cast member object.
    ///
    /// - Parameters:
    ///    - id: Cast member's identifier.
    ///    - castID: Cast member's identifier for the particular movie or TV series.
    ///    - creditID: Credit identifier for that particular movie or TV series.
    ///    - name: Cast member's name.
    ///    - character: Cast member's character name.
    ///    - gender: Cast member's gender.
    ///    - profilePath: Cast member's profile image.
    ///    - order: Order number in the cast list.
    ///
    init(
        id: Int,
        castID: Int? = nil,
        creditID: String,
        name: String,
        character: String,
        gender: Gender? = nil,
        profilePath: URL? = nil,
        order: Int
    ) {
        self.id = id
        self.castID = castID
        self.creditID = creditID
        self.name = name
        self.character = character
        self.gender = gender
        self.profilePath = profilePath
        self.order = order
    }

}

extension CastMember {

    private enum CodingKeys: String, CodingKey {
        case id
        case castID = "castId"
        case creditID = "creditId"
        case name
        case character
        case gender
        case profilePath
        case order
    }

}
