import Foundation
import CodableAlamofire
import Alamofire

class PublicHolidayRepository: SessionManager, PublicHolidayRepositoryProtocol {
    
    let publicHolidaysUrl = ApiConstants.baseUrl + "/publicholidays"
    
    func getHolidays(completion: @escaping (GenericResponse<[PublicHoliday]>?) -> Void) {
        guard let url = URL(string: publicHolidaysUrl) else {
            return
        }
        let deletedKey = "deleted"
        let params = [deletedKey: false]
        
        genericCodableRequest(value: [PublicHoliday].self, url, parameters: params) { response in
            completion(response)
        }
    }
    
    func add(holiday: PublicHoliday, completion: @escaping (GenericResponse<PublicHoliday>) -> Void) {
        guard let url = URL(string: publicHolidaysUrl),
            let parameters = holiday.dictionary else {
                return
        }
        genericCodableRequest(value: PublicHoliday.self, url, method: .post,
                              parameters: parameters, encoding: JSONEncoding.default) { response in
                                    completion(response)
        }
    }
    
    func update(holiday: PublicHoliday, completion: @escaping (GenericResponse<PublicHoliday>) -> Void) {
        guard let url = URL(string: publicHolidaysUrl),
            let parameters = holiday.dictionary else {
                return
        }
        genericCodableRequest(value: PublicHoliday.self, url, method: .put,
                              parameters: parameters,
                              encoding: JSONEncoding.default) { response in
                                completion(response)
        }
    }
    
    func delete(holiday: PublicHoliday, completion: @escaping (GenericResponse<Any>?) -> Void) {
        guard let id = holiday.id,
              let url = URL(string: publicHolidaysUrl + "/\(id)") else {
            return
        }
        
        genericJSONRequest(url, method: HTTPMethod.delete) { response in
            completion(response)
        }
    }
}
