
import Foundation

protocol AuthenticationServiceProvider {

    func getToken(completion: @escaping (String?, Error?) -> Void)
}
