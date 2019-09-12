
import Foundation

enum NetworkResponseError: Error {
    case needToBeAuthenticated
    case badRequest
    case urlOutdated
    case networkRequestFailed
}
