// NetworkError.swift

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error?)
    case noData
    case decodingError(Error?)
    case apiError(statusCode: Int, message: String?)
    case unknown
}
