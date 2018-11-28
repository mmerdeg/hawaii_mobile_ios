import Foundation
import Alamofire

protocol RequestRepositoryProtocol {
    
    func getAll(completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getBy(id: Int, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllBy(id: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func add(request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByDate(userId: Int, from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func updateRequest(request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByTeam(date: Date, teamId: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllForAllEmployees(date: Date, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAvailableRequestYears(completion: @escaping (GenericResponse<Year>) -> Void)
    
    func getAvailableRequestYearsForSearch(completion: @escaping (GenericResponse<Year>) -> Void)
    
}
