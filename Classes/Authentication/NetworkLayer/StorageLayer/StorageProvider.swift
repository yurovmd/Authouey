
import Foundation

protocol StorageProvider {
  
  func save(image: Data, withUrl: String) throws
  func getImagePath(for url: String) -> String?
  
}
