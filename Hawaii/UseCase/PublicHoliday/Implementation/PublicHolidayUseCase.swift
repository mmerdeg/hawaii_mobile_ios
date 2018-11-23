import Foundation

protocol PublicHolidayUseCaseProtocol {
    
    func getHolidays(completion: @escaping (([Date: [PublicHoliday]], GenericResponse<[PublicHoliday]>?)) -> Void)
    
    func getAllByYear(completion: @escaping (([Int: [PublicHoliday]], GenericResponse<[PublicHoliday]>?)) -> Void)
    
    func add(holiday: PublicHoliday, completion: @escaping (GenericResponse<PublicHoliday>) -> Void)
    
    func update(holiday: PublicHoliday, completion: @escaping (GenericResponse<PublicHoliday>) -> Void)
    
    func delete(holiday: PublicHoliday, completion: @escaping (GenericResponse<Any>?) -> Void)
}

class PublicHolidayUseCase: PublicHolidayUseCaseProtocol {
    
    let publicHolidayRepository: PublicHolidayRepositoryProtocol?
    
    let userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    init(publicHolidayRepository: PublicHolidayRepositoryProtocol, userDetailsUseCase: UserDetailsUseCaseProtocol) {
        self.publicHolidayRepository = publicHolidayRepository
        self.userDetailsUseCase = userDetailsUseCase
    }
    
    func getHolidays(completion: @escaping (([Date: [PublicHoliday]], GenericResponse<[PublicHoliday]>?)) -> Void) {
        guard let token = getToken() else {
            completion(([:], GenericResponse<[PublicHoliday]> (success: false, item: nil, statusCode: 401,
                                                               error: nil,
                                                               message: LocalizedKeys.General.emptyToken.localized())))
            return
        }
        publicHolidayRepository?.getHolidays(token: token) { response in
            guard let holidays = response?.item else {
                return
            }
            completion((Dictionary(grouping: holidays, by: { $0.date ?? Date() }), response))
        }
    }
    
    func getAllByYear(completion: @escaping (([Int: [PublicHoliday]], GenericResponse<[PublicHoliday]>?)) -> Void) {
        guard let token = getToken() else {
            completion(([:], GenericResponse<[PublicHoliday]> (success: false, item: nil, statusCode: 401,
                                                               error: nil,
                                                               message: LocalizedKeys.General.emptyToken.localized())))
            return
        }
        publicHolidayRepository?.getHolidays(token: token) { response in
            guard let holidays = response?.item else {
                return
            }
            let groupedHolidays = Dictionary(grouping: holidays, by: { (item: PublicHoliday) -> Int in
                let calendar = Calendar.current
                return calendar.component(.year, from: item.date ?? Date())
            })
            completion((groupedHolidays, response))
        }
    }
    
    func add(holiday: PublicHoliday, completion: @escaping (GenericResponse<PublicHoliday>) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<PublicHoliday> (success: false, item: nil, statusCode: 401,
                                                               error: nil,
                                                               message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        publicHolidayRepository?.add(token: token, holiday: holiday, completion: { response in
            completion(response)
        })
    }
    
    func update(holiday: PublicHoliday, completion: @escaping (GenericResponse<PublicHoliday>) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<PublicHoliday> (success: false, item: nil, statusCode: 401,
                                                       error: nil,
                                                       message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        publicHolidayRepository?.update(token: token, holiday: holiday, completion: { response in
            completion(response)
        })
    }
    
    func delete(holiday: PublicHoliday, completion: @escaping (GenericResponse<Any>?) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<Any> (success: false, item: nil, statusCode: 401,
                                                       error: nil,
                                                       message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        publicHolidayRepository?.delete(token: token, holiday: holiday, completion: { response in
            completion(response)
        })
    }
    
    func getToken() -> String? {
        return userDetailsUseCase?.getToken()
    }
}
