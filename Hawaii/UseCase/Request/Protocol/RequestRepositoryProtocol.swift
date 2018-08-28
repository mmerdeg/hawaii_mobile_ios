//
//  RequestRepositoryProtocol.swift
//  Hawaii
//
//  Created by Server on 6/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol RequestRepositoryProtocol {
    
    func getAll(completion: @escaping ([Request]) -> Void)
    
    func add(request: Request, completion: @escaping (Request) -> Void)
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping ([Request]) -> Void)
    
    func getAllPendingForApprover(approver: Int, completion: @escaping ([Request]) -> Void)
    
    func updateRequest(request: Request, completion: @escaping (Request) -> Void)
    
    func getAllByTeam(date: Date, teamId: Int, completion: @escaping ([Request]) -> Void)
    
    func getAllForAllEmployees(date: Date, completion: @escaping ([Request]) -> Void)
}
