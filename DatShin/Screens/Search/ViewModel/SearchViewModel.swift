//
//  SearchViewModel.swift
//  DatShin
//
//  Created by Cascade on 04/06/2025.
//

import Foundation
import Combine
//import TMDb // Ensure TMDb is imported to use Movie, Genre types

@MainActor
class SearchViewModel: ObservableObject {
    
    // MARK: - Services
    private let movieService: MovieServiceProtocol
    private let searchService: SearchServiceProtocol
    private let trendingService: TrendingServiceProtocol
    private let genreService: GenreServiceProtocol
    
    // MARK: - Published Properties for UI
    
    // Discovery Sections - Using concrete TMDb types
    @Published var popularMovies: [MovieListItem] = []
    @Published var topRatedMovies: [MovieListItem] = []
    @Published var nowPlayingMovies: [MovieListItem] = []
    @Published var upcomingMovies: [MovieListItem] = []
    @Published var trendingMovies: [MovieListItem] = [] // For the trending movies carousel
    @Published var movieGenres: [Genre] = []
    
    // Search Results
    @Published var searchResults: [MovieListItem] = [] // Assuming search primarily returns movies
    @Published var currentSearchQuery: String = ""
    
    // Loading States
    @Published var isLoadingPopular: Bool = false
    @Published var isLoadingTopRated: Bool = false
    @Published var isLoadingNowPlaying: Bool = false
    @Published var isLoadingUpcoming: Bool = false
    @Published var isLoadingTrending: Bool = false
    @Published var isLoadingGenres: Bool = false
    @Published var isLoadingSearchResults: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var searchDebounceTimer: Timer?

    // MARK: - Initialization
    init(
        movieService: MovieServiceProtocol,
        searchService: SearchServiceProtocol,
        trendingService: TrendingServiceProtocol,
        genreService: GenreServiceProtocol
    ) {
        self.movieService = movieService
        self.searchService = searchService
        self.trendingService = trendingService
        self.genreService = genreService
        
        // Debounce search query
        $currentSearchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Fetching
    
    func fetchInitialDiscoveryData() {
        fetchPopularMovies()
        fetchTopRatedMovies()
        fetchNowPlayingMovies()
        fetchUpcomingMovies()
        fetchTrendingMovies() // Fetch trending movies
        fetchMovieGenres()
    }
    
    private func performSearch(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        isLoadingSearchResults = true
        Task {
            defer { isLoadingSearchResults = false }
            do {
                // Assuming searchService.movies(query:page:) exists and is the correct method
                // The actual method might be different, e.g., searchService.searchMovies(query:page:)
                let moviesPage = try await searchService.searchMovies(query: query, page: 1)
                self.searchResults = moviesPage.results
            } catch {
                print("Error performing search for '\(query)': \(error.localizedDescription)")
                self.searchResults = [] // Clear results on error
            }
        }
    }
    
    // MARK: - Private Fetching Helpers
    
    private func fetchPopularMovies() {
        isLoadingPopular = true
        Task {
            defer { isLoadingPopular = false }
            do {
                let moviesPage = try await movieService.popular(page: 1)
                self.popularMovies = moviesPage.results
            } catch {
                print("Error fetching popular movies: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchTopRatedMovies() {
        isLoadingTopRated = true
        Task {
            defer { isLoadingTopRated = false }
            do {
                let moviesPage = try await movieService.topRated(page: 1)
                self.topRatedMovies = moviesPage.results
            } catch {
                print("Error fetching top rated movies: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchNowPlayingMovies() {
        isLoadingNowPlaying = true
        Task {
            defer { isLoadingNowPlaying = false }
            do {
                let moviesPage = try await movieService.nowPlaying(page: 1)
                self.nowPlayingMovies = moviesPage.results
            } catch {
                print("Error fetching now playing movies: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchUpcomingMovies() {
        isLoadingUpcoming = true
        Task {
            defer { isLoadingUpcoming = false }
            do {
                let moviesPage = try await movieService.upcoming(page: 1)
                self.upcomingMovies = moviesPage.results
            } catch {
                print("Error fetching upcoming movies: \(error.localizedDescription)")
            }
        }
    }

    private func fetchTrendingMovies() {
        isLoadingTrending = true
        Task {
            defer { isLoadingTrending = false }
            do {
                // Using .day as default time window, can be parameterized if needed
                let moviesPage = try await trendingService.movies(inTimeWindow: .day, page: 1)
                self.trendingMovies = moviesPage.results
            } catch {
                print("Error fetching trending movies: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchMovieGenres() {
        isLoadingGenres = true
        Task {
            defer { isLoadingGenres = false }
            do {
                self.movieGenres = try await genreService.movieGenres()
            } catch {
                print("Error fetching movie genres: \(error.localizedDescription)")
            }
        }
    }
}
