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
    
    private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()

    
    let fetcher: MoviesFetcherService
    
    let prefetcher = ImagePrefetcher()
    
    var sectionsStore: AnyModelStore<Section> = AnyModelStore([])
    var moviesStore: AnyModelStore<Movie> = AnyModelStore([])
    
    private var loadingTask: Task<Void, Never>?
    
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
//
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
        
        collectionView.register(PosterCell.self, forCellWithReuseIdentifier: PosterCell.reuseIdentifier)
        collectionView.register(FeaturedViewCell.self, forCellWithReuseIdentifier: FeaturedViewCell.reuseIdentifier)

    }
    
    func configure<T: SelfConfiguringCell>(_ cellType: T.Type, with movie: Movie, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(cellType)")
        }
        
        cell.configure(with: movie)
        return cell
    }
    
    func createDataSource() {
        
        dataSource = DataSource(collectionView: collectionView) { [weak self] (collectionView, indexPath, movieID) in
            guard let self = self else { return nil }
            guard let identifier = Identifier(rawValue: indexPath.section)  else { return nil}
            let section = self.sectionsStore.fetchByID(identifier)
            let movie = self.moviesStore.fetchByID(movieID)
            switch section.id {
            case .nowPlaying:
                return self.configure(FeaturedViewCell.self, with: movie, for: indexPath)
//            case .popular:
//                <#code#>
//            case .topRated:
//                <#code#>
//            case .upcoming:
//                <#code#>
            default:
                return self.configure(PosterCell.self, with: movie, for: indexPath)
            }
        }
        
        // Header
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<MoviesRowHeaderSupplementaryView>(elementKind: MoviesRowHeaderSupplementaryView.reuseIdentifier) { [weak self] (supplementaryView, string, indexPath) in
            
            guard let self = self else { return }
            
            let sectionID = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            supplementaryView.titleLabel.text = sectionID.description
        }
        
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: supplementaryRegistration, for: index)
        }
        
        // Footer
        
//        let pagingFooter = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: PagingSectionFooterView.reuseIdentifier, for: indexPath) as! PagingSectionFooterView
//
//        let itemCount = self.datasource.snapshot().numberOfItems(inSection: indexPath.section)
//        pagingFooter.configure(with: itemCount)
//
//        pagingFooter.subscribeTo(subject: pagingInfoSubject, for: indexPath.section)
//
//        return pagingFooter
//        let footerRegistration = UICollectionView.SupplementaryRegistration<PagingSectionFooterView>(elementKind: PagingSectionFooterView.reuseIdentifier) { [weak self] supplementaryView, elementKind, indexPath in
//            guard let self = self else { return }
//            
//            let sectionID = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
//            let itemCount = self.dataSource.snapshot().numberOfItems(inSection: sectionID)
//            supplementaryView.configure(with: itemCount)
//            supplementaryView.subscribeTo(subject: pagingInfoSubject, for: indexPath.section)
//        }
//        
//        dataSource.supplementaryViewProvider = { (view, kind, index) in
//            return self.collectionView.dequeueConfiguredReusableSupplementary(
//                using: footerRegistration, for: index)
//        }

    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
            
            guard let identifier = Identifier(rawValue: sectionIndex)  else { return nil }
            let section = self.sectionsStore.fetchByID(identifier)
            switch section.id {
            case .nowPlaying:
                return self.createFeaturedSection(using: sectionIndex)
                
                //            case .popular:
                //                <#code#>
                //            case .topRated:
                //                <#code#>
                //            case .upcoming:
                //                <#code#>
            default:
                return self.createHorizontalSection(using: section)
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        return layout
    }
    
    func createFeaturedSection(using sectionIndex: Int) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1.3))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        layoutSection.interGroupSpacing = 10
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        // Header
//        let layoutSectionHeader = createSectionHeader()
//        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        
        // Footer
        /*
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(20))

        let pagingFooterElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        layoutSection.boundarySupplementaryItems += [pagingFooterElement]

        layoutSection.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
            guard let self = self else { return }

            let page = round(offset.x / self.view.bounds.width)

            self.pagingInfoSubject.send(PagingInfo(sectionIndex: sectionIndex, currentPage: Int(page)))
        }
*/
        
        return layoutSection
    }
    
    func createHorizontalSection(using section: Section) -> NSCollectionLayoutSection {
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
    
    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                             heightDimension: .estimated(50))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSectionHeaderSize,
            elementKind: MoviesRowHeaderSupplementaryView.reuseIdentifier,
            alignment: .top)
        return layoutSectionHeader
    }
    
    func fetchMovies() {
        
        loadingTask = Task {
            
            do {
                async let topRated = try fetcher.fetchMovies(page: 1, section: .topRated)
                async let nowPlaying = try fetcher.fetchMovies(page: 1, section: .nowPlaying)
                async let popular = try fetcher.fetchMovies(page: 1, section: .popular)
                async let upcoming = try fetcher.fetchMovies(page: 1, section: .upcoming)
                
                let movies = try await (topRated, nowPlaying, popular, upcoming)

                moviesStore = AnyModelStore(duplicatedIDs: [movies.0, movies.1, movies.2, movies.3])
                
                sectionsStore = AnyModelStore([
                    .init(id: .upcoming, movies: movies.3.map { $0.id }),
                    .init(id: .nowPlaying, movies: movies.1.map { $0.id }),
                    .init(id: .popular, movies: movies.2.map { $0.id }),
                    .init(id: .topRated, movies: movies.0.map { $0.id })
                ])
                
                setInitialData()
                
            } catch {
                presentDSAlertOnMainThread(title: "Movies fetch failed", message: error.localizedDescription, buttonTitle: "Ok")
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movieID = dataSource.itemIdentifier(for: indexPath) else { return }
        let detailVC = MovieDetailViewController(viewModel: .init(id: movieID, fetcherService: fetcher))
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
