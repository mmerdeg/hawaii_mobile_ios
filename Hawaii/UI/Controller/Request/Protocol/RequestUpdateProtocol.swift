//
//  RequestUpdateProtocol.swift
//  Hawaii
//
//  Created by Server on 7/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol RequestUpdateProtocol: class {
    
    func didAdd(request: Request)
    
    func didRemove(request: Request)
    
    func didEdit(request: Request)
}
