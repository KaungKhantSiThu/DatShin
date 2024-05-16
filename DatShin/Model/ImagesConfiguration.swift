//
//  ImagesConfiguration.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 09/05/2024.
//

import Foundation

///
/// A model representing images configuration, which holds data relevant to building image URLs.
///
/// To build an image URL, you will need 3 pieces of data. The `base_url`, `size` and `file_path`. Simply combine them
/// all and you will have a fully qualified URL.
///
/// See <doc:/GeneratingImageURLs> for more details.
///
struct ImagesConfiguration: Codable, Equatable, Hashable, Sendable {

    ///
    /// Base image URL (http).
    ///
    let baseURL: URL

    ///
    /// Base Image secure URL (https).
    ///
    let secureBaseURL: URL

    ///
    /// Backdrop image sizes.
    ///
    let backdropSizes: [String]

    ///
    /// Logo image sizes.
    ///
    let logoSizes: [String]

    ///
    /// Poster image sizes.
    ///
    let posterSizes: [String]

    ///
    /// Profile image sizes.
    ///
    let profileSizes: [String]

    ///
    /// Still image sizes.
    ///
    let stillSizes: [String]

    ///
    /// Creates an images configuration object.
    ///
    /// - Parameters:
    ///    - baseURL: Base image URL (http).
    ///    - secureBaseURL: Base Image secure URL (https).
    ///    - backdropSizes: Backdrop image sizes.
    ///    - logoSizes: Logo image sizes.
    ///    - posterSizes: Poster image sizes.
    ///    - profileSizes: Profile image sizes.
    ///    - stillSizes: Still image sizes.
    ///
    init(
        baseURL: URL,
        secureBaseURL: URL,
        backdropSizes: [String],
        logoSizes: [String],
        posterSizes: [String],
        profileSizes: [String],
        stillSizes: [String]
    ) {
        self.baseURL = baseURL
        self.secureBaseURL = secureBaseURL
        self.backdropSizes = backdropSizes
        self.logoSizes = logoSizes
        self.posterSizes = posterSizes
        self.profileSizes = profileSizes
        self.stillSizes = stillSizes
    }

}

extension ImagesConfiguration {

    private enum CodingKeys: String, CodingKey {
        case baseURL = "baseUrl"
        case secureBaseURL = "secureBaseUrl"
        case backdropSizes
        case logoSizes
        case posterSizes
        case profileSizes
        case stillSizes
    }

}
