import Foundation
import CodableAlamofire
import Alamofire

class PublicHolidayRepository: PublicHolidayRepositoryProtocol {
    
    let publicHolidaysUrl = ApiConstants.baseUrl + "/publicholidays"
    
    func getHolidays(completion: @escaping (GenericResponse<[PublicHoliday]>?) -> Void) {
        guard let url = URL(string: publicHolidaysUrl) else {
            return
        }
        let activeKey = "active"
        let params = [activeKey: true]
        
        genericCodableRequest(value: [PublicHoliday].self, url, parameters: params) { response in
            completion(response)
        }
    }
}
