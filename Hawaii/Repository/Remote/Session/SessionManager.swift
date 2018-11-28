import Foundation
import Alamofire
import SwinjectStoryboard

class SessionManager: GenericRepositoryProtocol {
    
    let session = Alamofire.SessionManager.default

    init() {
        session.adapter = SwinjectStoryboard.defaultContainer.resolve(InterceptorProtocol.self,
                                                                          name: String(describing: InterceptorProtocol.self))
    }
    
    func genericCodableRequest<T: Codable >(value: T.Type, _ url: URL, method: HTTPMethod = .get,
                                            parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default,
                                            headers: HTTPHeaders? = nil, codableDecoder: JSONDecoder? = nil,
                                            completion: @escaping (GenericResponse<T>) -> Void) {
        let completionHandler: (_ response: DataResponse<T>) -> Void = { (response: DataResponse<T>) in
            switch response.result {
            case .success:
                completion(GenericResponse<T> (success: true, item: response.result.value,
                                               statusCode: response.response?.statusCode, error: nil, message: nil))
            case .failure(let error):
                print(error)
                completion(GenericResponse<T> (success: false, item: nil, statusCode: response.response?.statusCode,
                                               error: error,
                                               message: response.error?.localizedDescription))
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            self.session.request(url, method: method, parameters: parameters,
                            encoding: encoding, headers: headers).validate().responseDecodableObject(keyPath: nil,
                                                                                   decoder: codableDecoder ?? self.getDecoder(),
                                                                                   completionHandler: completionHandler)
        }
       
    }
    
    func genericStringRequest(_ url: URL, method: HTTPMethod,
                              parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default,
                              headers: HTTPHeaders? = nil,
                              completion: @escaping (GenericResponse<String>) -> Void) {
        let completionHandler: (_ response: DataResponse<String>) -> Void = { (response: DataResponse<String>) in
            switch response.result {
            case .success:
                completion(GenericResponse<String> (success: true, item: response.result.value,
                                                    statusCode: response.response?.statusCode, error: nil, message: nil))
            case .failure(let error):
                print(error)
                
                completion(GenericResponse<String> (success: false, item: nil, statusCode: response.response?.statusCode,
                                                    error: response.error,
                                                    message: response.error?.localizedDescription))
            }
        }

        DispatchQueue.global(qos: .background).async {
            self.session.request(url, method: method, parameters: parameters,
                                 encoding: encoding, headers: headers).validate().responseString(completionHandler: completionHandler)
        }
    }
    
    func genericJSONRequest(_ url: URL, method: HTTPMethod,
                            parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default,
                            headers: HTTPHeaders? = nil,
                            completion: @escaping (GenericResponse<Any>) -> Void) {
        let completionHandler: (_ response: DataResponse<Any>) -> Void = { (response: DataResponse<Any>) in
            switch response.result {
            case .success:
                completion(GenericResponse<Any> (success: true, item: response.result.value,
                                                 statusCode: response.response?.statusCode, error: nil, message: nil))
            case .failure(let error):
                print(error)
                
                completion(GenericResponse<Any> (success: false, item: nil, statusCode: response.response?.statusCode,
                                                 error: response.error,
                                                 message: response.error?.localizedDescription))
            }
        }

        DispatchQueue.global(qos: .background).async {
            self.session.request(url, method: method, parameters: parameters,
                                            encoding: encoding, headers: headers).validate().responseJSON(completionHandler: completionHandler)
        }
    }
    
    func getDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(getDateFormatter())
        return decoder
    }
    
    func getDateFormatter() -> DateFormatter {
        return RequestDateFormatter()
    }
}
