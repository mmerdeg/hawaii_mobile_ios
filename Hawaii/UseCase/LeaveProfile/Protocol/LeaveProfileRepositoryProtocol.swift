//
//  LeaveProfileRepositoryProtocol.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/22/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol LeaveProfileRepositoryProtocol: GenericRepositoryProtocol {
    
    func get(token: String, completion: @escaping (GenericResponse<[LeaveProfile]>?) -> Void)
    
}
