//
//  FluxController+Mapping.swift
//  Flux
//
//  Created by Telem Tobi on 19/12/2024.
//

import Foundation

public typealias DecodableJson = Decodable & JsonMapper

extension FluxController {
    // MARK: Json mapping API
    
    /// Performs a network request using the provided `Endpoint`.
    ///
    /// - Parameter endpoint: The `Endpoint` object defining the API endpoint and request parameters.
    /// - Throws: An error of type `F` if the request fails due to an issue like authentication, connection, or decoding errors.
    /// - Returns: The decoded response model of type `T`.
    public func request<T: DecodableJson>(_ endpoint: E) async throws(F) -> T {
        #if DEBUG
        guard environment == .live, !endpoint.shouldUseSampleData else {
            return try await makeMockRequest(endpoint)
        }
        #endif
        
        switch authenticator?.state ?? .reachable {
        case .notReachable:
            throw(.connectionError)
        case .notLoggedIn:
            throw(.authenticationError)
        case .reachable:
            break
        }
        
        do {
            if try await authenticator?.authenticate() == false {
                throw(F.authenticationError)
            }
        } catch {
            throw(.connectionError)
        }
        
        return try await makeRequest(endpoint)
    }
    
    /// Performs a network request using the provided `Endpoint`.
    ///
    /// - Parameter endpoint: The `Endpoint` object defining the API endpoint and request parameters.
    /// - Returns: An asynchronous result of type `Result<T, F>`.
    ///     On success, the result contains the decoded model of type `T`. On failure, it contains an error of type `F` describing the issue.
    public func request<T: DecodableJson>(_ endpoint: E) async -> Result<T, F> {
        do {
            let result: T = try await request(endpoint)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    /// Performs a network request using the provided `Endpoint` and calls a completion handler with the result.
    ///
    /// - Parameters:
    ///   - endpoint: The `Endpoint` object defining the API endpoint and request parameters.
    ///   - completion: A closure that will be called asynchronously with the result of the network request.
    ///   The closure takes a single argument of type `Result<T, F>`.
    ///   On success, the result contains the decoded model of type `T`. On failure, it contains an error of type `F` describing the issue.
    public func request<T: DecodableJson>(_ endpoint: E, completion: @escaping (Result<T, F>) -> Void) {
        Task {
            do {
                let result: T = try await request(endpoint)
                completion(.success(result))
            } catch {
                let error = error as? F ?? .unknownError()
                completion(.failure(error))
            }
        }
    }
    
    private func makeRequest<T: DecodableJson>(_ endpoint: Endpoint) async throws(F) -> T {
        do {
            var urlRequest = try URLRequest(endpoint)
            
            authenticator?.mapRequest(&urlRequest)
            
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            #if DEBUG
            if endpoint.shouldPrintLogs {
               logRequest(endpoint, urlRequest, response, data)
            }
            #endif
            
            guard response.status.group == .success else {
                throw(decodedError(endpoint, data))
            }
            
            let model = try T
                .map(data)
                .decode(
                    into: T.self,
                    using: endpoint.dateDecodingStrategy, endpoint.keyDecodingStrategy
                )
            return model
            
        } catch {
            throw(F.init(error.asFluxError))
        }
    }
    
    #if DEBUG
    private func makeMockRequest<T: DecodableJson>(_ endpoint: Endpoint) async throws(F) -> T {
        do {
            if environment == .preview {
                try await Task.sleep(interval: Flux.Stub.delayInterval)
            }
            
            let model = try T
                .map(endpoint.sampleData ?? Data())
                .decode(
                    into: T.self,
                    using: endpoint.dateDecodingStrategy, endpoint.keyDecodingStrategy
                )
            return model
            
        } catch {
            throw(F.init(error.asFluxError))
        }
    }
    #endif
}
