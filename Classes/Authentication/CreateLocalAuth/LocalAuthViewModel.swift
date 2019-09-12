
import Foundation

final class LocalAuthViewModel {

  typealias Dependencies = (LocalAuthScreenType)

  enum BiometricAuthenticationState {
    case loggedin, loggedout, failed
  }

  enum ScreenState {
    case passwordCreationEnterPassword
    case passwordCreationReenterPassword
    case passwordCreationBadReenterPassword
    case loginEnterPassword
    case loginBadPassword
  }

  // MARK: - Properties
  var shouldShowErrorLabel: Bool = false
  var shouldShowSecondLineOfInputs: Bool = false
  var titleLabelText: String = ""
  var errorLabelText: String = ""
  var pinIsWrong: Bool = false
  var repeatPinIsWrong: Bool = false
  var currentScreenState: ScreenState = .loginEnterPassword {
    didSet {
      switch currentScreenState {
      case .passwordCreationEnterPassword:
        titleLabelText = "Выберите пин-код"
        errorLabelText = ""
        shouldShowSecondLineOfInputs = false
        shouldShowErrorLabel = false
        pinIsWrong = false
        repeatPinIsWrong = false
      case .passwordCreationReenterPassword:
        titleLabelText = "Повторите пин-код"
        errorLabelText = ""
        shouldShowSecondLineOfInputs = true
        shouldShowErrorLabel = false
        pinIsWrong = false
        repeatPinIsWrong = false
      case .passwordCreationBadReenterPassword:
        titleLabelText = "Повторите пин-код"
        errorLabelText = "Пин-коды не совпадают. Попробуйте снова"
        shouldShowSecondLineOfInputs = true
        shouldShowErrorLabel = true
        pinIsWrong = false
        repeatPinIsWrong = true
      case .loginEnterPassword:
        titleLabelText = "Введите пин-код"
        errorLabelText = ""
        shouldShowSecondLineOfInputs = false
        shouldShowErrorLabel = false
        pinIsWrong = false
        repeatPinIsWrong = false
      case .loginBadPassword:
        titleLabelText = "Введите пин-код"
        errorLabelText = "Неверный пин-код. Попробуйте снова"
        shouldShowSecondLineOfInputs = false
        shouldShowErrorLabel = true
        pinIsWrong = true
        repeatPinIsWrong = false
      }
      onScreenStateDidChange?()
    }
  }
  var onScreenStateDidChange: (() -> Void)?
  var onFirstDotsStackViewChange: (() -> Void)?
  var onSecondStackViewChange: (() -> Void)?
  var onSuccessfulLogin: (() -> Void)?
  var onSuccessfulPinCreated: (() -> Void)?
  var onBiometricActivatePressed: (() -> Void)?
  var keychainService = KeychainManagerService()

  let screenType: LocalAuthScreenType
  var pin: [Int] = []
  var repeatPin: [Int] = []

  // MARK: - Initializer

  init(dependencies: Dependencies) {
    screenType = dependencies
  }
}

// MARK: - Signals from View

extension LocalAuthViewModel {

  func shouldCheckBiometrics() -> Bool {
    let defaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    guard let lastCheckDateString = defaults.string(forKey: "lastBiometricChackDate"),
      let lastCheckDate = dateFormatter.date(from: lastCheckDateString) else {
        return true
    }

    if lastCheckDate.timeIntervalSince1970 - Date.init().timeIntervalSince1970 > 300 {
      return false
    }
    return true
  }

  func viewIsReady() {
    switch screenType {
    case .login:
      currentScreenState = .loginEnterPassword
    case .create:
      currentScreenState = .passwordCreationEnterPassword
    }
  }

  func addNewNumberToPin(number: Int) {
    switch screenType {
    case .login:
      if pin.count < 4 {
        pin.append(number)
        onFirstDotsStackViewChange?()
        if pin.count == 4 {
          if isPinCorrect() {
            onSuccessfulLogin?()
          } else {
            currentScreenState = .loginBadPassword
          }
        }
      }
    case .create:
      if pin.count < 4 {
        pin.append(number)
        onFirstDotsStackViewChange?()
        if pin.count == 4 {
          currentScreenState = .passwordCreationReenterPassword
        }
      } else if repeatPin.count < 4 {
        repeatPin.append(number)
        onSecondStackViewChange?()
        if repeatPin.count == 4 {
          if isPinEqualRepeatPin() {
            savePin()
            onSuccessfulPinCreated?()
          } else {
            currentScreenState = .passwordCreationBadReenterPassword
          }
        }
      }
    }
    
  }

  func deleteNumber() {
    switch screenType {
    case .login:
      guard pin.count > 0 else {
        onBiometricActivatePressed?()
        return
      }
      pin.removeLast()
      currentScreenState = .loginEnterPassword
    case .create:
      if repeatPin.isEmpty {
        if !pin.isEmpty {
          pin.removeLast()
        } else {
          onBiometricActivatePressed?()
        }
        currentScreenState = .passwordCreationEnterPassword
      } else {
        if currentScreenState == .passwordCreationBadReenterPassword {
          repeatPin = []
        } else {
          repeatPin.removeLast()
        }
        currentScreenState = .passwordCreationReenterPassword
      }
    }

  }

  func clearUserCredentials() {
    keychainService.clearAll()
  }

}

// MARK: - Utility Methods

extension LocalAuthViewModel {

  private func isPinCorrect() -> Bool {
    do {
      let pinStored = try keychainService.getPin()
      let currentPin = String(pin.flatMap { "\($0)" })
      return pinStored == currentPin
    } catch {
      return false
    }
  }

  private func isPinEqualRepeatPin() -> Bool {
    return pin == repeatPin
  }

  private func savePin() {
    do {
      let pinToStore = String(pin.flatMap { "\($0)" })
      try keychainService.set(pin: pinToStore)
    } catch {
      return
    }
  }

}
