
import UIKit

final class AuthenticationScreenViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak private var loginTextField: InsettedTextField!
  @IBOutlet weak private var passwordTextField: InsettedTextField!
  @IBOutlet weak private var loginButton: UIButton!
  @IBOutlet weak private var wrongCredentialsLabel: UILabel!
  @IBOutlet weak private var containerView: UIView!
  @IBOutlet weak private var titleLabel: UILabel!
  @IBOutlet weak private var gerbImageView: UIImageView!

  @IBOutlet var heightConstraints: [NSLayoutConstraint]!
  @IBOutlet var widthConstraints: [NSLayoutConstraint]!

  @IBOutlet weak private var containerViewTopConstraint: NSLayoutConstraint!

  // MARK: - Overrides Properties

  override var prefersStatusBarHidden: Bool {
    return true
  }

  // MARK: - ExternalProperties

  var loginTextFieldTextColor: UIColor?
  var loginTextFieldTintColor: UIColor?
  var passwordTextFieldTextColor: UIColor?
  var passwordTextFieldTintColor: UIColor?
  var wrongCredentialsLabelTextColor: UIColor?
  var loginTextFieldWrongCredentialsColor: UIColor?
  var passwordTextFieldWrongCredentialsColor: UIColor?

  // MARK: - Internal Properties

  private let uiHeightMultiplier = ScreenSizeProvider.shared.heightMultiplier
  private let uiWidthMUltiplier = ScreenSizeProvider.shared.widthMultiplier
  private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture))
  private let activityView = UIActivityIndicatorView()
  var viewModel: AuthorizationScreenViewModel?
  
  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupViewModel()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWasShown),
                                           name: UIResponder.keyboardDidShowNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillBeHidden),
                                           name: UIResponder.keyboardWillHideNotification,
                                           object: nil)
  }
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - IBActions

  @IBAction func loginTextChanged(_ sender: UITextField) {
    viewModel?.loginTextChanged(string: sender.text)
  }

  @IBAction func passwordTextChanged(_ sender: UITextField) {
    viewModel?.passwordTextChanged(string: sender.text)
  }

  @IBAction func loginButtonPressed(_ sender: Any) {
    viewModel?.tryToLogin()
  }

  private func setupViewModel() {
    guard let service = ServicesAssembler.instanceFor(.authorization) else {
      return
    }
    viewModel = AuthorizationScreenViewModel(dependencies: service)
    viewModel?.onDataDidChangeClosure = { [weak self] in
      self?.reloadData()
    }
    viewModel?.startAnimatingClosure = { [weak self] in
      self?.activityView.startAnimating()
      self?.loginButton.setTitle("", for: .normal)
      self?.activityView.isHidden = false
    }
    viewModel?.stopAnimatingClosure = { [weak self] in
      self?.loginButton.setTitle("Войти", for: .normal)
      self?.activityView.stopAnimating()
    }
    reloadData()
  }

}

// MARK: - UI Setup

extension AuthenticationScreenViewController {

  private func setupUI() {
    setupConstraints()
    setupLoginTextField()
    setupPasswordTextField()
    setupWronCredentialsLabel()
    setupSubmitButton()
    setupTitleLabel()
    setupActivityView()
  }

  private func setupConstraints() {
    heightConstraints.forEach {
      $0.constant *= self.uiHeightMultiplier
    }
    widthConstraints.forEach {
      $0.constant *= self.uiWidthMUltiplier
    }
  }

  private func setupLoginTextField() {
    loginTextField.font = UIFont(name: "FiraSans-Regular", size: 16 * uiHeightMultiplier)
    loginTextField.placeholder = "Логин"
    loginTextField.textColor = loginTextFieldTextColor
    loginTextField.tintColor = loginTextFieldTintColor
    loginTextField.insetX = 24 * uiWidthMUltiplier
  }

  private func setupPasswordTextField() {
    passwordTextField.font = UIFont(name: "FiraSans-Regular", size: 16 * uiHeightMultiplier)
    passwordTextField.placeholder = "Пароль"
    passwordTextField.textColor = passwordTextFieldTextColor
    passwordTextField.tintColor = passwordTextFieldTintColor
    passwordTextField.insetX = 24 * uiWidthMUltiplier
  }

