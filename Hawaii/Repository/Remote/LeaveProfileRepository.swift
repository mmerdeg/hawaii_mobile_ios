import Foundation
import CodableAlamofire
import Alamofire

class LeaveProfileRepository: SessionManager, LeaveProfileRepositoryProtocol {
    
    let leaveProfileUrl = ApiConstants.baseUrl + "/leaveprofiles"
    
    func get(completion: @escaping (GenericResponse<[LeaveProfile]>?) -> Void) {
        guard let url = URL(string: leaveProfileUrl) else {
            return
        }
        
        genericCodableRequest(value: [LeaveProfile].self, url) { response in
            completion(response)
        }
    }
}
