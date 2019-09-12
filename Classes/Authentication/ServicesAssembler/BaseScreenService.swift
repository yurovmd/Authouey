
import Foundation

class BaseScreenService {

  // MARK: - Properties

  private var networkService: NetworkManagerProvider
  private let authenticationService: AuthenticationServiceProvider
  private let storageService: StorageProvider
  private let queue = DispatchQueue.global(qos: .utility)

  // Store auth completion and parameters for future use if token changed on server unexpectedly
  private var serviceCompletion: ((Any?, Error?) -> Void)?
  private var serviceParameters: [String: Any]?

  // MARK: - Initializer

  init(networkService: NetworkManagerProvider,
       authenticationService: AuthenticationServiceProvider,
       storageService: StorageProvider) {
    self.networkService = networkService
    self.authenticationService = authenticationService
    self.storageService = storageService
    self.networkService.delegate = self
  }

}

// MARK: - BaseService

extension BaseScreenService: ScreenDataProviderProtocol {

  func getDataFromEndpointWith(parameters: [String: Any]?,
                               parametersType: ParametersType?,
                               completion: @escaping (Any?, Error?) -> Void) {

    serviceCompletion = completion
    serviceParameters = parameters
    let authenticationCompletion: (String?, Error?) -> Void = { [weak self] (token, error) in
      guard error == nil else {
        completion(nil, error)
        return
      }
      guard let authToken = token else {
        completion(nil, NetworkLayerError.toknIsNil)
        return
      }
      self?.networkService.getDataForEndpointWith(parameters: parameters,
                                                  parametersType: parametersType,
                                                  authToken: authToken,
                                                  completion: completion)
    }
    queue.async { [weak self] in
      self?.authenticationService.getToken(completion: authenticationCompletion)
    }
  }

  func getDataFromUrl(_ urlString: String,
                      completion: @escaping (Any?, Error?) -> Void) {
    // Here we assume that url, that user provide is an image url.
    // That's because our app do not download anything but images using this
    // method for now, 01.08.2019
    // That's horrible, really need to add some assert later.
    if let imageDataPath = storageService.getImagePath(for: urlString),
      let urlOfLocalImage = URL(string: imageDataPath),
      let imageData = try? Data(contentsOf: urlOfLocalImage) {
      completion(imageData, nil)
      return
    }
    queue.async { [weak self] in
      self?.networkService.getDataFromUrl(urlString,
                                          completion: completion)
    }
  }
}

// MARK: - NetworkManagerDelegate

extension BaseScreenService: NetworkManagerDelegate {

  func authorizationFailResponceRecieved() {

    // If we receive 401 error (Unauthorized), we just need to authorize again
    let authenticationCompletion: (String?, Error?) -> Void = { [weak self] (token, error) in
      guard let self = self,
        let params = self.serviceParameters,
        let completion = self.serviceCompletion else { return }
      guard error == nil else {
        completion(nil, error)
        return
      }
      guard let authToken = token else {
        completion(nil, NetworkLayerError.toknIsNil)
        return
      }
      self.networkService.getDataForEndpointWith(parameters: params,
                                                 parametersType: .url,
                                                 authToken: authToken,
                                                 completion: completion)
    }
    queue.async { [weak self] in
      self?.authenticationService.getToken(completion: authenticationCompletion)
    }
  }

  func saveToCache(imageLink: String, imageData: Data) {
    // If image not stored, that's no problem
    // we will just download it next time
    // nothing to worry about, right?
    try? storageService.save(image: imageData, withUrl: imageLink)
  }

}
