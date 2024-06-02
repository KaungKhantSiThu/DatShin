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
        case similarMovies
        case watchProviders
        
        var title: String? {
            switch self {
            case .castMembers: return "Cast & Crew"
            case .similarMovies: return "Similar"
            case .watchProviders: return "Watch Providers"
            default: return nil
            }
        }
    }
    
    enum Item: Hashable {
        case header(Movie)
        case castMember(CastMember)
        case similarMovie(Movie)
        case watchProvider(WatchProvider)
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
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])

        collectionView.register(MovieHeaderCell.self, forCellWithReuseIdentifier: MovieHeaderCell.reuseIdentifier)
        collectionView.register(PersonCell.self, forCellWithReuseIdentifier: PersonCell.reuseIdentifier)
        collectionView.register(CoverCell.self, forCellWithReuseIdentifier: CoverCell.reuseIdentifier)
        collectionView.register(StreamingCell.self, forCellWithReuseIdentifier: StreamingCell.reuseIdentifier)
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
            case .similarMovies:
                return self.createSimilarSection()
            case .watchProviders:
                return self.createWatchProviderSection()
            }
        }
    }
    
    private func createHeaderSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.3))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        section.boundarySupplementaryItems = [self.createSectionHeader()]
        return section
    }
    
    private func createSimilarSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalWidth(0.25 * 1.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        section.boundarySupplementaryItems = [self.createSectionHeader()]
        return section
    }
    
    private func createWatchProviderSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.33))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .fractionalWidth(0.55))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered

        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
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
            case .similarMovie(let relatedMovie):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CoverCell.reuseIdentifier, for: indexPath) as! CoverCell
                cell.configure(with: relatedMovie)
                return cell
                
            case .watchProvider(let watchProvider):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StreamingCell.reuseIdentifier, for: indexPath) as! StreamingCell
                cell.configure(with: watchProvider)
                return cell
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
            .combineLatest(viewModel.$castMembers, viewModel.$similarMovies, viewModel.$watchProviders)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (_, _, _, _) in
                    guard let self = self else { return }
                    self.applySnapshot()
                }
                .store(in: &subscriptions)
        }
    
    func applySnapshot() {
        viewModel.applySnapshot(to: dataSource)
    }
}
