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
    
    func getBy(id: Int, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllBy(id: Int, completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void)
    
    func add(request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func updateRequest(request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByTeam(from: Date, teamId: Int, completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void)
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAvailableRequestYears(completion: @escaping (GenericResponse<Year>) -> Void)
    
    func getAvailableRequestYearsForSearch(completion: @escaping (GenericResponse<Year>) -> Void)
    
}

class RequestUseCase: RequestUseCaseProtocol {
    
    let requestRepository: RequestRepositoryProtocol?
    
    let userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    let userUseCase: UserUseCaseProtocol?
    
    init(entityRepository: RequestRepositoryProtocol, userUseCase: UserUseCaseProtocol,
         userDetailsUseCase: UserDetailsUseCaseProtocol) {
        self.requestRepository = entityRepository
        self.userUseCase = userUseCase
        self.userDetailsUseCase = userDetailsUseCase
    }
    
    func getBy(id: Int, completion: @escaping (GenericResponse<Request>) -> Void) {
        requestRepository?.getBy(id: id, token: getToken(), completion: { response in
            completion(response)
        })
    }
    
    func getAll(completion: @escaping (GenericResponse<[Request]>) -> Void) {
        requestRepository?.getAll(token: getToken()) { requests in
            completion(requests)
        }
    }
    
    func getAllBy(id: Int, completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void) {
        requestRepository?.getAllBy(token: getToken(), id: id) { requests in
            completion(self.handle(requests))
        }
    }
    
    func add(request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        requestRepository?.add(token: getToken(), request: request) {request in
            completion(request)
        }
    }
    
    func getAllForCalendar(completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void) {
        requestRepository?.getAll(token: getToken()) { response in
            completion(self.handle(response))
        }
    }
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        userUseCase?.readUser(completion: { user in
            self.requestRepository?.getAllByDate(token: self.getToken(), userId: user?.id ?? -1, from: from, toDate: toDate) { requests in
                completion(requests)
            }
        })
    }
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        requestRepository?.getAllPendingForApprover(token: getToken(), approver: approver) { requests in
            completion(requests)
        }
    }
    
    func updateRequest(request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        requestRepository?.updateRequest(token: getToken(), request: request) { request in
            completion(request)
        }
    }
    
    func getAllByTeam(from: Date, teamId: Int, completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void) {
        if teamId != -1 {
            requestRepository?.getAllByTeam(token: getToken(), date: from, teamId: teamId) { response in
                completion(self.handle(response))
            }
        } else {
            requestRepository?.getAllForAllEmployees(token: getToken(), date: from) { response in
                completion(self.handle(response))
            }
        }
    }
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        requestRepository?.getAllForEmployee(token: getToken(), byEmail: email) { requestsResponse in
            completion(requestsResponse)
        }
    }
    
    func getAvailableRequestYears(completion: @escaping (GenericResponse<Year>) -> Void) {
        requestRepository?.getAvailableRequestYears(token: getToken()) { requestsResponse in
            completion(requestsResponse)
        }
    }
    
    func getAvailableRequestYearsForSearch(completion: @escaping (GenericResponse<Year>) -> Void) {
        requestRepository?.getAvailableRequestYearsForSearch(token: getToken(), completion: { requestsResponse in
            completion(requestsResponse)
        })
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
                    request.requestStatus == RequestStatus.pending ||
                    request.requestStatus == RequestStatus.cancelationPending) &&
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
    
    func getToken() -> String {
        return userDetailsUseCase?.getToken() ?? ""
    }
    
}
