import Foundation
import Alamofire

protocol GenericRepositoryProtocol {
    
    func genericCodableRequest<T: Codable >(value: T.Type, _ url: URL, method: HTTPMethod,
                                            parameters: Parameters?, encoding: ParameterEncoding,
                                            headers: HTTPHeaders?, codableDecoder: JSONDecoder?,
                                            completion: @escaping (GenericResponse<T>) -> Void)
    
    func genericJSONRequest(_ url: URL, method: HTTPMethod,
                            parameters: Parameters?, encoding: ParameterEncoding,
                            headers: HTTPHeaders?,
                            completion: @escaping (GenericResponse<Any>) -> Void)
    
    func genericStringRequest(_ url: URL, method: HTTPMethod,
                              parameters: Parameters?, encoding: ParameterEncoding,
                              headers: HTTPHeaders?,
                              completion: @escaping (GenericResponse<String>) -> Void)
}
