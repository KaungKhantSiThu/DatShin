//
//  SearchViewModel.swift
//  DatShin
//
//  Created by Cascade on 04/06/2025.
//

import Foundation
import Combine
import UIKit // For UIApplication.didReceiveMemoryWarningNotification

// MARK: - SearchViewModelProtocol
@MainActor
protocol SearchViewModelProtocol: ObservableObject {
    // Published Properties
    var popularMovies: [MovieListItem] { get }
    var topRatedMovies: [MovieListItem] { get }
    var nowPlayingMovies: [MovieListItem] { get }
    var upcomingMovies: [MovieListItem] { get }
    var trendingMovies: [MovieListItem] { get }
    var movieGenres: [Genre] { get }
    var searchResults: [MovieListItem] { get }
    var currentSearchQuery: String { get set }
    
    // Loading States
    var isLoadingPopular: Bool { get }
    var isLoadingTopRated: Bool { get }
    var isLoadingNowPlaying: Bool { get }
    var isLoadingUpcoming: Bool { get }
    var isLoadingTrending: Bool { get }
    var isLoadingGenres: Bool { get }
    var isLoadingSearchResults: Bool { get }
    
    // Methods
    func fetchInitialDiscoveryData()
    func fetchNextPopularMoviesPage()
    func fetchNextSearchResultsPage()
}

// MARK: - CachedSearchResults
private class CachedSearchResults {
    let results: [MovieListItem]
    let timestamp: Date
    
    init(results: [MovieListItem]) {
        self.results = results
        self.timestamp = Date()
    }
    
    var isExpired: Bool {
        // Cache expires after 1 hour
        return Date().timeIntervalSince(timestamp) > 3600
    }
}

// MARK: - SearchViewModel
@MainActor
final class SearchViewModel: SearchViewModelProtocol {
    // MARK: - Properties
    
    // Cache for search results
    private let searchResultsCache = NSCache<NSString, CachedSearchResults>()
    private let cacheExpirationInterval: TimeInterval = 3600 // 1 hour
    
    // Services
    private let movieService: MovieServiceProtocol
    private let searchService: SearchServiceProtocol
    private let trendingService: TrendingServiceProtocol
    private let genreService: GenreServiceProtocol
    private let configurationService: ConfigurationService
    
    // Published Properties
    @Published private(set) var popularMovies: [MovieListItem] = []
    @Published private(set) var topRatedMovies: [MovieListItem] = []
    @Published private(set) var nowPlayingMovies: [MovieListItem] = []
    @Published private(set) var upcomingMovies: [MovieListItem] = []
    @Published private(set) var trendingMovies: [MovieListItem] = []
    @Published private(set) var movieGenres: [Genre] = []
    @Published private(set) var searchResults: [MovieListItem] = []
    @Published var currentSearchQuery: String = ""
    
    // Loading States
    @Published private(set) var isLoadingPopular: Bool = false
    @Published private(set) var isLoadingMorePopularMovies: Bool = false
    @Published private(set) var isLoadingTopRated: Bool = false
    @Published private(set) var isLoadingNowPlaying: Bool = false
    @Published private(set) var isLoadingUpcoming: Bool = false
    @Published private(set) var isLoadingTrending: Bool = false
    @Published private(set) var isLoadingGenres: Bool = false
    @Published private(set) var isLoadingSearchResults: Bool = false
    @Published private(set) var isLoadingMoreSearchResults: Bool = false
    
    // Pagination State
    private var popularMoviesCurrentPage: Int = 0
    private var popularMoviesTotalPages: Int = 1
    private var searchResultsCurrentPage: Int = 0
    private var searchResultsTotalPages: Int = 1
    
    // Configuration
    @Published private(set) var imagesConfiguration: ImagesConfiguration?
    
    // Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        movieService: MovieServiceProtocol,
        searchService: SearchServiceProtocol,
        trendingService: TrendingServiceProtocol,
        genreService: GenreServiceProtocol,
        configurationService: ConfigurationService
    ) {
        self.movieService = movieService
        self.searchService = searchService
        self.trendingService = trendingService
        self.genreService = genreService
        self.configurationService = configurationService
        
        setupSearchDebouncing()
        setupMemoryWarningObserver()
        searchResultsCache.countLimit = 20
    }
    
    // MARK: - Setup
    private func setupSearchDebouncing() {
        $currentSearchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                Task { [weak self] in
                    await self?.performSearch(query: query, isNewSearch: true)
                }
            }
            .store(in: &cancellables)
    }

    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    // MARK: - Public Methods
    func fetchInitialDiscoveryData() {
        Task {
            async let configTask = fetchAPIConfiguration()
            async let popularTask = fetchPopularMovies(page: 1)
            async let trendingTask = fetchTrendingMovies()
            async let genresTask = fetchMovieGenres()
            async let topRatedTask = fetchTopRatedMovies()
            async let nowPlayingTask = fetchNowPlayingMovies()
            async let upcomingTask = fetchUpcomingMovies()
            
            // Wait for all tasks to complete
            _ = await [configTask, popularTask, trendingTask, genresTask, topRatedTask, nowPlayingTask, upcomingTask]
        }
    }
    
    func fetchNextPopularMoviesPage() {
        guard !isLoadingPopular, !isLoadingMorePopularMovies, popularMoviesCurrentPage < popularMoviesTotalPages else {
            return
        }
        Task {
            await fetchPopularMovies(page: popularMoviesCurrentPage + 1)
        }
    }
    
    func fetchNextSearchResultsPage() {
        guard !isLoadingSearchResults, !isLoadingMoreSearchResults, searchResultsCurrentPage < searchResultsTotalPages else {
            return
        }
        let query = currentSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            Task {
                await fetchSearchResults(query: query, page: searchResultsCurrentPage + 1)
            }
        }
    }
    
    // MARK: - Private Methods
    private func performSearch(query: String, isNewSearch: Bool) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            searchResults = []
            searchResultsCurrentPage = 0
            searchResultsTotalPages = 1
            return
        }

        if isNewSearch {
            searchResultsCurrentPage = 0
            searchResultsTotalPages = 1
            searchResults = []

            if let cached = searchResultsCache.object(forKey: trimmedQuery as NSString),
               !cached.isExpired {
                self.searchResults = cached.results
                return
            }
        }
        
        await fetchSearchResults(query: trimmedQuery, page: searchResultsCurrentPage + 1)
    }

    private func fetchSearchResults(query: String, page: Int) async {
        guard !query.isEmpty else { return }

        if page == 1 {
            isLoadingSearchResults = true
        } else {
            isLoadingMoreSearchResults = true
        }

            do {
                let moviesPage = try await searchService.searchMovies(query: query, page: page)
            
                if page == 1 {
                    self.searchResults = moviesPage.results
                self.searchResultsCache.setObject(
                    CachedSearchResults(results: moviesPage.results),
                    forKey: query as NSString
                )
                } else {
                    self.searchResults.append(contentsOf: moviesPage.results)
                }
            
                self.searchResultsCurrentPage = moviesPage.page ?? 1
                self.searchResultsTotalPages = moviesPage.totalPages ?? 1
            } catch {
                print("Error fetching search results for '\(query)' (page \(page)): \(error.localizedDescription)")
                if page == 1 {
                    self.searchResults = []
                }
            }
        
        if page == 1 {
            isLoadingSearchResults = false
        } else {
            isLoadingMoreSearchResults = false
        }
    }
    
    private func fetchPopularMovies(page: Int) async {
        if page == 1 {
            isLoadingPopular = true
        } else {
            isLoadingMorePopularMovies = true
        }
        
            do {
                let moviesPage = try await movieService.popular(page: page)
                if page == 1 {
                    self.popularMovies = moviesPage.results
                } else {
                    self.popularMovies.append(contentsOf: moviesPage.results)
                }
                self.popularMoviesCurrentPage = moviesPage.page ?? 1
                self.popularMoviesTotalPages = moviesPage.totalPages ?? 1
            } catch {
                print("Error fetching popular movies (page \(page)): \(error.localizedDescription)")
        }
        
        if page == 1 {
            isLoadingPopular = false
        } else {
            isLoadingMorePopularMovies = false
        }
    }
    
    private func fetchTopRatedMovies() async {
        guard topRatedMovies.isEmpty && !isLoadingTopRated else { return }
        isLoadingTopRated = true
        
            do {
                let moviesPage = try await movieService.topRated(page: 1)
                self.topRatedMovies = moviesPage.results
            } catch {
                print("Error fetching top rated movies: \(error.localizedDescription)")
            }
        
        isLoadingTopRated = false
    }
    
    private func fetchNowPlayingMovies() async {
        guard nowPlayingMovies.isEmpty && !isLoadingNowPlaying else { return }
        isLoadingNowPlaying = true
        
            do {
                let moviesPage = try await movieService.nowPlaying(page: 1)
                self.nowPlayingMovies = moviesPage.results
            } catch {
                print("Error fetching now playing movies: \(error.localizedDescription)")
            }
        
        isLoadingNowPlaying = false
    }
    
    private func fetchUpcomingMovies() async {
        guard upcomingMovies.isEmpty && !isLoadingUpcoming else { return }
        isLoadingUpcoming = true
        
            do {
                let moviesPage = try await movieService.upcoming(page: 1)
                self.upcomingMovies = moviesPage.results
            } catch {
                print("Error fetching upcoming movies: \(error.localizedDescription)")
            }
        
        isLoadingUpcoming = false
    }

    private func fetchTrendingMovies() async {
        isLoadingTrending = true
        
            do {
                let moviesPage = try await trendingService.movies(inTimeWindow: .day, page: 1)
                self.trendingMovies = moviesPage.results
            } catch {
                print("Error fetching trending movies: \(error.localizedDescription)")
            }
        
        isLoadingTrending = false
    }
    
    private func fetchMovieGenres() async {
        isLoadingGenres = true
        
            do {
                self.movieGenres = try await genreService.movieGenres()
            } catch {
                print("Error fetching movie genres: \(error.localizedDescription)")
            }
        
        isLoadingGenres = false
    }
    
    private func fetchAPIConfiguration() async {
        do {
            let apiConfig = try await configurationService.apiConfiguration()
            self.imagesConfiguration = apiConfig.images
        } catch {
            print("Error fetching API configuration: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Memory Management
    @objc private func handleMemoryWarning() {
        searchResultsCache.removeAllObjects()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
