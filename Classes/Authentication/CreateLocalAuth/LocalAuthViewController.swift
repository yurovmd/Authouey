
import UIKit
import LocalAuthentication

final class LocalAuthViewController: UIViewController {

  // MARK: - IBOutlets

  @IBOutlet weak private var titleLabel: UILabel!
  @IBOutlet weak private var errorLabel: UILabel!
  @IBOutlet weak private var errorLabelView: UIView!
  @IBOutlet weak private var buttonsStackView: UIStackView!
  @IBOutlet weak private var secondGroupOfDotsView: UIView!
  @IBOutlet weak private var biometricButton: UIButton!
  @IBOutlet weak private var exitButton: UIButton!

  // MARK: - Outlet Collections

  @IBOutlet private var horizontalStackViews: [UIStackView]!
  // Have tags from 201 to 204
  @IBOutlet private var firstGroupOfDots: [UIView]!
  // Have tags from 301 to 304
  @IBOutlet private var secondGroupOfDots: [UIView]!
  // Have tags 101 - 110
  @IBOutlet private var numberButtons: [UIButton]!
  @IBOutlet private var heightConstraints: [NSLayoutConstraint]!
  @IBOutlet private var widthConstraints: [NSLayoutConstraint]!

  // MARK: - Outside Properties

  var screenType: LocalAuthScreenType?

  var errorLabelTextColor: UIColor?
  var dotsCleanColor: UIColor?
  var dotsFilledColor: UIColor?
  var numberButtonsBorderColor: UIColor?

  // MARK: - Internal Properties

  private var viewModel: LocalAuthViewModel?
  private var context = LAContext()
  private let uiHeightMultiplier = ScreenSizeProvider.shared.heightMultiplier
  private let uiWidthMultiplier = ScreenSizeProvider.shared.widthMultiplier

  // MARK: - Property overrides

  override var prefersStatusBarHidden: Bool {
    return true
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    createViewModel()
    viewModel?.viewIsReady()

    let defaults = UserDefaults.standard
    guard let viewModel = viewModel,
      viewModel.screenType == .login,
      defaults.bool(forKey: "ActivateFastBiometrics") else {
      return
    }
    authenticateWithBiometrics()
  }
  
  // MARK: - IBActions
  @IBAction func exitButtonPressed(_ sender: Any) {
    showExitAlert()
  }
  
  @IBAction func biometricButtonPressed(_ sender: Any) {
    let defaults = UserDefaults.standard
    guard defaults.bool(forKey: "ActivateFastBiometrics") else {
      showActivateBiometricsAlert()
      return
    }
    guard let viewModel = viewModel,
      viewModel.pin.isEmpty else {
      self.viewModel?.deleteNumber()
      return
    }
    authenticateWithBiometrics()
  }

  // MARK: - View Model Creation

  private func createViewModel() {
    guard let screenType = screenType else {
      return
    }
    viewModel = LocalAuthViewModel(dependencies: screenType)
    viewModel?.onScreenStateDidChange = { [weak self] in
      self?.reloadDependOnScreenState()
    }
    viewModel?.onFirstDotsStackViewChange = { [weak self] in
      self?.reloadFirstDotsView()
    }
    viewModel?.onSecondStackViewChange = { [weak self] in
      self?.reloadSecondDotsView()
    }
    viewModel?.onSuccessfulLogin = { [weak self] in
      self?.openMainScreen()
    }
    viewModel?.onSuccessfulPinCreated = { [weak self] in
      self?.showActivateBiometricsAlert()
    }
    viewModel?.onBiometricActivatePressed = { [weak self] in
      self?.authenticateWithBiometrics()
    }
  }

  private func openMainScreen() {
    let str = UIStoryboard(name: "MainScreen", bundle: Bundle.main)
    guard let viewCont = str.instantiateInitialViewController() else {
      return
    }
    viewCont.modalPresentationStyle = .fullScreen
    present(viewCont, animated: true, completion: nil)
  }

