
import Foundation

final class NetworkRouter {

  // MARK: - Properties

}

// MARK: - NetworkRouterProvider

extension NetworkRouter: NetworkRouterProvider {

  func requestWith(endpoint: NetworkEndpointAbstraction,
                   authToken: String?,
                   completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
    let session = URLSession.shared
    do {
      let request = try buildRequestWith(endpoint: endpoint,
                                         authToken: authToken)
      let task = session.dataTask(with: request, completionHandler: completion)
      task.resume()
    } catch (let error) {
      completion(nil, nil, error)
      return
    }
  }

  func downloadDataFor(urlString: String,
                       completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
    let session = URLSession.shared
    guard let url = URL(string: urlString) else {
      return
    }
    let task = session.dataTask(with: url, completionHandler: completion)
    task.resume()
  }

  private func buildRequestWith(endpoint: NetworkEndpointAbstraction,
                                authToken: String?) throws -> URLRequest {
    guard let baseUrl = endpoint.baseURL else {
      throw NetworkLayerError.cantBuildURLForRequest
    }

    let url = baseUrl.appendingPathComponent(endpoint.path ?? "")

    var request = URLRequest.init(url: url,
                                  cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
                                  timeoutInterval: 10.0)

    request.httpMethod = endpoint.httpMethod.rawValue

    // Configuring Url Parameters

    if let parameters = endpoint.urlParameters,
      let methodName = endpoint.methodName {
      configure(request: &request,
                withMethodName: methodName,
                withURLparameters: parameters)
    }

    // Configuring Body Parameters

    if let parameters = endpoint.bodyParameters {
      configure(request: &request,
                withBodyparameters: parameters)
    } else if endpoint.bodyData != nil {
      // TODO: -
    } else {

    }

    // Configure headers

    if let token = authToken {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    //        print(request.url)
    //        print(request.httpMethod)
    //        print(request.value(forHTTPHeaderField: "Authorization"))
    //        print(request.value(forHTTPHeaderField: "Content-Type"))
    //        print("\n")
    return request
  }

  private func configure(request: inout URLRequest,
                         withBodyparameters parameters: [String: Any]) {
    let params = parameters as? [String: [String: String]]
    request.httpBody = try? JSONEncoder().encode(params)
    if request.value(forHTTPHeaderField: "Content-Type") == nil {
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
  }

  private func configure(request: inout URLRequest,
                         withMethodName methodName: String,
                         withURLparameters parameters: [String: String]) {
    guard var url = request.url else { return }

    if parameters.isEmpty {
      url = url.appendingPathComponent("/\(methodName)")
      request.url = url
      return
    }

    var mutableParameters = parameters

    // If have project Id in parameters, we need to construct url in special way
    for (key, value) in mutableParameters {
      if key == "projectId" {
        url = url.appendingPathComponent("projects/\(value)/\(methodName)")
        mutableParameters.removeValue(forKey: "projectId")
      }
    }

    // if have object Id, need to append it to the tail of url
    for (key, value) in mutableParameters {
      if key == "objectIdAfterMethodName" {
        url = url.appendingPathComponent("/\(methodName)/\(value)")
        mutableParameters.removeValue(forKey: "objectIdAfterMethodName")
      } else if key == "objectIdBeforeMethodName" {
        url = url.appendingPathComponent("/\(value)/\(methodName)")
        mutableParameters.removeValue(forKey: "objectIdBeforeMethodName")
      }
    }

    if var urlComponents = URLComponents(url: url,
                                         resolvingAgainstBaseURL: false), !mutableParameters.isEmpty {
      urlComponents.queryItems = [URLQueryItem]()
      for (key,value) in mutableParameters {
        let queryItem = URLQueryItem(name: key,
                                     value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
        urlComponents.queryItems?.append(queryItem)
      }
      request.url = urlComponents.url
    } else {
      request.url = url
    }
    if request.value(forHTTPHeaderField: "Content-Type") == nil {
      request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
    }
  }
}
