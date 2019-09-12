
import Foundation

final class NetworkManager {
  
  // MARK: - Properties
  
  private var endpoint: NetworkEndpointAbstraction?
  private var router: NetworkRouterProvider
  var delegate: NetworkManagerDelegate?
  var authToken: String?
  
  // MARK: - Initializers
  
  init(router: NetworkRouterProvider,
       endpoint: NetworkEndpointAbstraction?) {
    self.router = router
    self.endpoint = endpoint
  }
  
}

// MARK: - Endpoint Setup

extension NetworkManager {
  
  private func handleNetworkResponse(response: HTTPURLResponse) -> NetworkResponseError? {
    switch (response.statusCode) {
    case 200 ... 299:
      return nil
    case 401 ... 500:
      return NetworkResponseError.needToBeAuthenticated
    case 501 ... 599:
      return NetworkResponseError.badRequest
    case 600:
      return NetworkResponseError.urlOutdated
    default:
      return NetworkResponseError.networkRequestFailed
    }
  }
  
}

// MARK: - Network Manager Provider

extension NetworkManager: NetworkManagerProvider {
  
  func getDataForEndpointWith(parameters: [String: Any]?,
                              parametersType: ParametersType?,
                              authToken: String?,
                              completion: @escaping (Any?, Error?) -> Void) {
    self.authToken = authToken
    guard var endpoint = endpoint else { return }
    if let parameters = parameters,
      let parametersType = parametersType {
      switch parametersType {
      case .body:
        endpoint.setBodyParameters(parameters)
      case .url:
        endpoint.setUrlParameters(parameters)
      }
    }
    let requestCompletion: (Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
      DispatchQueue.main.async { [weak self] in
        if (error != nil) {
          completion(nil, NetworkLayerError.networkConnectionError)
          return
        }
        guard let responseResult = response as? HTTPURLResponse else {
          completion(nil, NetworkLayerError.unknownTypeOfResponse)
          return
        }
        if let status = self?.handleNetworkResponse(response: responseResult) {
          if status == NetworkResponseError.needToBeAuthenticated {
            self?.delegate?.authorizationFailResponceRecieved()
            return
          }
          completion(nil, status)
          return
        }
        guard let dataUnwrapped = data else {
          completion(nil, NetworkLayerError.noDataToDecode)
          return
        }
        do {
          let apiResponse = try JSONSerialization.jsonObject(with: dataUnwrapped,
                                                             options: [])
          if let apiResponseArray = apiResponse as? [[String: Any]] {
            completion(apiResponseArray, nil)
          } else if let apiResponseDict = apiResponse as? [String: Any] {
            completion(apiResponseDict, nil)
          } else {
            throw NetworkLayerError.dataDecodingProblem
          }
          return
          
        } catch (let error) {
          completion(nil, error)
          return
        }
      }
      
    }
    router.requestWith(endpoint: endpoint,
                       authToken: authToken,
                       completion: requestCompletion)
  }
  
  func getDataFromUrl(_ urlString: String,
                      completion: @escaping (Any?, Error?) -> Void) {
    let requestCompletion: (Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
      DispatchQueue.main.async { [weak self] in
        if (error != nil) {
          completion(nil, NetworkLayerError.networkConnectionError)
          return
        }
        guard let responseResult = response as? HTTPURLResponse else {
          completion(nil, NetworkLayerError.unknownTypeOfResponse)
          return
        }
        if let status = self?.handleNetworkResponse(response: responseResult) {
          completion(nil, status)
          return
        }
        guard let dataUnwrapped = data else {
          completion(nil, NetworkLayerError.noDataToDecode)
          return
        }
        // Again, not the best decision, because we just assume that
        // Here will be the image data
        self?.delegate?.saveToCache(imageLink: urlString, imageData: dataUnwrapped)
        completion(dataUnwrapped, nil)
      }
    }
    router.downloadDataFor(urlString: urlString, completion: requestCompletion)
  }
  
  func set(endpoint: NetworkEndpointAbstraction) {
    self.endpoint = endpoint
  }
  
}
