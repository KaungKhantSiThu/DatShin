//
//  Gender.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 26/05/2024.
//

import Foundation

///
/// A model representing the gender of a person.
///
public enum Gender: Int, Codable, Equatable, Hashable, Sendable {

    ///
    /// An unknown gender.
    ///
    case unknown = 0

    ///
    /// A female.
    ///
    case female = 1

    ///
    /// A male.
    ///
    case male = 2

    ///
    /// Some other gender.
    ///
    case other = 3

    public init(from decoder: Decoder) throws {
        self = try Gender(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }

}
