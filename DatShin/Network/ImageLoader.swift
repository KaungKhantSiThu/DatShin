//
//  TMDbImageLoader.swift
//  Yote Shin
//
//  Created by Kaung Khant Si Thu on 16/04/2024.
//

import UIKit

class ImageLoader {
    
    enum ImageType {
        case backdrop, profile, poster, still,logo
    }
    
    private let imagesConfiguration: ImagesConfiguration
    
    let cache = NSCache<NSString, UIImage>()
    
    static let shared = ImageLoader()
    
    private init() {
        imagesConfiguration = ImagesConfiguration(
            baseURL: URL(string: "http://image.tmdb.org/t/p/")!,
            secureBaseURL: URL(string: "https://image.tmdb.org/t/p/")!,
            backdropSizes: ["w300", "w780", "w1280", "original"],
            logoSizes: ["w45", "w92", "w154", "w185", "w300", "w500", "original"],
            posterSizes: ["w92", "w154", "w185", "w342", "w500", "w780", "original"],
            profileSizes: ["w45", "w185", "h632", "original"],
            stillSizes: ["w92", "w185", "w300", "original"]
        )
    }
    
    private func backdropURL(for path: URL?, idealWidth width: Int = Int.max) -> URL? {
        return imagesConfiguration.backdropURL(for: path, idealWidth: width)
    }
    
    private func profileURL(for path: URL?, idealWidth width: Int = Int.max) -> URL? {
        return imagesConfiguration.profileURL(for: path, idealWidth: width)
    }
    
    private func posterURL(for path: URL?, idealWidth width: Int = Int.max) -> URL? {
        return imagesConfiguration.posterURL(for: path, idealWidth: width)
    }
    
    private func stillURL(for path: URL?, idealWidth width: Int = Int.max) -> URL? {
        return imagesConfiguration.stillURL(for: path, idealWidth: width)
    }
    
    private func logoURL(for path: URL?, idealWidth width: Int = Int.max) -> URL? {
        return imagesConfiguration.logoURL(for: path, idealWidth: width)
    }
    
    func generateFullURL(from url: URL?, as type: ImageType, idealWidth width: Int = Int.max) -> URL {
        let fullURL: URL?
        
        switch type {
        case .backdrop:
            fullURL = backdropURL(for: url, idealWidth: width)
        case .profile:
            fullURL = profileURL(for: url, idealWidth: width)
        case .poster:
            fullURL = posterURL(for: url, idealWidth: width)
        case .still:
            fullURL = stillURL(for: url, idealWidth: width)
        case .logo:
            fullURL = logoURL(for: url, idealWidth: width)
        }
        
        return fullURL ?? URL(string: "https://cloud.githubusercontent.com/assets/1567433/9781817/ecb16e82-57a0-11e5-9b43-6b4f52659997.jpg")!
    }
    
    func downloadImage(from url: URL?, as type: ImageType, completed: @escaping (UIImage?) -> Void) {
        let fullURL: URL!
        
        switch type {
        case .backdrop:
            fullURL = backdropURL(for: url)
        case .profile:
            fullURL = profileURL(for: url)
        case .poster:
            fullURL = posterURL(for: url)
        case .still:
            fullURL = stillURL(for: url)
        case .logo:
            fullURL = logoURL(for: url)
        }
        
        
        let cacheKey = NSString(string: fullURL.absoluteString)
        
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }
        
        guard let url = fullURL else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  error == nil,
                  let response = response as? HTTPURLResponse, response.statusCode == 200,
                  let data = data,
                  let image = UIImage(data: data) else {
                completed(nil)
                return
            }
            
            self.cache.setObject(image, forKey: cacheKey)
            completed(image)
        }
        
        task.resume()
    }
}