  private func authenticateWithBiometrics() {
    guard let viewModel = viewModel,
      viewModel.shouldCheckBiometrics() else {
        openMainScreen()
        return
    }
    context = LAContext()
    // First check if we have the needed hardware support.
    var error: NSError?
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
      let reason = "Быстрый вход"
      context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason ) { success, error in
        if success {
          // Move to the main thread because a state update triggers UI changes.
          DispatchQueue.main.async { [weak self] in
            self?.openMainScreen()
          }
        } else {
          DispatchQueue.main.async { [weak self] in

          }
        }
      }
    } else {
      DispatchQueue.main.async { [weak self] in

      }
    }
  }

  @objc
  private func numberButtonPressed(sender: UIButton) {
    let biometricButtonImage = UIImage(named: "localAuthScreenClear")
    biometricButton.setImage(biometricButtonImage, for: .normal)
    viewModel?.addNewNumberToPin(number: sender.tag - 100)
  }

  private func userWantsLogout() {
    viewModel?.clearUserCredentials()
    let str = UIStoryboard(name: "AuthorizationScreen", bundle: Bundle.main)
    guard let cont = str.instantiateInitialViewController() else {
      return
    }
    cont.modalPresentationStyle = .fullScreen
    present(cont, animated: true, completion: nil)
  }

}

// MARK: - UI Setup

extension LocalAuthViewController {

  private func setupUI() {
    setupConstraints()
    setupTitleLabel()
    setupErrorLabel()
    setupDots()
    setupNumbers()
    setupStackViewsSpacing()
    setupExitButton()
    setupBiometricButton()
  }

  private func setupConstraints() {
    heightConstraints.forEach {
      $0.constant *= self.uiHeightMultiplier
    }
    widthConstraints.forEach {
      $0.constant *= self.uiWidthMultiplier
    }
  }

  private func setupTitleLabel() {
    titleLabel.font = UIFont(name: "SFProDisplay-Light", size: 22 * uiHeightMultiplier)
    titleLabel.textColor = .white
  }

  private func setupErrorLabel() {
    errorLabel.font = UIFont(name: "SFProText-Regular", size: 14 * uiHeightMultiplier)
    errorLabel.textColor = errorLabelTextColor
  }

  private func setupDots() {
    firstGroupOfDots.forEach {
      $0.layer.cornerRadius = $0.bounds.height / 2 * uiHeightMultiplier
      $0.layer.masksToBounds = true
      $0.backgroundColor = dotsCleanColor
    }
    secondGroupOfDots.forEach {
      $0.layer.cornerRadius = $0.bounds.height / 2 * uiHeightMultiplier
      $0.layer.masksToBounds = true
      $0.backgroundColor = dotsCleanColor
    }
  }

  private func setupNumbers() {
    numberButtons.forEach {
      $0.layer.borderColor = numberButtonsBorderColor?.cgColor
      $0.layer.borderWidth = 1.0
      $0.layer.cornerRadius = $0.bounds.height / 2 * uiHeightMultiplier
      $0.layer.masksToBounds = true
      $0.titleLabel?.font = UIFont(name: "SFProDisplay-Light", size: 27 * uiHeightMultiplier)!
      $0.setTitleColor(.white, for: .normal)
      $0.addTarget(self, action: #selector(numberButtonPressed), for: .touchUpInside)
    }
  }

  private func setupStackViewsSpacing() {
    buttonsStackView.spacing *= uiHeightMultiplier
    horizontalStackViews.forEach {
      $0.spacing *= uiWidthMultiplier
    }
  }

  private func setupExitButton() {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    let title = NSMutableAttributedString(string: "Забыли\nпин-код?",
                                          attributes: [NSAttributedString.Key.font: UIFont(name: "SFProText-Light", size: 12 * uiHeightMultiplier)!,
                                                       NSAttributedString.Key.foregroundColor: UIColor.white,
                                                       NSAttributedString.Key.paragraphStyle: paragraphStyle])
    exitButton.titleLabel?.numberOfLines = 0
    exitButton.setAttributedTitle(title, for: .normal)
  }

  private func setupBiometricButton() {
    biometricButton.tintColor = .white
    guard let screenType = screenType,
      screenType == .login else {
      let biometricButtonImage = UIImage(named: "localAuthScreenClear")
      biometricButton.setImage(biometricButtonImage, for: .normal)
      return
    }
    context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    let biometricButtonImage: UIImage?
    switch context.biometryType {
    case .faceID:
      biometricButtonImage = UIImage(named: "localAuthScreenFace")
    case .touchID:
      biometricButtonImage = UIImage(named: "localAuthScreenTouch")
    case .none:
      biometricButtonImage = UIImage(named: "localAuthScreenClear")
    }
    biometricButton.setImage(biometricButtonImage, for: .normal)
  }

}

// MARK: - UI Update

extension LocalAuthViewController {

