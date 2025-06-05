import Foundation

// MARK: - Supporting Types
struct PlaceholderItem: Hashable {
    let id = UUID()
}

struct EmptyStateItem: Hashable {
    let id = UUID()
}

struct LoadingMoreItem: Hashable {
    let id = UUID()
} 

// Define sections for the CollectionView. Internal for access from extensions.
enum SectionLayoutKind: Int, CaseIterable {
    case trendingMovies
    case popularMovies
    case topRatedMovies
    case nowPlayingMovies
    case upcomingMovies
    case genres


    var title: String? {
        switch self {
        case .trendingMovies: return "Trending Now"
        case .popularMovies: return "Popular"
        case .topRatedMovies: return "Top Rated"
        case .nowPlayingMovies: return "Now Playing"
        case .upcomingMovies: return "Coming Soon"
        case .genres: return "Browse by Genre"
        }
    }
}
