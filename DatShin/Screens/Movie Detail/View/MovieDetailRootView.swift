//
//  MovieDetailView.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 11/05/2024.
//

import UIKit
import Combine
import Nuke
import NukeExtensions

class MovieDetailRootView: NiblessView {
    
    private var subscriptions = Set<AnyCancellable>()
    let viewModel: MovieDetailViewModel
    var hierarchyNotReady = true
    
    enum Section: Int, CaseIterable {
        case header
        case castMembers
        //        case relatedMovies
        
        var title: String? {
            switch self {
            case .castMembers: return "Cast & Crew"
                //            case .relatedMovies: return "Related Movies"
            default: return nil
            }
        }
    }
    
    enum Item: Hashable {
        case header(Movie)
        case castMember(CastMember)
        //        case relatedMovie(Movie)
    }
    
    private var collectionView: UICollectionView! = nil
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    
    init(frame: CGRect = .zero,
         viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        //        bindToViewModel()
        constructHierarchy()
        configureDataSource()
        bindViewModel()
        print("init")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard hierarchyNotReady else {
            return
        }
        backgroundColor = .systemBackground
        
        hierarchyNotReady = false
        print("didMoveToWindow")
    }
    
    private func constructHierarchy() {
        let layout = createLayout()
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.contentInsetAdjustmentBehavior = .never
        
        addSubview(collectionView)

        collectionView.register(MovieHeaderCell.self, forCellWithReuseIdentifier: MovieHeaderCell.reuseIdentifier)
        collectionView.register(PersonCell.self, forCellWithReuseIdentifier: PersonCell.reuseIdentifier)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.reuseIdentifier)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            let section = Section(rawValue: sectionIndex)!
            switch section {
            case .header:
                return self.createHeaderSection()
            case .castMembers:
                return self.createListSection()
                //            case .relatedMovies:
                //                return self.createListSection()
            }
        }
    }
    
    private func createHeaderSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.3))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func createListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .absolute(180))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        section.boundarySupplementaryItems = [self.createSectionHeader()]
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .header(let movie):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieHeaderCell.reuseIdentifier, for: indexPath) as! MovieHeaderCell
                cell.configure(with: movie)
                return cell
            case .castMember(let castMember):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonCell.reuseIdentifier, for: indexPath) as! PersonCell
                cell.configure(with: castMember)
                return cell
                //            case .relatedMovie(let relatedMovie):
                //                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RelatedMovieCell.reuseIdentifier, for: indexPath) as! RelatedMovieCell
                //                cell.configure(with: relatedMovie)
                //                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as! SectionHeaderView
            let section = Section(rawValue: indexPath.section)!
            header.title = section.title
            return header
        }
    }
    
    private func bindViewModel() {
            viewModel.$movie
                .combineLatest(viewModel.$castMembers)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (_, _) in
                    guard let self = self else { return }
                    self.applySnapshot()
                }
                .store(in: &subscriptions)
        }
    
    func applySnapshot() {
        viewModel.applySnapshot(to: dataSource)
    }
}
