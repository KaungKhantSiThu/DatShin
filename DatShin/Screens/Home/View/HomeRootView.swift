////
////  HomeRootView.swift
////  DatShin
////
////  Created by Kaung Khant Si Thu on 26/05/2024.
////
//import UIKit
//
//class HomeRootView: NiblessView {
//    
//    let viewModel: HomeViewModel
//    
//    private var collectionView: UICollectionView! = nil
//    private var dataSource: UICollectionViewDiffableDataSource<Section.ID, Movie.ID>! = nil
//    
//    var hierarchyNotReady = true
//    
//    init(frame: CGRect = .zero,
//         viewModel: HomeViewModel) {
//        self.viewModel = viewModel
//        super.init(frame: frame)
//        constructHierarchy()
//        configureDataSource()
//        bindViewModel()
//        print("init")
//    }
//    
//    override func didMoveToWindow() {
//        super.didMoveToWindow()
//        guard hierarchyNotReady else {
//            return
//        }
//        backgroundColor = .systemBackground
//        
//        hierarchyNotReady = false
//        print("didMoveToWindow")
//    }
//    
//    func constructHierarchy() {
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
//        collectionView.backgroundColor = .systemBackground
//        collectionView.delegate = self
//        collectionView.isPrefetchingEnabled = true
//        collectionView.prefetchDataSource = self
//        
//        // To ignore Safe Area Layout
//        collectionView.contentInsetAdjustmentBehavior = .never
//
//        
//        addSubview(collectionView)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            collectionView.topAnchor.constraint(equalTo: topAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
//        ])
//        
//        collectionView.register(PosterCell.self, forCellWithReuseIdentifier: PosterCell.reuseIdentifier)
//        collectionView.register(FeaturedViewCell.self, forCellWithReuseIdentifier: FeaturedViewCell.reuseIdentifier)
//
//    }
//    
//    func configureDataSource() {
//        dataSource = UICollectionViewDiffableDataSource<Section.ID, Movie.ID>(collectionView: collectionView) {
//            (collectionView, indexPath, movieID) in
//            guard let identifier = Identifier(rawValue: indexPath.section) else { fatalError("Unknown section") }
//            let section = self.viewModel.sectionsStore.fetchByID(identifier)
//            let movie = self.viewModel.moviesStore.fetchByID(movieID)
//            switch section.id {
//            case .nowPlaying:
//                return self.configure(FeaturedViewCell.self, with: movie, for: indexPath)
////            case .popular:
////                <#code#>
////            case .topRated:
////                <#code#>
////            case .upcoming:
////                <#code#>
//            default:
//                return self.configure(PosterCell.self, with: movie, for: indexPath)
//            }
//        }
//        
//        // Header
//        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<MoviesRowHeaderSupplementaryView>(elementKind: MoviesRowHeaderSupplementaryView.reuseIdentifier) { [weak self] (supplementaryView, string, indexPath) in
//            
//            guard let self = self else { return }
//            
//            let sectionID = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
//            supplementaryView.titleLabel.text = sectionID.description
//        }
//        
//        dataSource.supplementaryViewProvider = { (view, kind, index) in
//            return self.collectionView.dequeueConfiguredReusableSupplementary(
//                using: supplementaryRegistration, for: index)
//        }
//    }
//    
//    func configure<T: SelfConfiguringCell>(_ cellType: T.Type, with movie: Movie, for indexPath: IndexPath) -> T {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
//            fatalError("Unable to dequeue \(cellType)")
//        }
//        
//        cell.configure(with: movie)
//        return cell
//    }
//    
//    func createCompositionalLayout() -> UICollectionViewLayout {
//        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
//            
//            
//            guard let identifier = Identifier(rawValue: sectionIndex) else { fatalError("Unknown section") }
//            let section = self.viewModel.sectionsStore.fetchByID(identifier)
//            switch section.id {
//            case .nowPlaying:
//                return self.createFeaturedSection(using: sectionIndex)
//                
//                //            case .popular:
//                //                <#code#>
//                //            case .topRated:
//                //                <#code#>
//                //            case .upcoming:
//                //                <#code#>
//            default:
//                return self.createHorizontalSection(using: section)
//            }
//        }
//        
//        let config = UICollectionViewCompositionalLayoutConfiguration()
//        config.interSectionSpacing = 20
//        layout.configuration = config
//        return layout
//    }
//    
//    func createFeaturedSection(using sectionIndex: Int) -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
//        
//        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1.3))
//        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
//        
//        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
//        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
//        layoutSection.interGroupSpacing = 10
//        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
//        
//        return layoutSection
//    }
//    
//    func createHorizontalSection(using section: Section) -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
//        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .estimated(170))
//        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
//        
//        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
//        layoutSection.orthogonalScrollingBehavior = .continuous
//        layoutSection.interGroupSpacing = 10
//        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
//        
//        let layoutSectionHeader = createSectionHeader()
//        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
//        return layoutSection
//    }
//    
//    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
//        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                                             heightDimension: .estimated(50))
//        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: layoutSectionHeaderSize,
//            elementKind: MoviesRowHeaderSupplementaryView.reuseIdentifier,
//            alignment: .top)
//        return layoutSectionHeader
//    }
//    
//    func bindViewModel() {
//        
//    }
//}
//
//extension HomeRootView: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let movieID = dataSource.itemIdentifier(for: indexPath) else { return }
//        let detailVC = MovieDetailViewController(viewModel: .init(id: movieID, fetcherService: MoviesFetcherService(requestManager: RequestManager())))
////        navigationController?.pushViewController(detailVC, animated: true)
//    }
//}
//
//private var loggingEnabled = true
//
//extension HomeViewController: UICollectionViewDataSourcePrefetching {
//    // MARK: UICollectionViewDataSourcePrefetching
//
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        let imageURLs = getImageURLs(for: indexPaths)
//        prefetcher.startPrefetching(with: imageURLs)
//        if loggingEnabled {
//            print("prefetchItemsAt: \(stringForIndexPaths(indexPaths))")
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
//        let imageURLs = getImageURLs(for: indexPaths)
//        prefetcher.stopPrefetching(with: imageURLs)
//        if loggingEnabled {
//            print("cancelPrefetchingForItemsAt: \(stringForIndexPaths(indexPaths))")
//        }
//    }
//    
//    func getImageURLs(for indexPaths: [IndexPath]) -> [URL] {
////        return indexPaths.compactMap {
////              $0.row < collections.endIndex ? collections[$0.row] : nil
////            }.flatMap(getImages)
//        return indexPaths.compactMap {
//            sectionsStore.fetchByIndexPath($0)?.id ?? nil
//        }.flatMap(getImages)
//    }
//    
//    func getImages(for id: Section.ID) -> [URL] {
//        return sectionsStore.fetchMovieIDs(by: id)
//            .map {
//                let movie = moviesStore.fetchByID($0)
//                return ImageLoader.shared.generateFullURL(from: movie.posterPath, as: .poster, idealWidth: 100)
//            }
//    }
//}
//
//private func stringForIndexPaths(_ indexPaths: [IndexPath]) -> String {
//    guard indexPaths.count > 0 else {
//        return "[]"
//    }
//    let items = indexPaths
//        .map { return "\(($0 as NSIndexPath).item)" }
//        .joined(separator: " ")
//    return "[\(items)]"
//}
