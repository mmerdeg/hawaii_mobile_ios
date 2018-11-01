import Foundation
import CodableAlamofire
import Alamofire

class PublicHolidayRepository: PublicHolidayRepositoryProtocol {
    
    let authHeader = "X-AUTH-TOKEN"
    
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
    
    func getHeaders(token: String) -> HTTPHeaders {
        return [authHeader: token]
    }
    
}
