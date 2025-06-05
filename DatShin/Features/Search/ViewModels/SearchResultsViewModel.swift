//
//  SearchResultsViewModel.swift
//  DatShin
//
//  Created by Cascade on 04/06/2025.
//

import Foundation
import Combine

// Define LoadingState outside or make it generic if used elsewhere, for now, keeping it file-private or internal.
enum LoadingState<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(_ value: Value, canLoadMore: Bool)
    case empty(message: String)
    case error(message: String)
}

@MainActor
class SearchResultsViewModel {

    // MARK: - Dependencies
    private let searchService: SearchService
    private let imageConfigurationService: ConfigurationService // To get image base URLs


    // MARK: - Published Properties
    @Published private(set) var state: LoadingState<[Media]> = .idle
    @Published private(set) var imagesConfiguration: ImagesConfiguration? = nil
    @Published var currentQuery: String = ""
    @Published var currentFilter: FilterType = .all

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPage: Int = 1
    private var totalPages: Int = 1
    private var currentItems: [Media] = [] // Holds current loaded items for pagination
    
    private var isPerformingRequest: Bool = false // Prevents concurrent requests

    enum FilterType: Int, CaseIterable {
        case all = 0
        case movies = 1
        case tvShows = 2
        case people = 3

        var title: String {
            switch self {
            case .all: return "All"
            case .movies: return "Movies"
            case .tvShows: return "TV Shows"
            case .people: return "People"
            }
        }
    }

    // MARK: - Initialization
    init(searchService: SearchService, imageConfigurationService: ConfigurationService) {
        self.searchService = searchService
        self.imageConfigurationService = imageConfigurationService
        fetchImageConfiguration()
        setupBindings()
    }

    /// Sets up Combine bindings to trigger search on query or filter change, debounced for user experience like Apple TV app.
    private func setupBindings() {
        $currentQuery
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                if query.isEmpty {
                    self.clearResults()
                } else {
                    self.fetchInitialData()
                }
            }
            .store(in: &cancellables)

        $currentFilter
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if !self.currentQuery.isEmpty {
                    self.fetchInitialData()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods
    func fetchInitialData() {
        guard !currentQuery.isEmpty else {
            currentItems = []
            state = .empty(message: "Start typing to search for movies, TV shows, and more.")
            return
        }
        resetPaginationAndSearch()
    }
    
    func loadMoreResults() {
        guard !isPerformingRequest, currentPage < totalPages else { return }
        performSearch(loadMore: true)
    }

    func clearResults() {
        currentQuery = ""
        currentItems = []
        state = .idle // Or .empty with a generic message
        resetPagination()
    }

    // MARK: - Private Helper Methods
    private func fetchImageConfiguration() {
        Task {
            do {
                let config = try await imageConfigurationService.apiConfiguration()
                await MainActor.run {
                    self.imagesConfiguration = config.images
                }
            } catch {
                await MainActor.run {
                    print("Error fetching image configuration: \(error)")
                }
            }
        }
    }
    
    private func setupQueryDebouncing() {
        $currentQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                if query.isEmpty {
                    self.clearResults()
                } else {
                    // New query means new search, not pagination
                    self.fetchInitialData()
                }
            }
            .store(in: &cancellables)
    }

    private func resetPagination() {
        currentPage = 1
        totalPages = 1
        currentItems = []
    }

    private func resetPaginationAndSearch() {
        resetPagination()
        performSearch(loadMore: false)
    }

    private func performSearch(loadMore: Bool) {
        guard !currentQuery.isEmpty, !isPerformingRequest else {
            if currentQuery.isEmpty && !loadMore { // Explicitly set empty if query cleared and not loading more
                state = .empty(message: "Start typing to search...")
            }
            return
        }

        isPerformingRequest = true
        let requestedPage = loadMore ? currentPage + 1 : 1

        if !loadMore {
            currentItems = [] // Clear items for a new search
            state = .loading
        } // For loadMore, UI can show a footer loading indicator based on a separate flag or by observing currentPage changes.

        Task {
            do {
                var responsePage: Int = 0
                var responseTotalPages: Int = 0
                var response: MediaPageableList

                switch currentFilter {
                case .all:
                    response = try await searchService.searchAll(query: currentQuery, page: requestedPage, language: nil)
                case .movies:
                    let movieResponse = try await searchService.searchMovies(query: currentQuery, page: requestedPage, language: nil)
                    response = MediaPageableList(page: movieResponse.page, results: movieResponse.results.map { Media.movie($0) }, totalResults: movieResponse.totalResults, totalPages: movieResponse.totalPages)
                case .tvShows:
                    let tvResponse = try await searchService.searchTVSeries(query: currentQuery, page: requestedPage, language: nil)
                    response = MediaPageableList(page: tvResponse.page, results: tvResponse.results.map { Media.tvSeries($0) }, totalResults: tvResponse.totalResults, totalPages: tvResponse.totalPages)
                case .people:
                    let peopleResponse = try await searchService.searchPeople(query: currentQuery, page: requestedPage, language: nil)
                    response = MediaPageableList(page: peopleResponse.page, results: peopleResponse.results.map { Media.person($0) }, totalResults: peopleResponse.totalResults, totalPages: peopleResponse.totalPages)
                }

                responsePage = response.page ?? 1
                responseTotalPages = response.totalPages ?? 1
                
                await MainActor.run {
                    self.currentPage = responsePage
                    self.totalPages = responseTotalPages
                    
                    if loadMore {
                        self.currentItems.append(contentsOf: response.results)
                    } else {
                        self.currentItems = response.results
                    }

                    if self.currentItems.isEmpty {
                        self.state = .empty(message: "No results found for '\(self.currentQuery)'.")
                    } else {
                        self.state = .loaded(self.currentItems, canLoadMore: self.currentPage < self.totalPages)
                    }
                    self.isPerformingRequest = false
                }

            } catch {
                await MainActor.run {
                    // Preserve existing data on pagination error, otherwise show error state
                    if !loadMore {
                        self.currentItems = []
                        self.state = .error(message: "Failed to fetch results: \(error.localizedDescription)")
                    } else {
                        // For pagination errors, we could show a toast or simply stop loading more.
                        // For now, revert to previous loaded state without canLoadMore if it was true.
                        if case .loaded(let items, _) = self.state {
                            self.state = .loaded(items, canLoadMore: false) // Indicate cannot load more due to error
                        }
                        // Optionally log the error or show a non-intrusive error message.
                        print("Error loading more search results: \(error.localizedDescription)")
                    }
                    self.isPerformingRequest = false
                }
            }
        }
    }

}
