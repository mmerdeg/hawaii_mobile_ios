import Foundation
import CodableAlamofire
import Alamofire

class RequestRepository: RequestRepositoryProtocol {
    
    var requests: [Request]!
    
    let requestsUrl = ApiConstants.baseUrl + "/requests"
    
    let allowancesUrl = ApiConstants.baseUrl  + "/allowances"
    
    let userRequestsUrl = ApiConstants.baseUrl + "/requests/user"
    
    let requestUrl = ApiConstants.baseUrl + "/requests"
    
    let requestsToApproveUrl = ApiConstants.baseUrl + "/requests/approval"
    
    let requestsByTeamByMonthUrl = ApiConstants.baseUrl + "/requests/team"
    
    let requestsByMonthUrl = ApiConstants.baseUrl + "/requests/month"
    
    let requestYearsUrl = ApiConstants.baseUrl + "/requests" + "/years/range"
    
    let allowanceYearsUrl = ApiConstants.baseUrl  + "/allowances" + "/years/range"
    
    func add(request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        requests?.append(request)
        
        guard let url = URL(string: requestsUrl),
              let requestParameters = request.dictionary else {
                return
        }
        genericCodableRequest(value: Request.self, url, method: .post,
                       parameters: requestParameters, encoding: JSONEncoding.default) { response in
            if response.statusCode == 416 {
                completion(GenericResponse<Request> (success: false, item: nil, statusCode: response.statusCode,
                                               error: response.error,
                                               message: LocalizedKeys.Api.tooManyDays.localized()))
            } else if response.statusCode == 409 {
                completion(GenericResponse<Request> (success: false, item: nil, statusCode: response.statusCode,
                                               error: response.error,
                                               message: LocalizedKeys.Api.alreadyExists.localized()))
            } else {
                completion(response)
            }
        }
    
    }
    
    func getBy(id: Int, completion: @escaping (GenericResponse<Request>) -> Void) {
        guard let url = URL(string: requestUrl + "/\(id)") else {
            return
        }
        genericCodableRequest(value: Request.self, url) { response in
            completion(response)
        }
    }
    
    func getAll(completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: userRequestsUrl) else {
            return
        }
        genericCodableRequest(value: [Request].self, url) { response in
            completion(response)
        }
    }
    
    func getAllBy(id: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: userRequestsUrl + "/\(id)") else {
            return
        }
        
        genericCodableRequest(value: [Request].self, url) { response in
            completion(response)
        }
    }
    
    func getAllByDate(userId: Int, from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        
        let formatter = getDateFormatter()
        
        let startDateKey = "startDate",
            endDateKey = "endDate"
        let params = [startDateKey: formatter.string(from: from),
                      endDateKey: formatter.string(from: toDate)]
        
        guard let url = URL(string: userRequestsUrl + "/\(userId)/dates") else {
            return
        }
        
        genericCodableRequest(value: [Request].self, url, parameters: params) { response in
            completion(response)
        }
    }
    
    func updateRequest(request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        guard let url = URL(string: requestsUrl),
              let requestParameters = request.dictionary else {
                return
        }
        genericCodableRequest(value: Request.self, url, method: .put,
                       parameters: requestParameters,
                       encoding: JSONEncoding.default) { response in
            completion(response)
        }
    }
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: requestsToApproveUrl) else {
            return
        }
        
        genericCodableRequest(value: [Request].self, url) { response in
            completion(response)
        }
    }
    
    func getAllByTeam(date: Date, teamId: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        let urlString = requestsByTeamByMonthUrl + "/\(teamId)/month"
        guard let url = URL(string: urlString) else {
            return
        }
        let formatter = getDateFormatter()
        let dateKey = "date"
        
        let params = [dateKey: formatter.string(from: date)]
        
        genericCodableRequest(value: [Request].self, url, parameters: params) { response in
            completion(response)
        }
    }
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: userRequestsUrl) else {
            return
        }
        genericCodableRequest(value: [Request].self, url) { response in
            completion(response)
        }
    }
    
    func getAllForAllEmployees(date: Date, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: requestsByMonthUrl) else {
            return
        }
        let formatter = getDateFormatter()
        let dateKey = "date"
        
        let params = [dateKey: formatter.string(from: date)]
        
        genericCodableRequest(value: [Request].self, url, parameters: params) { response in
            completion(response)
        }
    }
    
    func getAvailableRequestYearsForSearch(completion: @escaping (GenericResponse<Year>) -> Void) {
        guard let url = URL(string: requestYearsUrl) else {
            return
        }
        
        genericCodableRequest(value: Year.self, url, method: .get) { response in
            completion(response)
        }
    }
    
    func getAvailableRequestYears(completion: @escaping (GenericResponse<Year>) -> Void) {
        guard let url = URL(string: allowanceYearsUrl) else {
            return
        }
        
        genericCodableRequest(value: Year.self, url, method: .get) { response in
            completion(response)
        }
    }
}
