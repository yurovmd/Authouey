
import Foundation

protocol NetworkEndpointAbstraction {

  // MARK: - Properties

  var baseURL: URL? { get }
  var path: String? { get set }
  var methodName: String? { get }
  var httpMethod: HTTPMethod { get }
  var headers: [String: String]? { get }
  var bodyParameters: [String: Any]? { get set }
  var bodyData: Data? { get }
  var urlParameters: [String: String]? { get set }

}

extension NetworkEndpointAbstraction {

  mutating func setBodyParameters(_ parameters: [String: Any]) {
    bodyParameters = parameters as? [String: String]
  }

  mutating func setUrlParameters(_ parameters: [String: Any]) {
     urlParameters = parameters as? [String: String]
  }

}
