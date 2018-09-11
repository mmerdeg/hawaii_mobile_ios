//
//  PublicHolidayUseCase.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/7/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol PublicHolidayUseCaseProtocol {
    func getHolidays(completion: @escaping (([Date: [PublicHoliday]], PublicHolidayResponse?)) -> Void)
}

class PublicHolidayUseCase: PublicHolidayUseCaseProtocol {
    
    let publicHolidayRepository: PublicHolidayRepositoryProtocol!
    
    init(publicHolidayRepository: PublicHolidayRepositoryProtocol) {
        self.publicHolidayRepository = publicHolidayRepository
    }
    
    func getHolidays(completion: @escaping (([Date: [PublicHoliday]], PublicHolidayResponse?)) -> Void) {
        publicHolidayRepository.getHolidays { response in
            guard let holidays = response?.holidays else {
                return
            }
            completion((Dictionary(grouping: holidays, by: { $0.date ?? Date() }), response))
        }
    }
    
}
