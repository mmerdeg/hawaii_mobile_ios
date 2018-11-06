import Foundation
import Alamofire

protocol RequestRepositoryProtocol: GenericRepositoryProtocol {
    
    func getAll(token: String, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getBy(id: Int, token: String, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllBy(token: String, id: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func add(token: String, request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByDate(token: String, userId: Int, from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllPendingForApprover(token: String, approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func updateRequest(token: String, request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByTeam(token: String, date: Date, teamId: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllForAllEmployees(token: String, date: Date, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllForEmployee(token: String, byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAvailableRequestYears(token: String, completion: @escaping (GenericResponse<Year>) -> Void)
    
    func getAvailableRequestYearsForSearch(token: String, completion: @escaping (GenericResponse<Year>) -> Void)
    
}
