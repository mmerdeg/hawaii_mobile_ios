//
//  RequestRepositoryProtocol.swift
//  Hawaii
//
//  Created by Server on 6/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol RequestRepositoryProtocol {
    
    func getAll(completion: @escaping ([Request])-> ())
    
}
