//
//  TMDbAPIError.swift
//  TMDb
//
//  Copyright © 2024 Adam Young.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an AS IS BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

///
/// A model representing a TMDb API error.
///
enum TMDbAPIError: LocalizedError {

    ///
    /// Network error.
    ///
    case network(Error)

    ///
    /// Bad request.
    ///
    case badRequest(String?)

    ///
    /// Unauthorised.
    ///
    case unauthorised(String?)

    ///
    /// Forbidden.
    ///
    case forbidden(String?)

    ///
    /// Not found.
    ///
    case notFound(String?)

    ///
    /// Method not allowed.
    ///
    case methodNotAllowed(String?)

    ///
    /// Not acceptable.
    ///
    case notAcceptable(String?)

    ///
    /// Unprocessable content.
    ///
    case unprocessableContent(String?)

    ///
    /// Too many requests.
    ///
    case tooManyRequests(String?)

    ///
    /// Internal server error.
    ///
    case internalServerError(String?)

    ///
    /// Not implemented.
    ///
    case notImplemented(String?)

    ///
    /// Bad gateway.
    ///
    case badGateway(String?)

    ///
    /// Service unavailable.
    ///
    case serviceUnavailable(String?)

    ///
    /// Gateway timeout.
    ///
    case gatewayTimeout(String?)

    ///
    /// Data encode error.
    ///
    case encode(Error)

    ///
    /// Data decode error.
    ///
    case decode(Error)

    ///
    /// Unknown error.
    ///
    case unknown

}

extension TMDbAPIError {
    var errorTitle: String {
        switch self {
        case .network:
            "No Internet connection."
        case .badRequest:
            "Bad Request"
        case .unauthorised:
            "Unauthorized"
        case .forbidden:
            "Forbidden"
        case .notFound:
            "Not found"
        case .methodNotAllowed:
            "Method not allowed"
        case .notAcceptable:
            "Not Acceptable"
        case .unprocessableContent:
            "Unprocessable Content"
        case .tooManyRequests:
            "Too Many Request"
        case .internalServerError:
            "Internal Server Error"
        case .notImplemented:
            "Not Implemented"
        case .badGateway:
            "Bad Gateway"
        case .serviceUnavailable:
            "Service Unavailable"
        case .gatewayTimeout:
            "Gateway Timeout"
        case .encode:
            "Encode Error"
        case .decode:
            "Decode Error"
        case .unknown:
            "Unknown"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .network(let error):
            error.localizedDescription
//        case .badRequest(let string):
//            string ?? "Something went wrong"
//        case .unauthorised(let string):
//            <#code#>
//        case .forbidden(let string):
//            <#code#>
//        case .notFound(let string):
//            string ?? "Something went wrong"
//        case .methodNotAllowed(let string):
//            <#code#>
//        case .notAcceptable(let string):
//            <#code#>
//        case .unprocessableContent(let string):
//            <#code#>
//        case .tooManyRequests(let string):
//            <#code#>
//        case .internalServerError(let string):
//            <#code#>
//        case .notImplemented(let string):
//            <#code#>
//        case .badGateway(let string):
//            <#code#>
//        case .serviceUnavailable(let string):
//            <#code#>
//        case .gatewayTimeout(let string):
//            <#code#>
        case .encode(let error):
            error.localizedDescription
        case .decode(let error):
            error.localizedDescription
//        case .unknown:
//            "Unknown"
        default: "Something went wrong"
        }
    }
}
