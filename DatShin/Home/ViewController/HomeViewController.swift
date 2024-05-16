//
//  HomeViewController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 09/05/2024.
//

import UIKit
import Nuke
import NukeExtensions

class HomeViewController: DSDataLoadingViewController {
    
    var collectionView: UICollectionView! = nil
    var dataSource: DataSource! = nil
    
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
        configureDataSource()
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
    }
    
}


extension HomeViewController {
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.isPrefetchingEnabled = true
        collectionView.prefetchDataSource = self
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<DSPosterCell, Movie.ID> { [weak self] (cell, indexPath, movieID) in
            guard let self = self else { return }
            
            
            guard let identifier = Identifier(rawValue: indexPath.section)  else { return }
            let section = self.sectionsStore.fetchByID(identifier)
            
            let imageURL: URL
            let movie = self.moviesStore.fetchByID(movieID)
            
            //            switch section.id {
            //            case "playlist":
            //                return self.createMediumTableSection(using: section)
            //            case "collections":
            //                return self.createSmallTableSection(using: section)
            //            default:
            //                return self.createFeaturedSection(using: section)
            //            }
            switch section.id {
            case .nowPlaying:
                imageURL = ImageLoader.shared.generateFullURL(from: movie.backdropPath, as: .backdrop, idealWidth: 300)
                //            case .popular:
                //                <#code#>
                //            case .topRated:
                //                <#code#>
                //            case .upcoming:
                //                <#code#>
            default:
                imageURL = ImageLoader.shared.generateFullURL(from: movie.posterPath, as: .poster, idealWidth: 100)
            }
            
            let request = self.makeRequest(with: imageURL, cellSize: cell.bounds.size)
            let options = self.makeImageLoadingOptions()
            NukeExtensions.loadImage(with: request, options: options, into: cell.imageView)
        }
        
        dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, identifier) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: TitleSupplementaryView.reuseIdentifier) { [weak self] (supplementaryView, string, indexPath) in
            
            guard let self = self else { return }
            
            let sectionID = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            supplementaryView.titleLabel.text = sectionID.description
        }
        
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: supplementaryRegistration, for: index)
        }
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
            
            guard let identifier = Identifier(rawValue: sectionIndex)  else { return nil }
            let section = self.sectionsStore.fetchByID(identifier)
            //            switch section.id {
            //            case "playlist":
            //                return self.createMediumTableSection(using: section)
            //            case "collections":
            //                return self.createSmallTableSection(using: section)
            //            default:
            //                return self.createFeaturedSection(using: section)
            //            }
            switch section.id {
            case .nowPlaying:
                return self.createFeaturedSection(using: section)
                
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
    
    func createFeaturedSection(using section: Section) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalWidth(0.5))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        
        let layoutSectionHeader = createSectionHeader()
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        
        return layoutSection
    }
    
    func createHorizontalSection(using section: Section) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(150))
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
                                                             heightDimension: .estimated(44))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSectionHeaderSize,
            elementKind: TitleSupplementaryView.reuseIdentifier,
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
                
                
                //                collections = [
                //                    .init(id: .upcoming, movies: movies.3),
                //                    .init(id: .nowPlaying, movies: movies.1),
                //                    .init(id: .popular, movies: movies.2),
                //                    .init(id: .topRated, movies: movies.0)
                //                ]
                
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
    
    
    
    func makeRequest(with url: URL, cellSize: CGSize) -> ImageRequest {
        ImageRequest(url: url)
    }
    
    func makeImageLoadingOptions() -> ImageLoadingOptions {
        ImageLoadingOptions(transition: .fadeIn(duration: 0.25))
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movieID = dataSource.itemIdentifier(for: indexPath) else { return }
        let detailVC = MovieDetailViewController(viewModel: .init(id: movieID, fetcherService: fetcher))
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
