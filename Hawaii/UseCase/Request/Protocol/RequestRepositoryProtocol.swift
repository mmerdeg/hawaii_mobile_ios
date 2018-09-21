//
//  RequestRepositoryProtocol.swift
//  Hawaii
//
//  Created by Server on 6/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import Alamofire

protocol RequestRepositoryProtocol: GenericResponseProtocol {
    
    func getAll(completion: @escaping (GenericResponseSingle<[Request]>) -> Void)
    
    func getAllBy(id: Int, completion: @escaping (GenericResponseSingle<[Request]>) -> Void)
    
    func add(request: Request, completion: @escaping (GenericResponseSingle<Request>) -> Void)
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping (GenericResponseSingle<[Request]>) -> Void)
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (GenericResponseSingle<[Request]>) -> Void)
    
    func updateRequest(request: Request, completion: @escaping (GenericResponseSingle<Request>) -> Void)
    
    func getAllByTeam(date: Date, teamId: Int, completion: @escaping (GenericResponseSingle<[Request]>) -> Void)
    
    func getAllForAllEmployees(date: Date, completion: @escaping (GenericResponseSingle<[Request]>) -> Void)
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (GenericResponseSingle<[Request]>) -> Void)
    
    func getAvailableRequestYears(completion: @escaping (GenericResponseSingle<Year>) -> Void)
    
}
