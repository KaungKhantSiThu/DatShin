//
//  HomeViewController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 09/05/2024.
//

import UIKit
import Nuke
import NukeExtensions
import Combine

class HomeViewController: DSDataLoadingViewController {
    
    var collectionView: UICollectionView! = nil
    var dataSource: DataSource! = nil
    
    let fetcher: MoviesFetcherService
    
    let prefetcher = ImagePrefetcher()
    
    var sectionsStore: AnyModelStore<Section> = AnyModelStore([])
    var moviesStore: AnyModelStore<Movie> = AnyModelStore([])
    
    var loadingTask: Task<Void, Never>?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()
    
    init(fetcherService: MoviesFetcherService) {
        self.fetcher = fetcherService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Movies"
        // Do any additional setup after loading the view.
        configureViewController()
        configureHierarchy()
        createDataSource()
        fetchMovies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prefetcher.isPaused = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        prefetcher.isPaused = true
        loadingTask?.cancel()
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
//        
//        navigationController?.navigationBar.barTintColor = UIColor.clear
    }
    
}


extension HomeViewController {
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.isPrefetchingEnabled = true
        collectionView.prefetchDataSource = self
        
        // To ignore Safe Area Layout
        collectionView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        collectionView.register(RankedPosterCell.self, forCellWithReuseIdentifier: RankedPosterCell.reuseIdentifier)
        collectionView.register(CoverCell.self, forCellWithReuseIdentifier: CoverCell.reuseIdentifier)
        collectionView.register(NowPlayingCell.self, forCellWithReuseIdentifier: NowPlayingCell.reuseIdentifier)

    }
    
    func configure<T: SelfConfiguringCell>(_ cellType: T.Type, with movie: Movie, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(cellType)")
        }
        
        cell.configure(with: movie)
        return cell
    }
    
    func createDataSource() {
        
        dataSource = DataSource(collectionView: collectionView) { [weak self] (collectionView, indexPath, movieWrapper) in
            guard let self = self else { return nil }
            guard let identifier = Identifier(rawValue: indexPath.section)  else { return nil}
            let section = self.sectionsStore.fetchByID(identifier)
            let movie = self.moviesStore.fetchByID(movieWrapper.movieID)
            switch section.id {
            case .nowPlaying:
                return self.configure(NowPlayingCell.self, with: movie, for: indexPath)
            case .popular:
                return self.configure(CoverCell.self, with: movie, for: indexPath)
            case .topRated:
                return self.configure(RankedPosterCell.self, with: movie, for: indexPath)
            case .upcoming:
                return self.configure(CoverCell.self, with: movie, for: indexPath)
            }
        }
        
        // Header
        let headerRegistration = UICollectionView.SupplementaryRegistration<MoviesRowHeaderSupplementaryView>(elementKind: MoviesRowHeaderSupplementaryView.reuseIdentifier) { [weak self]  (supplementaryView, string, indexPath) in
            
            guard let self = self else { return }
            
            let sectionID = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            supplementaryView.titleLabel.text = sectionID.description
        }
        
        let footerRegistration = UICollectionView.SupplementaryRegistration<PagingSectionFooterView>(elementKind: PagingSectionFooterView.reuseIdentifier) { [weak self] (pagingFooter, elementKind, indexPath) in
            
            guard let self = self else { return }
            
            let sectionID = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            let itemCount = self.dataSource.snapshot().numberOfItems(inSection: sectionID)
            pagingFooter.configure(with: itemCount)
            
            pagingFooter.subscribeTo(subject: pagingInfoSubject, for: indexPath.section)
        }
        
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            if kind == MoviesRowHeaderSupplementaryView.reuseIdentifier {
                return self.collectionView.dequeueConfiguredReusableSupplementary(
                    using: headerRegistration, for: index)
            } else {
                return self.collectionView.dequeueConfiguredReusableSupplementary(
                    using: footerRegistration, for: index)
            }
        }

    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
            guard let identifier = Identifier(rawValue: sectionIndex)  else { fatalError("Section doesn't exist") }
            let section = self.sectionsStore.fetchByID(identifier)
            switch section.id {
            case .nowPlaying:
                return self.createNowPlayingSection()
            case .popular:
                return self.createPosterSection()
            case .topRated:
                return self.createRankSection()
            case .upcoming:
                return self.createPosterSection()

            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        return layout
    }
    
    func createNowPlayingSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1.3))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        layoutSection.interGroupSpacing = 10
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
        let pagingFooterElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: PagingSectionFooterView.reuseIdentifier, alignment: .bottom)
        pagingFooterElement.contentInsets = NSDirectionalEdgeInsets(top: -70, leading: 0, bottom: 0, trailing: 0)
        layoutSection.boundarySupplementaryItems = [pagingFooterElement]

        layoutSection.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
            guard let self = self else { return }

            let page = round(offset.x / self.view.bounds.width)

            self.pagingInfoSubject.send(PagingInfo(sectionIndex: 0, currentPage: Int(page)))
        }
        
        return layoutSection
    }
    
    func createRankSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .estimated(170))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .continuous
        layoutSection.interGroupSpacing = 10
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let layoutSectionHeader = createSectionHeader()
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        return layoutSection
    }
    
    func createPosterSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalWidth(0.25 * 1.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        section.boundarySupplementaryItems = [self.createSectionHeader()]
        return section
    }
    
    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                             heightDimension: .estimated(50))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSectionHeaderSize,
            elementKind: MoviesRowHeaderSupplementaryView.reuseIdentifier,
            alignment: .top)
        return layoutSectionHeader
    }

}


