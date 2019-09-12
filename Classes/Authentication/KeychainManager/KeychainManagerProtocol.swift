
import Foundation

protocol KeychainManagerProtocol {

  func getLogin() throws -> String
  func getPassword() throws -> String
  func getToken() throws -> String
  func getPin() throws  -> String

  func set(login: String) throws
  func set(password: String) throws
  func set(token: String, lifeTime: Double) throws
  func set(pin: String) throws

  func clearAll()

}
