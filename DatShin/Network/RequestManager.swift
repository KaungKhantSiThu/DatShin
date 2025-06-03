//
//  RequestManager.swift
//  Yote Shin
//
//  Created by Kaung Khant Si Thu on 09/04/2024.
//

import Foundation
import Combine

protocol RequestManagerProtocol {
    func get<Response: Decodable>(endpoint: Endpoint) async throws -> Response
    func getPublisher<Response: Decodable>(endpoint: Endpoint) -> AnyPublisher<Response, Error>
}

final class RequestManager: RequestManagerProtocol {
    let apiManager: APIManagerProtocol
    let parser: DataParserProtocol
    private let cacheManager: CacheManagerProtocol
    private let logger: LoggerProtocol
    
    private let baseURL = URL.tmdbAPIBaseURL
    private let apiKey = APIConstants.apiKey
    private let localeProvider = LocaleProvider(locale: .current)
    
    init(
        apiManager: APIManagerProtocol = APIManager(),
        parser: DataParserProtocol = DataParser(),
        cacheManager: CacheManagerProtocol = try! CacheManager(),
        logger: LoggerProtocol = Logger.shared
    ) {
        self.apiManager = apiManager
        self.parser = parser
        self.cacheManager = cacheManager
        self.logger = logger
    }
    
    func get<Response: Decodable>(endpoint: Endpoint) async throws -> Response {
        // Check cache first
        if let cachedResponse: Response = try? cacheManager.get(forKey: endpoint.path.absoluteString) {
            logger.debug("Cache hit for endpoint: \(endpoint.path.absoluteString)")
            return cachedResponse
        }
        
        let url = urlFromPath(endpoint.path)
        let headers = [
            "Authorization": "Bearer \(APIConstants.accessTokenAuth)",
            "Accept": "application/json"
        ]
        
        let request = HTTPRequest(url: url, headers: headers)
        let responseObject: Response = try await perform(request: request)
        
        // Cache the response
        try? cacheManager.set(responseObject, forKey: endpoint.path.absoluteString, expiration: 3600) // 1 hour cache
        
        return responseObject
    }
    
    func getPublisher<Response: Decodable>(endpoint: Endpoint) -> AnyPublisher<Response, Error> {
        // Check cache first
        if let cachedResponse: Response = try? cacheManager.get(forKey: endpoint.path.absoluteString) {
            logger.debug("Cache hit for endpoint: \(endpoint.path.absoluteString)")
            return Just(cachedResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let url = urlFromPath(endpoint.path)
        let headers = [
            "Authorization": "Bearer \(APIConstants.accessTokenAuth)",
            "Accept": "application/json"
        ]
        
        let request = HTTPRequest(url: url, headers: headers)
        
        return apiManager.performPublisher(request: request)
            .tryMap { response in
                try self.validate(response: response)
                guard let data = response.data else {
                    throw TMDbAPIError.unknown
                }
                return try self.parser.decode(Response.self, from: data)
            }
            .handleEvents(receiveOutput: { [weak self] response in
                // Cache the response
                try? self?.cacheManager.set(response, forKey: endpoint.path.absoluteString, expiration: 3600)
            })
            .eraseToAnyPublisher()
    }
}

extension RequestManager {
    private func perform<Response: Decodable>(request: HTTPRequest) async throws -> Response {
        let response: HTTPResponse
        
        do {
            response = try await apiManager.perform(request: request)
        } catch let error {
            logger.error("Network request failed: \(error.localizedDescription)")
            throw TMDbAPIError.network(error)
        }
        
        let decodedResponse: Response = try await decodeResponse(response: response)
        return decodedResponse
    }
    
    private func urlFromPath(_ path: URL) -> URL {
        guard var urlComponents = URLComponents(url: path, resolvingAgainstBaseURL: true) else {
            return path
        }
        
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.path = "\(baseURL.path)\(urlComponents.path)"
        
        return urlComponents.url!
            .appendingAPIKey(apiKey)
            .appendingLanguage(localeProvider.languageCode)
    }
    
    private func decodeResponse<Response: Decodable>(response: HTTPResponse) async throws -> Response {
        try await validate(response: response)
        
        guard let data = response.data else {
            throw TMDbAPIError.unknown
        }
        
        let decodedResponse: Response
        do {
            decodedResponse = try await parser.decode(Response.self, from: data)
        } catch let error {
            logger.error("Decoding failed: \(error.localizedDescription)")
            throw TMDbAPIError.decode(error)
        }
        
        return decodedResponse
    }
    
    private func validate(response: HTTPResponse) async throws {
        let statusCode = response.statusCode
        if (200 ... 299).contains(statusCode) {
            return
        }
        
        guard let data = response.data else {
            throw TMDbAPIError(statusCode: statusCode, message: nil)
        }
        
        let statusResponse = try? await parser.decode(TMDbStatusResponse.self, from: data)
        let message = statusResponse?.statusMessage
        
        logger.error("API error: \(message ?? "Unknown error") with status code: \(statusCode)")
        throw TMDbAPIError(statusCode: statusCode, message: message)
    }
}

