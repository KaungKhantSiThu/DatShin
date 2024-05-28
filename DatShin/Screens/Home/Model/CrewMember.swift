//
//  CrewMember.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 26/05/2024.
//

import Foundation

///
/// A model representing a crew member..
///
struct CrewMember: Identifiable, Codable, Equatable, Hashable, Sendable {

    ///
    /// Crew member's identifier.
    ///
    let id: Int

    ///
    /// Crew member's identifier for the particular movie or TV series.
    ///
    let creditID: String

    ///
    /// Crew member's name.
    ///
    let name: String

    ///
    /// Crew member's job.
    ///
    let job: String

    ///
    /// Crew member's department.
    ///
    let department: String

    ///
    /// Crew member's gender.
    ///
    let gender: Gender?

    ///
    /// Crew member's profile image.
    ///
    /// To generate a full URL see <doc:/TMDb/GeneratingImageURLs>.
    ///
    let profilePath: URL?

    ///
    /// Creates a crew member object.
    ///
    /// - Parameters:
    ///    - id: Crew member's identifier.
    ///    - creditID: Crew member's identifier for the particular movie or TV series.
    ///    - name: Crew member's name.
    ///    - job: Crew member's job.
    ///    - department: Crew member's department.
    ///    - gender: Crew member's gender.
    ///    - profilePath: Crew member's profile image.
    ///
    init(
        id: Int,
        creditID: String,
        name: String,
        job: String,
        department: String,
        gender: Gender? = nil,
        profilePath: URL? = nil
    ) {
        self.id = id
        self.creditID = creditID
        self.name = name
        self.job = job
        self.department = department
        self.gender = gender
        self.profilePath = profilePath
    }

}

extension CrewMember {

    private enum CodingKeys: String, CodingKey {
        case id
        case creditID = "creditId"
        case name
        case job
        case department
        case gender
        case profilePath
    }

}
