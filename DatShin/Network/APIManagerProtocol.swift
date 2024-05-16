//
//  APIManagerProtocol.swift
//  Yote Shin
//
//  Created by Kaung Khant Si Thu on 09/04/2024.
//

import Foundation


protocol APIManagerProtocol {
    func perform(request: HTTPRequest) async throws -> HTTPResponse
}

class APIManager: APIManagerProtocol {
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func perform(request: HTTPRequest) async throws -> HTTPResponse {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        for header in request.headers {
            urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }

        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await perform(urlRequest)
        } catch let error {
            throw error
        }

        guard let httpURLResponse = response as? HTTPURLResponse else {
            return HTTPResponse(statusCode: -1, data: nil)
        }

        let statusCode = httpURLResponse.statusCode
        return HTTPResponse(statusCode: statusCode, data: data)
    }
    
    private func perform(_ urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        try await urlSession.data(for: urlRequest)
    }
}
