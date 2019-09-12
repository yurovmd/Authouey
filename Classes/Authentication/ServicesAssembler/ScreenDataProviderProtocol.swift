
import Foundation

protocol ScreenDataProviderProtocol {

  func getDataFromEndpointWith(parameters: [String: Any]?,
                               parametersType: ParametersType?,
                               completion: @escaping (Any?, Error?) -> Void)

  func getDataFromUrl(_ urlString: String,
                      completion: @escaping (Any?, Error?) -> Void)

}
