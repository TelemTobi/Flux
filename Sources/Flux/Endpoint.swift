import Foundation

/// Defines the specifications required to construct a `URLRequest`.
public protocol Endpoint {

    /// The base URL for the API endpoint.
    ///
    /// This URL should be the root of the API you're interacting with.
    var baseURL: URL { get }

    /// The path component to be appended to the `baseURL` to form the complete URL.
    ///
    /// This string represents the specific resource you're targeting within the API.
    var path: String { get }

    /// The HTTP method for the network request.
    ///
    /// This value specifies the type of operation you want to perform (e.g., GET, POST, PUT).
    var method: HTTPMethod { get }

    /// The configuration for the HTTP request body and query parameters.
    ///
    /// This specifies how the request data should be encoded and included in the request.
    var task: HTTPTask { get }

    /// The headers to be included in the network request.
    ///
    /// This dictionary allows you to specify custom headers for authentication, content type, etc.
    /// (Default: `nil`)
    var headers: [String: String]? { get }

    /// The strategy used by `JSONDecoder` for decoding JSON response keys.
    ///
    /// This property allows you to customize how JSON keys are mapped to your model properties.
    ///
    /// (Default: `.useDefaultKeys`)
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }

    /// The strategy used by `JSONDecoder` for decoding dates from the JSON response.
    ///
    /// This property allows you to specify how date strings are parsed into your model objects.
    /// 
    /// (Default: `.iso8601`)
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }

    /// Optional stub data used for testing purposes.
    ///
    /// This property allows you to provide pre-defined data to simulate a network response in tests.
    var sampleData: Data? { get }
    
    /// A Boolean value indicating whether request and response details should be printed to the console.
    ///
    /// When set to `true` (default), Flux will log the following information upon receiving a response:
    ///  * Request URL
    ///  * HTTP Method
    ///  * Request Headers
    ///  * Request Body (if applicable)
    ///  * Status Code
    ///  * Response Headers
    ///  * Response Body (formatted JSON)
    ///
    /// You can use this property to control logging verbosity for specific endpoints.
    var shouldPrintLogs: Bool { get }
}

// Default implementations for optional properties
extension Endpoint {

    var headers: [String: String]? { nil }

    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { .useDefaultKeys }

    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { .iso8601 }

    var sampleData: Data? { nil }
    
    var shouldPrintLogs: Bool { true }
}
