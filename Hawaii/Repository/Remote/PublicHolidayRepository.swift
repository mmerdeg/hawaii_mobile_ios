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
    
    let publicHolidaysUrl = ApiConstants.baseUrl + "/publicholidays"
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    func getHolidays(completion: @escaping (GenericResponse<[PublicHoliday]>?) -> Void) {
        guard let url = URL(string: publicHolidaysUrl) else {
            return
        }
        let activeKey = "active"
        let params = [activeKey: true]
        
        genericCodableRequest(value: [PublicHoliday].self, url, parameters: params, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getHeaders() -> HTTPHeaders {
        let token = userDetailsUseCase?.getToken()
        return [authHeader: token ?? ""]
    }
    
}