  private func reloadDependOnScreenState() {
    guard let viewModel = viewModel else { return }
    titleLabel.text = viewModel.titleLabelText
    errorLabel.text = viewModel.errorLabelText
    if errorLabelView.isHidden != !(viewModel.shouldShowErrorLabel) {
      UIView.animate(withDuration: 0.3) {
        self.errorLabelView.isHidden = !(viewModel.shouldShowErrorLabel)
        self.view.layoutIfNeeded()
      }
    }
    if secondGroupOfDotsView.isHidden != !(viewModel.shouldShowSecondLineOfInputs) {
      UIView.animate(withDuration: 0.3) {
        self.secondGroupOfDotsView.isHidden = !(viewModel.shouldShowSecondLineOfInputs)
        self.view.layoutIfNeeded()
      }
    }
    if viewModel.pin.isEmpty {
      setupBiometricButton()
    } else {
      let biometricButtonImage = UIImage(named: "localAuthScreenClear")
      biometricButton.setImage(biometricButtonImage, for: .normal)
    }
    if viewModel.pinIsWrong {
      markAllPinDotsWith(color: dotsFilledColor)
    } else {
      reloadFirstDotsView()
    }
    if viewModel.repeatPinIsWrong {
      markAllRepeatPinDotsWith(color: dotsFilledColor)
    } else {
      reloadSecondDotsView()
    }
  }

  private func markAllPinDotsWith(color: UIColor?) {
    for dot in 1..<5 {
      guard let view = view.viewWithTag(200 + dot) else {
        return
      }
      view.backgroundColor = color
    }
  }

  private func markAllRepeatPinDotsWith(color: UIColor?) {
    for dot in 1..<5 {
      guard let view = view.viewWithTag(300 + dot) else {
        return
      }
      view.backgroundColor = color
    }
  }

  private func reloadFirstDotsView() {
    markAllPinDotsWith(color: dotsCleanColor)
    guard let viewModel = viewModel,
      viewModel.pin.count > 0 else {
      return
    }
    for dot in 1...viewModel.pin.count {
      guard let view = view.viewWithTag(200 + dot) else {
        return
      }
      view.backgroundColor = .white
    }
  }

  private func reloadSecondDotsView() {
    markAllRepeatPinDotsWith(color: dotsCleanColor)
    guard let viewModel = viewModel,
      viewModel.repeatPin.count > 0 else {
      return
    }
    for dot in 1...viewModel.repeatPin.count {
      guard let view = view.viewWithTag(300 + dot) else {
        return
      }
      view.backgroundColor = .white
    }
  }
  
}

// MARK: - Utility

extension LocalAuthViewController {

  private func showActivateBiometricsAlert() {
    context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    let messageString: String
    switch context.biometryType {
    case .faceID:
      messageString = "Face ID"
    case .touchID:
      messageString = "Touch ID"
    case .none:
      openMainScreen()
      return
    }
    let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    let messageText = NSMutableAttributedString(
      string: "Использовать \(messageString) для входа?",
      attributes: [
        NSAttributedString.Key.paragraphStyle: paragraphStyle,
        NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .body),
        NSAttributedString.Key.foregroundColor : UIColor.black
      ]
    )
    alert.setValue(messageText, forKey: "attributedMessage")
    let okHandler: (UIAlertAction) -> Void = { [weak self] _ in
      let defaults = UserDefaults.standard
      defaults.set(true, forKey: "ActivateFastBiometrics")
      self?.authenticateWithBiometrics()
    }
    let cancelHandler: (UIAlertAction) -> Void = { [weak self] _ in
      self?.openMainScreen()
    }
    let okAction = UIAlertAction(title: "OK", style: .default, handler: okHandler)
    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: cancelHandler)
    alert.addAction(okAction)
    alert.addAction(cancelAction)
    present(alert, animated: true)
  }

  private func showExitAlert() {
    let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    let messageText = NSMutableAttributedString(
      string: "Для того, чтобы обновить пинкод, вам нужно будет заново ввести логин и пароль. Продолжить?",
      attributes: [
        NSAttributedString.Key.paragraphStyle: paragraphStyle,
        NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .body),
        NSAttributedString.Key.foregroundColor : UIColor.black
      ]
    )
    alert.setValue(messageText, forKey: "attributedMessage")
    let okHandler: (UIAlertAction) -> Void = { [weak self] _ in
      self?.userWantsLogout()
    }
    let okAction = UIAlertAction(title: "OK", style: .default, handler: okHandler)
    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
    alert.addAction(okAction)
    alert.addAction(cancelAction)
    present(alert, animated: true)
  }

}

// MARK: - LogoutDelegate

extension LocalAuthViewController: LogoutDelegate {

  func logoutUser() {
    let dismissCompletion: () -> Void = { [weak self] in
      self?.userWantsLogout()
    }
    dismiss(animated: true, completion: dismissCompletion)
  }

}
