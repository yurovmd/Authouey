
import UIKit

class ScreenSizeProvider {

  static let shared: ScreenSizeProvider = ScreenSizeProvider()
  let widthMultiplier: CGFloat
  let heightMultiplier: CGFloat

  private init() {
    widthMultiplier = UIScreen.main.bounds.width / 1024
    heightMultiplier = UIScreen.main.bounds.height / 768
  }
}
