
import Foundation

enum NetworkLayerError: Error {
    case cantBuildURLForRequest
    case networkConnectionError
    case noDataToDecode
    case unknownTypeOfResponse
    case returnedDataUnexpectedType
    case toknIsNil
    case dataDecodingProblem
}
