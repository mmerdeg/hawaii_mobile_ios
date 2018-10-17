//
//  RequestUseCase.swift
//  Hawaii
//
//  Created by Server on 6/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import Alamofire
import CodableAlamofire

protocol RequestUseCaseProtocol {
    
    func getAll(completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllForCalendar(completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void)
    
    func getAllBy(id: Int, completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void)
    
    func add(request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func updateRequest(request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByTeam(from: Date, teamId: Int, completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void)
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAvailableRequestYears(completion: @escaping (GenericResponse<Year>) -> Void)
    
}

class RequestUseCase: RequestUseCaseProtocol {
    
    let entityRepository: RequestRepositoryProtocol!
    
    let userUseCase: UserUseCaseProtocol?
    
    init(entityRepository: RequestRepositoryProtocol, userUseCase: UserUseCaseProtocol) {
        self.entityRepository = entityRepository
        self.userUseCase = userUseCase
    }
    
    func getAll(completion: @escaping (GenericResponse<[Request]>) -> Void) {
        entityRepository.getAll() { requests in
            completion(requests)
        }
    }
    
    func getAllBy(id: Int, completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void) {
        entityRepository.getAllBy(id: id) { requests in
            completion(self.handle(requests))
        }
    }
    
    func add(request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        entityRepository.add(request: request) {request in
            completion(request)
        }
    }
    
    func getAllForCalendar(completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void) {
        entityRepository.getAll() { response in
            completion(self.handle(response))
        }
    }
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        userUseCase?.readUser(completion: { user in
            self.entityRepository.getAllByDate(userId: user?.id ?? -1, from: from, toDate: toDate) { requests in
                completion(requests)
            }
        })
    }
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        entityRepository.getAllPendingForApprover(approver: approver) { requests in
            completion(requests)
        }
    }
    
    func updateRequest(request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        entityRepository.updateRequest(request: request) { request in
            completion(request)
        }
    }
    
    func getAllByTeam(from: Date, teamId: Int, completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void) {
        if teamId != -1 {
            entityRepository.getAllByTeam(date: from, teamId: teamId) { response in
                completion(self.handle(response))
            }
        } else {
            entityRepository.getAllForAllEmployees(date: from) { response in
                completion(self.handle(response))
            }
        }
    }
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        entityRepository.getAllForEmployee(byEmail: email) { requestsResponse in
            completion(requestsResponse)
        }
    }
    
    func getAvailableRequestYears(completion: @escaping (GenericResponse<Year>) -> Void) {
        entityRepository.getAvailableRequestYears() { requestsResponse in
            completion(requestsResponse)
        }
    }
    
    func handle(_ response: GenericResponse<[Request]>?) -> GenericResponse<[Date: [Request]]> {
        if !(response?.success ?? false) {
            return GenericResponse<[Date: [Request]]> (success: response?.success,
                                                       item: nil, statusCode: response?.statusCode,
                                                       error: response?.error,
                                                       message: response?.error?.localizedDescription)
        }
        var dict: [Date: [Request]] = [:]
        response?.item?.forEach({ request in
            request.days?.forEach({ day in
                if (request.requestStatus == RequestStatus.approved ||
                    request.requestStatus == RequestStatus.pending) &&
                    request.absence?.absenceType != AbsenceType.bonus.rawValue {
                    if let date = day.date {
                        if dict[date] != nil {
                            if !(dict[date]?.contains(request) ?? true) {
                                dict[date]?.append(request)
                            }
                        } else {
                            dict[date] = [request]
                        }
                    }
                }
            })
        })
        return GenericResponse<[Date: [Request]]> (success: response?.success,
                                                   item: dict, statusCode: response?.statusCode,
                                                   error: response?.error,
                                                   message: response?.error?.localizedDescription)
    }
    
//    func getHeaders() -> HTTPHeaders {
//        let authHeader = "X-AUTH-TOKEN"
//        let token = userDetailsUseCase?.getToken()
//        return [authHeader: token ?? ""]
//    }
    
}
