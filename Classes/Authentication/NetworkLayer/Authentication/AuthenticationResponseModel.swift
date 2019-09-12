
import Foundation

struct AuthenticationResponseModel: Decodable {
    let accessToken: String
    let expiresIn: Int
}
