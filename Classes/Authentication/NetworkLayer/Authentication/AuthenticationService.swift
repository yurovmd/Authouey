
import Foundation

final class AuthenticationService {
  
  // MARK: - Properties
  
  private let networkService: NetworkManagerProvider
  private let keychainService = KeychainManagerService()
  private var login: String?
  private var password: String?
  private var completion: ((String?, Error?) -> Void)?
  
  // MARK: - Initializer
  
  init(networkService: NetworkManagerProvider,
       login: String?,
       password: String?) {
    self.login = login
    self.password = password
    self.networkService = networkService
  }
  
}

// MARK: - AuthenticationServiceProvider

extension AuthenticationService: AuthenticationServiceProvider {
  
  private func authenticate(completion: @escaping (String?, Error?) -> Void) {
    guard let login = login,
      let password = password else {
      return
    }

    let endpoint = AuthenticationEndpoint()

    var parameters = [String: Any]()
    var parametersData = [String: String]()
    parametersData["Login"] = login
    parametersData["Password"] = password
    parameters["Data"] = parametersData
    endpoint.bodyParameters = parameters
    networkService.set(endpoint: endpoint)

    let networkServiceCompletion: (Any?, Error?) -> Void = { [weak self] data, error in

      guard error == nil else {
        completion(nil, error)
        return
      }
      guard let dataModel = data as? [String: Any],
        let responseData = dataModel["ResponseData"] as? [String: Any],
        let token = responseData["Token"] as? String else {
          completion(nil, NetworkLayerError.returnedDataUnexpectedType)
          return
      }
      self?.saveToken(token: token, lifeTime: 86400)
      if let userAvatarLink = dataModel["userAvatarLink"] as? String {
        let defaults = UserDefaults.standard
        defaults.set(userAvatarLink, forKey: "userAvatarLink")
      }
      completion(token, nil)
    }

    networkService.getDataForEndpointWith(parameters: nil,
                                          parametersType: nil,
                                          authToken: nil,
                                          completion: networkServiceCompletion)
  }
  
  func getToken(completion: @escaping (String?, Error?) -> Void) {
    if let savedToken = getSavedToken() {
      completion(savedToken, nil)
      return
    } else {
      authenticate(completion: completion)
    }
  }
  
  private func getSavedToken() -> String? {
    do {
      return try keychainService.getToken()
    } catch {
      return nil
    }
  }
  
  private func saveToken(token: String,
                         lifeTime: Double) {
    do {
      try keychainService.set(token: token, lifeTime: lifeTime)
      try keychainService.set(login: login ?? "")
      try keychainService.set(password: password ?? "")
      return
    } catch {
      return
    }
  }
}

// MARK: - ScreenDataProviderProtocol

extension AuthenticationService: ScreenDataProviderProtocol {

  func getDataFromEndpointWith(parameters: [String : Any]?,
                               parametersType: ParametersType?,
                               completion: @escaping (Any?, Error?) -> Void) {
    login = parameters?["login"] as? String
    password = parameters?["password"] as? String
    self.completion = completion
    authenticate(completion: completion)
  }

  func getDataFromUrl(_ urlString: String,
                      completion: @escaping (Any?, Error?) -> Void) {
    
  }


}

// MARK: - NetworkManagerDelegate

extension AuthenticationService: NetworkManagerDelegate {

  func authorizationFailResponceRecieved() {
    completion?(nil, NetworkResponseError.needToBeAuthenticated)
  }

  func saveToCache(imageLink: String, imageData: Data) {

  }

}
