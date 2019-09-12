
import Foundation

protocol NetworkRouterProvider {

    func requestWith(endpoint: NetworkEndpointAbstraction,
                     authToken: String?,
                     completion: @escaping (Data?, URLResponse?, Error?) -> Void)

    func downloadDataFor(urlString: String,
                         completion: @escaping (Data?, URLResponse?, Error?) -> Void)

}
