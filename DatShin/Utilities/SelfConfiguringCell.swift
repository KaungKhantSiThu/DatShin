//
//  SelfConfiguringCell.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 17/05/2024.
//

import Foundation

protocol SelfConfiguringCell {
    static var reuseIdentifier: String { get }
    func configure(with movie: Movie)
}
