
import Foundation

enum KeychainManagerError: Error {

  case errorSavingLogin
  case errorSavingPassword
  case errorSavingToken
  case errorSavingPin
  case errorGettingLogin
  case errorGettingPassword
  case errorGettingToken
  case errorGettingPin

}
