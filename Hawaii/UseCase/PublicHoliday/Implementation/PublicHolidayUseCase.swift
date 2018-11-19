import Foundation

protocol PublicHolidayUseCaseProtocol {
    
    func getHolidays(completion: @escaping (([Date: [PublicHoliday]], GenericResponse<[PublicHoliday]>?)) -> Void)
    
    func getAllByYear(completion: @escaping (([Date: [PublicHoliday]], GenericResponse<[PublicHoliday]>?)) -> Void)
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
    
    func getAllByYear(completion: @escaping (([Date: [PublicHoliday]], GenericResponse<[PublicHoliday]>?)) -> Void) {
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
    
    func getToken() -> String? {
        return userDetailsUseCase?.getToken()
    }
}
