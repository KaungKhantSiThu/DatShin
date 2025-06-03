//
//  APIManagerProtocol.swift
//  Yote Shin
//
//  Created by Kaung Khant Si Thu on 09/04/2024.
//

import Foundation
import Combine

protocol APIManagerProtocol {
    func perform(request: HTTPRequest) async throws -> HTTPResponse
    func performPublisher(request: HTTPRequest) -> AnyPublisher<HTTPResponse, Error>
}

class APIManager: APIManagerProtocol {
    private let urlSession: URLSession
    private let logger: rLoggerProtocol
    
    init(urlSession: URLSession = URLSession.shared, logger: LoggerProtocol = Logger.shared) {
        self.urlSession = urlSession
        self.logger = logger
    }
    
    func perform(request: HTTPRequest) async throws -> HTTPResponse {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        for header in request.headers {
            urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }

        logger.debug("Making request to: \(request.url.absoluteString)")
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await perform(urlRequest)
        } catch let error {
            logger.error("Network request failed: \(error.localizedDescription)")
            throw error
        }

        guard let httpURLResponse = response as? HTTPURLResponse else {
            logger.error("Invalid response type")
            return HTTPResponse(statusCode: -1, data: nil)
        }

        let statusCode = httpURLResponse.statusCode
        logger.debug("Received response with status code: \(statusCode)")
        
        return HTTPResponse(statusCode: statusCode, data: data)
    }
    
    func performPublisher(request: HTTPRequest) -> AnyPublisher<HTTPResponse, Error> {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        for header in request.headers {
            urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        logger.debug("Making publisher request to: \(request.url.absoluteString)")
        
        return urlSession.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                self.logger.debug("Received publisher response with status code: \(httpResponse.statusCode)")
                
                return HTTPResponse(statusCode: httpResponse.statusCode, data: data)
            }
            .eraseToAnyPublisher()
    }
    
    private func perform(_ urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        try await urlSession.data(for: urlRequest)
    }
}
