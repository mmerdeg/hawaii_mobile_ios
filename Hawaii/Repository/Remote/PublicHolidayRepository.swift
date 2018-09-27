//
//  PublicHolidayRepository.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/7/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import CodableAlamofire
import Alamofire

class PublicHolidayRepository: PublicHolidayRepositoryProtocol {
    
    let authHeader = "X-AUTH-TOKEN"
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    func getHolidays(completion: @escaping (GenericResponse<[PublicHoliday]>?) -> Void) {
        guard let url = URL(string: Constants.publicHolidays) else {
            return
        }
        
        let params = ["active": true]
        
        genericRequest(value: [PublicHoliday].self, url, parameters: params, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getHeaders() -> HTTPHeaders {
        let token = userDetailsUseCase?.getToken()
        return [authHeader: token ?? ""]
    }
    
}
