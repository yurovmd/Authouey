
import Foundation

final class AuthenticationEndpoint: NetworkEndpointAbstraction {

    var baseURL: URL? {
        let defaults = UserDefaults.standard
        let state = defaults.bool(forKey: "isProd_preference")
        return URL(string: state
            ? NetworkEnvironmentType.prod.rawValue
            : NetworkEnvironmentType.dev.rawValue)
    }

    var path: String? {
        get {
            return "user/auth/"
        }
        set {
            
        }
    }

    var methodName: String? {
        return nil
    }

    var httpMethod: HTTPMethod {
        return HTTPMethod.post
    }

    var headers: [String: String]? {
        return nil
    }

    var bodyParameters: [String: Any]?

    var bodyData: Data? {
        return nil
    }

    var urlParameters: [String: String]?
}
