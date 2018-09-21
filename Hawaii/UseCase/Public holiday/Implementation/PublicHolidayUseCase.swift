//
//  PublicHolidayUseCase.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/7/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol PublicHolidayUseCaseProtocol {
    func getHolidays(completion: @escaping (([Date: [PublicHoliday]], GenericResponse<PublicHoliday>?)) -> Void)
}

class PublicHolidayUseCase: PublicHolidayUseCaseProtocol {
    
    let publicHolidayRepository: PublicHolidayRepositoryProtocol!
    
    init(publicHolidayRepository: PublicHolidayRepositoryProtocol) {
        self.publicHolidayRepository = publicHolidayRepository
    }
    
    func getHolidays(completion: @escaping (([Date: [PublicHoliday]], GenericResponse<PublicHoliday>?)) -> Void) {
        publicHolidayRepository.getHolidays { response in
            guard let holidays = response?.items else {
                return
            }
            completion((Dictionary(grouping: holidays, by: { $0.date ?? Date() }), response))
        }
    }
    
}
