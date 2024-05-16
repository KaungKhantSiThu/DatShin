//
//  RequestManager.swift
//  Yote Shin
//
//  Created by Kaung Khant Si Thu on 09/04/2024.
//

import Foundation

protocol RequestManagerProtocol {
    func get<Response: Decodable>(endpoint: Endpoint) async throws -> Response
}

final class RequestManager: RequestManagerProtocol {
    let apiManager: APIManagerProtocol
    let parser: DataParserProtocol
    
    private let baseURL = URL.tmdbAPIBaseURL
    private let apiKey = APIConstants.apiKey
    private let localeProvider = LocaleProvider(locale: .current)
    
    init(
        apiManager: APIManagerProtocol = APIManager(),
        parser: DataParserProtocol = DataParser()
    ) {
        self.apiManager = apiManager
        self.parser = parser
    }
    
    func get<Response: Decodable>(endpoint: Endpoint) async throws -> Response {
        let url = urlFromPath(endpoint.path)
        let headers = [
            "Authorization": "Bearer \(APIConstants.accessTokenAuth)",
            "Accept": "application/json"
        ]
        
        let request = HTTPRequest(url: url, headers: headers)
        let responseObject: Response = try await perform(request: request)
        
        return responseObject
    }
}

extension RequestManager {
    
    private func perform<Response: Decodable>(request: HTTPRequest) async throws -> Response {
        let response: HTTPResponse
        
        do {
            response = try await apiManager.perform(request: request)
        } catch let error {
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
        
        throw TMDbAPIError(statusCode: statusCode, message: message)
    }
    
}

