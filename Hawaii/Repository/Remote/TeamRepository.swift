import Foundation
import CodableAlamofire
import Alamofire

class TeamRepository: TeamRepositoryProtocol {
    
    let teamsUrl = ApiConstants.baseUrl + "/teams"
    
    func getTeams(completion: @escaping (GenericResponse<[Team]>?) -> Void) {
        guard let url = URL(string: teamsUrl) else {
            return
        }
        let activeKey = "active"
        let params = [activeKey: true]
        
        genericCodableRequest(value: [Team].self, url, parameters: params) { response in
            completion(response)
        }
    }
}
