//
//  MovieCoordinator.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import UIKit

/// Coordinator responsible for handling movie detail presentation.
/// This coordinator might be further refactored or absorbed if its role diminishes significantly.
final class MovieCoordinator: BaseCoordinator, SearchViewControllerDelegate {
    
    // MARK: - Properties
    
    private let viewControllerFactory: ViewControllerFactoryProtocol
    private let serviceFactory: ServiceFactoryProtocol // Added for SearchResultsViewModel
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactoryProtocol, serviceFactory: ServiceFactoryProtocol) { // Added serviceFactory
        self.viewControllerFactory = viewControllerFactory
        self.serviceFactory = serviceFactory // Added serviceFactory
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        // This coordinator no longer manages a primary view for a tab.
        // Its main purpose, if retained, would be to facilitate the presentation of movie details
        // when invoked by other coordinators.
        logger.debug("MovieCoordinator started. It does not push a default view controller.")
    }
    
    // MARK: - Navigation Methods
    
    func showMovieDetail(movieID: Movie.ID) {
        let detailViewController = viewControllerFactory.makeMovieDetailViewController(movieID: movieID)
        navigationController.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - SearchViewControllerDelegate
extension MovieCoordinator {
    // func searchViewControllerDidTapSearchButton(_ controller: SearchViewController) { ... } // Obsolete: UISearchController handles presentation
    
    // Handles selections from SearchViewController's carousels
    func searchViewController(_ controller: SearchViewController, didSelectMovie movie: MovieListItem) {
        logger.debug("Movie selected from SearchViewController carousel: \(movie.title)")
        showMovieDetail(movieID: movie.id)
    }

    func searchViewController(_ controller: SearchViewController, didSelectGenre genre: Genre) {
        // TODO: Implement genre selection navigation (e.g., to a screen listing movies by genre)
        logger.debug("Genre selected: \(genre.name). Navigation not yet implemented.")
    }

    // Handles selections passed from SearchResultsViewController via SearchViewController
    func searchViewController(_ controller: SearchViewController, didSelectMedia media: Media) {
        switch media {
        case .movie(let movieListItem):
            logger.debug("Media (Movie) selected via SearchViewController: \(movieListItem.title)")
            showMovieDetail(movieID: movieListItem.id)
        case .tvSeries(let tvSeriesListItem):
            logger.debug("Media (TV Series) selected via SearchViewController: \(tvSeriesListItem.name). Navigation TODO.")
            // TODO: Implement navigation to TV series detail
            // let tvSeriesDetailCoordinator = TVSeriesDetailCoordinator(navigationController: navigationController, viewControllerFactory: viewControllerFactory, serviceFactory: serviceFactory, tvSeriesID: tvSeriesListItem.id)
            // addChildCoordinator(tvSeriesDetailCoordinator)
            // tvSeriesDetailCoordinator.start()
        case .person(let personListItem):
            logger.debug("Media (Person) selected via SearchViewController: \(personListItem.name). Navigation TODO.")
            // TODO: Implement navigation to person detail
            // let personDetailCoordinator = PersonDetailCoordinator(navigationController: navigationController, viewControllerFactory: viewControllerFactory, serviceFactory: serviceFactory, personID: personListItem.id)
            // addChildCoordinator(personDetailCoordinator)
            // personDetailCoordinator.start()
        }
    }
}

