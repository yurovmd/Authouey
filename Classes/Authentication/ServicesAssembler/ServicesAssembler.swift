
import Foundation

final class ServicesAssembler {

  // MARK: - Assembling screen service

  static func instanceFor(_ screen: ScreenType) -> ScreenDataProviderProtocol? {

    let routerForScreen = NetworkRouter()
    let routerForAuth = NetworkRouter()
    let keychainService = KeychainManagerService()
    let screenEndpoint: NetworkEndpointAbstraction
    let networkServiceForAuth = NetworkManager(router: routerForAuth,
                                               endpoint: nil)
    let storageService = StorageService()

    switch screen {
    case .authorization:
      screenEndpoint = AuthenticationEndpoint()
      let authenticationService = AuthenticationService(networkService: networkServiceForAuth,
                                                        login: nil,
                                                        password: nil)
      networkServiceForAuth.delegate = authenticationService
      return authenticationService
    }
    do {
      let login = try keychainService.getLogin()
      let password = try keychainService.getPassword()
      let networkServiceForScreen = NetworkManager(router: routerForScreen,
                                                   endpoint: screenEndpoint)
      let authenticationService = AuthenticationService(networkService: networkServiceForAuth,
                                                        login: login,
                                                        password: password)
      let screenService = BaseScreenService(networkService: networkServiceForScreen,
                                            authenticationService: authenticationService,
                                            storageService: storageService)
      return screenService
    } catch {
      return nil
    }
  }

}
