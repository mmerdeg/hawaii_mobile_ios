//
//  LeaveProfileRepository.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/22/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import CodableAlamofire
import Alamofire

class LeaveProfileRepository: LeaveProfileRepositoryProtocol {
    
    let leaveProfileUrl = ApiConstants.baseUrl + "/leaveprofiles"
    
    func get(completion: @escaping (GenericResponse<[LeaveProfile]>?) -> Void) {
        guard let url = URL(string: leaveProfileUrl) else {
            return
        }
        
        genericCodableRequest(value: [LeaveProfile].self, url) { response in
            completion(response)
        }
    }
}
