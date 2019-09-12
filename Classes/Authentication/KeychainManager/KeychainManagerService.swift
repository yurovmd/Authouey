
import Foundation

final class KeychainManagerService {

}

// MARK: - KeychainManagerProtocol

extension KeychainManagerService: KeychainManagerProtocol {

  func getLogin() throws -> String {
    let defaults = UserDefaults.standard
    let state = defaults.bool(forKey: "isProd_preference")
    if state {
      guard let login = KeychainWrapper.standard.string(forKey: "login_prod") else {
        throw KeychainManagerError.errorGettingLogin
      }
      return login
    } else {
      guard let login = KeychainWrapper.standard.string(forKey: "login_dev") else {
        throw KeychainManagerError.errorGettingLogin
      }
      return login
    }
  }

  func getPassword() throws -> String {
    let defaults = UserDefaults.standard
    let state = defaults.bool(forKey: "isProd_preference")
    if state {
      guard let password = KeychainWrapper.standard.string(forKey: "password_prod") else {
        throw KeychainManagerError.errorGettingPassword
      }
      return password
    } else {
      guard let password = KeychainWrapper.standard.string(forKey: "password_dev") else {
        throw KeychainManagerError.errorGettingPassword
      }
      return password
    }
  }

  func getToken() throws -> String {
    let defaults = UserDefaults.standard
    let state = defaults.bool(forKey: "isProd_preference")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    if state {
      guard let token = KeychainWrapper.standard.string(forKey: "token_prod"),
        !token.isEmpty,
        let lifeTime = KeychainWrapper.standard.double(forKey: "token_lifetime_prod"),
        let tokenSavedDateString = KeychainWrapper.standard.string(forKey: "token_saved_date_prod"),
        let tokenSavedDate = dateFormatter.date(from: tokenSavedDateString),
        (-(tokenSavedDate.timeIntervalSinceNow)) < lifeTime else {
          throw KeychainManagerError.errorGettingToken
      }
      return token
    } else {
      guard let token = KeychainWrapper.standard.string(forKey: "token_dev"),
        !token.isEmpty,
        let lifeTime = KeychainWrapper.standard.double(forKey: "token_lifetime_dev"),
        let tokenSavedDateString = KeychainWrapper.standard.string(forKey: "token_saved_date_dev"),
        let tokenSavedDate = dateFormatter.date(from: tokenSavedDateString),
        (-(tokenSavedDate.timeIntervalSinceNow)) > lifeTime else {
          throw KeychainManagerError.errorGettingToken
      }
      return token
    }
  }

  func getPin() throws  -> String {
    guard let pin = KeychainWrapper.standard.string(forKey: "pin"),
      !pin.isEmpty else {
        throw KeychainManagerError.errorGettingPin
    }
    return pin
  }

  func set(login: String) throws {
    guard KeychainWrapper.standard.set(login, forKey: "login_prod") else {
      throw KeychainManagerError.errorSavingLogin
    }
    guard KeychainWrapper.standard.set(login, forKey: "login_dev") else {
      throw KeychainManagerError.errorSavingLogin
    }
  }

  func set(password: String) throws {
    guard KeychainWrapper.standard.set(password, forKey: "password_prod") else {
      throw KeychainManagerError.errorSavingPassword
    }
    guard KeychainWrapper.standard.set(password, forKey: "password_dev") else {
      throw KeychainManagerError.errorSavingPassword
    }
  }

  func set(token: String, lifeTime: Double) throws {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let defaults = UserDefaults.standard
    let state = defaults.bool(forKey: "isProd_preference")
    if state {
      guard KeychainWrapper.standard.set(token, forKey: "token_prod"),
        KeychainWrapper.standard.set(lifeTime, forKey: "token_lifetime_prod"),
        KeychainWrapper.standard.set(dateFormatter.string(from: Date.init()),
                                     forKey: "token_saved_date_prod") else {
                                      throw KeychainManagerError.errorSavingToken
      }
    } else {
      guard KeychainWrapper.standard.set(token, forKey: "token_dev"),
        KeychainWrapper.standard.set(lifeTime, forKey: "token_lifetime_dev"),
        KeychainWrapper.standard.set(dateFormatter.string(from: Date.init()),
                                     forKey: "token_saved_date_dev") else {
                                      throw KeychainManagerError.errorSavingToken
      }
    }
  }

  func set(pin: String) throws {
    guard KeychainWrapper.standard.set(pin, forKey: "pin") else {
      throw KeychainManagerError.errorSavingPin
    }
  }

  func clearAll() {
    try? set(login: "")
    try? set(pin: "")
    try? set(password: "")
    try? set(token: "", lifeTime: 0)
  }


}
