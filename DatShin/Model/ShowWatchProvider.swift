//
//  ShowWatchProvider.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 29/05/2024.
//

import Foundation

struct ShowWatchProviderResult: Equatable, Decodable {
    let id: Int
    let results: [String: ShowWatchProvider]
}

///
/// A model representing a show's watch provider.
///
struct ShowWatchProvider: Equatable, Codable, Sendable {

    ///
    /// A link to the watch provider.
    ///
    let link: String

    ///
    /// A list of free watch providers.
    ///
    let free: [WatchProvider]?

    ///
    /// A list of flat rate watch providers.
    ///
    let flatRate: [WatchProvider]?

    ///
    /// A list of watch providers to buy from.
    ///
    let buy: [WatchProvider]?

    ///
    /// A list of watch providers to rent from.
    ///
    let rent: [WatchProvider]?

    ///
    /// Creates a show credits object.
    ///
    /// - Parameters:
    ///   - link: A link to the watch provider.
    ///   - free: A list of free watch providers.
    ///   - flatRate: A list of flat rate watch providers.
    ///   - buy: A list of watch providers to buy from.
    ///   - rent: A list of watch providers to rent from.
    ///
    init(
        link: String,
        free: [WatchProvider]? = nil,
        flatRate: [WatchProvider]? = nil,
        buy: [WatchProvider]? = nil,
        rent: [WatchProvider]? = nil
    ) {
        self.link = link
        self.free = free
        self.flatRate = flatRate
        self.buy = buy
        self.rent = rent
    }

}

extension ShowWatchProvider {

    private enum CodingKeys: String, CodingKey {
        case link
        case free
        case flatRate = "flatrate"
        case buy
        case rent
    }

}

