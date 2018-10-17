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
    
    func getAll(headers: HTTPHeaders, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllBy(headers: HTTPHeaders, id: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func add(headers: HTTPHeaders, request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByDate(headers: HTTPHeaders, userId: Int, from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllPendingForApprover(headers: HTTPHeaders, approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func updateRequest(headers: HTTPHeaders, request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByTeam(headers: HTTPHeaders, date: Date, teamId: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllForAllEmployees(headers: HTTPHeaders, date: Date, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllForEmployee(headers: HTTPHeaders, byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAvailableRequestYears(headers: HTTPHeaders, completion: @escaping (GenericResponse<Year>) -> Void)
    
}
