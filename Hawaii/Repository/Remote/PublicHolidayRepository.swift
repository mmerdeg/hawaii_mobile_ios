import Foundation
import CodableAlamofire
import Alamofire

class PublicHolidayRepository: PublicHolidayRepositoryProtocol {
    
    let publicHolidaysUrl = ApiConstants.baseUrl + "/publicholidays"
    
    func getHolidays(token: String, completion: @escaping (GenericResponse<[PublicHoliday]>?) -> Void) {
        guard let url = URL(string: publicHolidaysUrl) else {
            return
        }
        let activeKey = "active"
        let params = [activeKey: true]
        
        genericCodableRequest(value: [PublicHoliday].self, url, parameters: params, headers: getHeaders(token: token)) { response in
            completion(response)
        }
    }
    
    func add(token: String, holiday: PublicHoliday, completion: @escaping (GenericResponse<PublicHoliday>) -> Void) {
        guard let url = URL(string: publicHolidaysUrl),
            let parameters = holiday.dictionary else {
                return
        }
        genericCodableRequest(value: PublicHoliday.self, url, method: .post,
                              parameters: parameters, encoding: JSONEncoding.default,
                              headers: getHeaders(token: token)) { response in
                                    completion(response)
        }
    }
    
    func update(token: String, holiday: PublicHoliday, completion: @escaping (GenericResponse<PublicHoliday>) -> Void) {
        guard let url = URL(string: publicHolidaysUrl),
            let parameters = holiday.dictionary else {
                return
        }
        genericCodableRequest(value: PublicHoliday.self, url, method: .put,
                              parameters: parameters,
                              encoding: JSONEncoding.default,
                              headers: getHeaders(token: token)) { response in
                                completion(response)
        }
    }
    
    func delete(token: String, holiday: PublicHoliday, completion: @escaping (GenericResponse<Any>?) -> Void) {
        guard let id = holiday.id,
              let url = URL(string: publicHolidaysUrl + "/\(id)") else {
            return
        }
        
        genericJSONRequest(url, method: HTTPMethod.delete, headers: getHeaders(token: token)) { response in
            completion(response)
        }
    }
    
    func getHeaders(token: String) -> HTTPHeaders {
        return [ApiConstants.authHeader: token]
    }
    
}
