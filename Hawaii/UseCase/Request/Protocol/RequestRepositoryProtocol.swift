//
//  RequestRepositoryProtocol.swift
//  Hawaii
//
//  Created by Server on 6/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import Alamofire

protocol RequestRepositoryProtocol: GenericRepositoryProtocol {
    
    func getAll(token: HTTPHeaders, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllBy(token: HTTPHeaders, id: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func add(token: HTTPHeaders, request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByDate(token: HTTPHeaders, userId: Int, from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllPendingForApprover(token: HTTPHeaders, approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func updateRequest(token: HTTPHeaders, request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByTeam(token: HTTPHeaders, date: Date, teamId: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllForAllEmployees(token: HTTPHeaders, date: Date, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllForEmployee(token: HTTPHeaders, byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAvailableRequestYears(token: HTTPHeaders, completion: @escaping (GenericResponse<Year>) -> Void)
    
}
