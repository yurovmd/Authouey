
import Foundation

protocol NetworkManagerDelegate: class {
  
  func authorizationFailResponceRecieved()
  func saveToCache(imageLink: String, imageData: Data)
  
}
