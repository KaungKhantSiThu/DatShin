//
//  UICollectionView+Extensions.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 15/05/2024.
//

import UIKit

func createLayout() -> UICollectionViewLayout {
    let sectionProvider = { (sectionIndex: Int,
        layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // if we have the space, adapt and go 2-up + peeking 3rd item
//            let groupFractionalWidth = CGFloat(layoutEnvironment.container.effectiveContentSize.width > 500 ?
//                0.425 : 0.85)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(100),
                                              heightDimension: .absolute(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

        let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44))
        let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: titleSize,
            elementKind: TitleSupplementaryView.reuseIdentifier,
            alignment: .top)
        section.boundarySupplementaryItems = [titleSupplementary]
        return section
    }

    let config = UICollectionViewCompositionalLayoutConfiguration()
    config.interSectionSpacing = 20

    let layout = UICollectionViewCompositionalLayout(
        sectionProvider: sectionProvider, configuration: config)
    return layout
}