  private func setupWronCredentialsLabel() {
    wrongCredentialsLabel.textColor = wrongCredentialsLabelTextColor
    wrongCredentialsLabel.font = UIFont(name: "FiraSans-Regular", size: 14 * uiHeightMultiplier)
    wrongCredentialsLabel.isHidden = true
  }

  private func setupSubmitButton() {
    loginButton.layer.cornerRadius = 4 * uiHeightMultiplier
    loginButton.layer.masksToBounds = true
    loginButton.titleLabel?.font = UIFont(name: "FiraSans-Medium", size: 16 * uiHeightMultiplier)
    loginButton.setTitle("Войти", for: .normal)
  }

  private func setupTitleLabel() {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.minimumLineHeight = 23 * uiHeightMultiplier
    paragraphStyle.alignment = .center
    let text = NSMutableAttributedString(string: "Стратегия развития\nНижегородской области")
    text.addAttributes([NSAttributedString.Key.font: UIFont(name: "FiraSans-Light", size: 21 * uiHeightMultiplier)!,
                        NSAttributedString.Key.foregroundColor: UIColor.white,
                        NSAttributedString.Key.paragraphStyle: paragraphStyle,
                        NSAttributedString.Key.kern: 1.04 * uiWidthMUltiplier],
                       range: NSRange(location: 0, length: text.string.count))

    titleLabel.attributedText = text
  }

  private func setupActivityView() {
    activityView.hidesWhenStopped = true
    activityView.color = .white
    activityView.style = .whiteLarge
    activityView.isHidden = true
    activityView.translatesAutoresizingMaskIntoConstraints = false
    loginButton.addSubview(activityView)
    activityView.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor).isActive = true
    activityView.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor).isActive = true

  }
}

// MARK: - UI Update

extension AuthenticationScreenViewController {

  private func reloadData() {
    guard let viewModel = viewModel else { return }
    wrongCredentialsLabel.isHidden = !viewModel.credentialsAreWrong
    loginTextField.backgroundColor = viewModel.credentialsAreWrong
      ? loginTextFieldWrongCredentialsColor
      : .white
    passwordTextField.backgroundColor = viewModel.credentialsAreWrong
      ? passwordTextFieldWrongCredentialsColor
      : .white
    if viewModel.loginSuccessful {
      // Go To adding touchId screen
      let str = UIStoryboard(name: "LocalAuth", bundle: Bundle.main)
      guard let cont = str.instantiateInitialViewController() as? LocalAuthViewController else {
        return
      }
      cont.screenType = .create
      cont.modalPresentationStyle = .fullScreen
      present(cont, animated: true, completion: nil)
    }
  }
}

// MARK: - Local Events

extension AuthenticationScreenViewController {

  @objc
  private func keyboardWasShown(notification: NSNotification) {
    view.addGestureRecognizer(tapGesture)
    UIView.animate(withDuration: 0.3) {
      self.containerViewTopConstraint.constant = -9 * self.uiHeightMultiplier
      self.gerbImageView.isHidden = true
      self.view.layoutIfNeeded()
    }
  }

  @objc
  private func keyboardWillBeHidden(notification: NSNotification) {
    self.view.removeGestureRecognizer(tapGesture)
    UIView.animate(withDuration: 0.3) {
      self.containerViewTopConstraint.constant = 144 * self.uiHeightMultiplier
      self.gerbImageView.isHidden = false
      self.view.layoutIfNeeded()
    }
  }

  @objc
  private func handleGesture() {
    self.view.endEditing(true)
  }
}

// MARK: - Needet for Insetted Text Field.

class InsettedTextField: UITextField {
  var insetX: CGFloat = 6 {
    didSet {
      layoutIfNeeded()
    }
  }
  var insetY: CGFloat = 6 {
    didSet {
      layoutIfNeeded()
    }
  }

  // placeholder position
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: insetX, dy: insetY)
  }

  // text position
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: insetX, dy: insetY)
  }
}
