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
    
    func getAllBy(id: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func add(request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func updateRequest(request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByTeam(from: Date, teamId: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAvailableRequestYears(completion: @escaping (GenericResponse<Year>) -> Void)
    
}

class RequestUseCase: RequestUseCaseProtocol {
    
    let entityRepository: RequestRepositoryProtocol!
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    let userUseCase: UserUseCaseProtocol?
    
    let authHeader = "X-AUTH-TOKEN"
    
    init(entityRepository: RequestRepositoryProtocol, userDetailsUseCase: UserDetailsUseCaseProtocol?, userUseCase: UserUseCaseProtocol) {
        self.entityRepository = entityRepository
        self.userDetailsUseCase = userDetailsUseCase
        self.userUseCase = userUseCase
    }
    
    func getAll(completion: @escaping (GenericResponse<[Request]>) -> Void) {
        entityRepository.getAll(token: getHeaders()) { requests in
            completion(requests)
        }
    }
    
    func getAllBy(id: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        entityRepository.getAllBy(token: getHeaders(), id: id) { requests in
            completion(requests)
        }
    }
    
    func add(request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        entityRepository.add(token: getHeaders(), request: request) {request in
            completion(request)
        }
    }
    
    func getAllForCalendar(completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void) {
        entityRepository.getAll(token: getHeaders()) { response in
            var dict: [Date: [Request]] = [:]
            response.item?.forEach({ request in
                request.days?.forEach({ day in
                    if let date = day.date {
                        if dict[date] != nil {
                            if !(dict[date]?.contains(request) ?? true) &&
                                request.requestStatus != RequestStatus.canceled &&
                                request.requestStatus != RequestStatus.rejected &&
                                request.absence?.absenceType != AbsenceType.bonus.rawValue {
                                dict[date]?.append(request)
                            }
                        } else {
                            dict[date] = [request]
                        }
                    }
                })
            })
            completion(GenericResponse<[Date: [Request]]> (success: response.success,
                                                            item: dict, statusCode: response.statusCode,
                                                            error: response.error,
                                                            message: response.error?.localizedDescription))
        }
    }
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        userUseCase?.readUser(completion: { user in
            self.entityRepository.getAllByDate(token: self.getHeaders(), userId: user?.id ?? -1, from: from, toDate: toDate) { requests in
                completion(requests)
            }
        })
    }
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        entityRepository.getAllPendingForApprover(token: getHeaders(), approver: approver) { requests in
            completion(requests)
        }
    }
    
    func updateRequest(request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        entityRepository.updateRequest(token: getHeaders(), request: request) { request in
            completion(request)
        }
    }

    func getAllByTeam(from: Date, teamId: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        if teamId != -1 {
            entityRepository.getAllByTeam(token: getHeaders(), date: from, teamId: teamId) { requests in
                completion(requests)
            }
        } else {
            entityRepository.getAllForAllEmployees(token: getHeaders(), date: from) { requests in
                completion(requests)
            }
        }
    }
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        entityRepository.getAllForEmployee(token: getHeaders(), byEmail: email) { requestsResponse in
            completion(requestsResponse)
        }
    }
    
    func getAvailableRequestYears(completion: @escaping (GenericResponse<Year>) -> Void) {
        entityRepository.getAvailableRequestYears(token: getHeaders()) { requestsResponse in
            completion(requestsResponse)
        }
    }
    
    func getHeaders() -> HTTPHeaders {
        let token = userDetailsUseCase?.getToken()
        return [authHeader: token ?? ""]
    }
    
}
