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
    
    func getHolidays(completion: @escaping (PublicHolidayResponse?) -> Void) {
        guard let url = URL(string: Constants.publicHolidays) else {
            return
        }
        
        let params = ["active": true]
        Alamofire.request(url, method: HTTPMethod.get, parameters: params, headers: getHeaders()).validate()
            .responseDecodableObject(keyPath: nil, decoder: getDecoder()) { (response: DataResponse<[PublicHoliday]>) in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    completion(PublicHolidayResponse(success: true, holidays: response.result.value, error: nil, message: nil))
                case .failure(let error):
                    print(error)
                    completion(PublicHolidayResponse(success: false, holidays: nil,
                                                     error: response.error, message: response.error?.localizedDescription))
                }
            }
    }
    
    func getHeaders() -> HTTPHeaders {
        let token = userDetailsUseCase?.getToken()
        return [authHeader: token ?? ""]
    }
    
    func getDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(getDateFormatter())
        return decoder
    }
    
    func getDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }
    
}
