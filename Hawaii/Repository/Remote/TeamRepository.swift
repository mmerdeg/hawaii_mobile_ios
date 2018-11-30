import Foundation
import CodableAlamofire
import Alamofire

class TeamRepository: SessionManager, TeamRepositoryProtocol {
    
    let teamsUrl = ApiConstants.baseUrl + "/teams"
    
    func get(completion: @escaping (GenericResponse<[Team]>?) -> Void) {
        guard let url = URL(string: teamsUrl) else {
            return
        }
        let activeKey = "deleted"
        let params = [activeKey: false]
        
        genericCodableRequest(value: [Team].self, url, parameters: params) { response in
            completion(response)
        }
    }
    
    func add(team: Team, completion: @escaping (GenericResponse<Team>) -> Void) {
        guard let url = URL(string: teamsUrl),
            let userParameters = team.dictionary else {
                return
        }
        genericCodableRequest(value: Team.self, url, method: .post,
                              parameters: userParameters, encoding: JSONEncoding.default) { response in
                                if response.statusCode == 416 {
                                    completion(GenericResponse<Team> (success: false, item: nil, statusCode: response.statusCode,
                                                                      error: response.error,
                                                                      message: LocalizedKeys.Api.tooManyDays.localized()))
                                } else if response.statusCode == 409 {
                                    completion(GenericResponse<Team> (success: false, item: nil, statusCode: response.statusCode,
                                                                      error: response.error,
                                                                      message: LocalizedKeys.Api.alreadyExists.localized()))
                                } else {
                                    completion(response)
                                }
        }
    }
    
    func update(team: Team, completion: @escaping (GenericResponse<Team>) -> Void) {
        guard let url = URL(string: teamsUrl),
            let requestParameters = team.dictionary else {
                return
        }
        genericCodableRequest(value: Team.self, url, method: .put,
                              parameters: requestParameters,
                              encoding: JSONEncoding.default) { response in
                                completion(response)
        }
    }
    
    func delete(team: Team, completion: @escaping (GenericResponse<Any>?) -> Void) {
        guard let id = team.id,
              let url = URL(string: teamsUrl + "/\(id)") else {
            return
        }

        genericJSONRequest(url, method: HTTPMethod.delete) { response in
                            completion(response)
        }
    }
}
