//
//  WatchProvider.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 29/05/2024.
//

import Foundation

///
/// A model representing a watch provider.
///
struct WatchProvider: Identifiable, Codable, Equatable, Hashable, Sendable {

    ///
    /// Watch Provider identifier.
    ///
    let id: Int

    ///
    /// Watch Provider Name.
    ///
    let name: String

    ///
    /// Watch Provider logo path.
    ///
    /// To generate a full URL see <doc:/TMDb/GeneratingImageURLs>.
    ///
    let logoPath: URL

    ///
    /// Creates a watch provider object.
    ///
    /// - Parameters:
    ///    - id: Watch Provider identifier.
    ///    - name: Watch Provider name.
    ///    - logoPath: Watch Provider logo path.
    ///
    init(id: Int, name: String, logoPath: URL) {
        self.id = id
        self.name = name
        self.logoPath = logoPath
    }

}

extension WatchProvider {

    private enum CodingKeys: String, CodingKey {
        case id = "providerId"
        case name = "providerName"
        case logoPath

    }

}
