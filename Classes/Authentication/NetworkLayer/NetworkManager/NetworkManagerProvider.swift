
import Foundation

protocol NetworkManagerProvider {
  
  // MARK: - Properties
  
  var delegate: NetworkManagerDelegate? { get set }
  
  // MARK: - Methods
  
  func getDataForEndpointWith(parameters: [String: Any]?,
                              parametersType: ParametersType?,
                              authToken: String?,
                              completion: @escaping (Any?, Error?) -> Void)
  
  func getDataFromUrl(_ urlString: String,
                      completion: @escaping (Any?, Error?) -> Void)
  
  func set(endpoint: NetworkEndpointAbstraction)
  
}
