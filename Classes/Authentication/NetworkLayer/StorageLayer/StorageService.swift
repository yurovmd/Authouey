
import Foundation

final class StorageService {
  
}

// MARK: - StorageProvider

extension StorageService: StorageProvider {
  
  func save(image: Data, withUrl: String) throws {
    
    // At first, we need to create pair for store in userdefaults
    // There must be generated image name and link, that we get from server
    // ImageName:
    let imageName = "\(UUID.init().uuidString).png"
    
    // Now we need to save image data to filesystem
    guard let path = FileManager.default.urls(for: .documentDirectory,
                                              in: .userDomainMask).first else {
      throw StorageLayerError.cantGetUserDocumentsPath
    }
    let imageUrl = path.appendingPathComponent(imageName)
    do {
      try image.write(to: imageUrl)
    } catch {
      throw StorageLayerError.problemWithSavingFile
    }
    
    // After we saved data to filesystem, just update defaults by
    // adding there ney entry with new image
    let defaults = UserDefaults.standard
    defaults.set(imageName, forKey: withUrl)
    // Now Image Name can be reached throwgh its url
  }
  
  func getImagePath(for url: String) -> String? {
    // At first, we need to get image Name by provided link
    let defaults = UserDefaults.standard
    guard let imageName = defaults.value(forKey: url) as? String else {
      return nil
    }
    
    // Now, we need to provide current file path with
    // appended image name
    guard let path = FileManager.default.urls(for: .documentDirectory,
                                              in: .userDomainMask).first else {
      return nil
    }
    let imageUrl = path.appendingPathComponent(imageName)
    return imageUrl.absoluteString
  }
  
}
