
import Foundation

final class AuthorizationScreenViewModel {

  typealias Dependencies = (ScreenDataProviderProtocol)
  // MARK: - Properties

  var onDataDidChangeClosure: (() -> Void)?
  var startAnimatingClosure: (() -> Void)?
  var stopAnimatingClosure: (() -> Void)?
  var credentialsAreWrong: Bool = false
  var loginSuccessful: Bool = false
  private let service: ScreenDataProviderProtocol
  private var currentLogin: String?
  private var currentPassword: String?
  
  // MARK: - Initializer

  init(dependencies: Dependencies) {
    service = dependencies
  }
}

// MARK: - Signals From View

extension AuthorizationScreenViewModel {

  func loginTextChanged(string: String?) {
    credentialsAreWrong = false
    currentLogin = string
    onDataDidChangeClosure?()
  }

  func passwordTextChanged(string: String?) {
    credentialsAreWrong = false
    currentPassword = string
    onDataDidChangeClosure?()
  }

  func tryToLogin() {
    guard fieldsAreOk() else {
      credentialsAreWrong = true
      onDataDidChangeClosure?()
      return
    }
    startAnimatingClosure?()
    let completion: (Any?, Error?) -> Void = { [weak self] data, error in
      guard let self = self else { return }
      self.stopAnimatingClosure?()
      guard error == nil else {
        self.credentialsAreWrong = true
        self.onDataDidChangeClosure?()
        return
      }
      self.loginSuccessful = true
      self.onDataDidChangeClosure?()
    }
    var parameters = [String: Any]()
    parameters["login"] = currentLogin
    parameters["password"] = currentPassword
    service.getDataFromEndpointWith(parameters: parameters,
                                    parametersType: .body,
                                    completion: completion)
  }
}

// MARK: - Utility Methods

extension AuthorizationScreenViewModel {

  private func fieldsAreOk() -> Bool {
    guard !(currentLogin?.isEmpty ?? true),
      !(currentPassword?.isEmpty ?? true) else {
        return false
    }
    return true
  }
}
