import Foundation

enum Config {
    
    enum Key: String {
        case tmdbBaseUrl
        case tmdbAccessToken
    }
    
    static func value<T>(for key: Key) -> T? {
        let value = Bundle.main.object(forInfoDictionaryKey: key.rawValue)
        
        switch T.self {
        case is String.Type: return value as? T
        case is Bool.Type: return (value as? String)?.boolValue as? T
        default: return nil
        }
    }
    
    enum TmdbApi {
        static var baseUrl: String {
            value(for: .tmdbBaseUrl) ?? ""
        }
        
        static var accessToken: String {
            value(for: .tmdbAccessToken) ?? ""
        }
        
        static var accountIdPlaceholder: String { #function }
    }
}
