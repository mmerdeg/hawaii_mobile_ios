import Foundation

protocol PublicHolidayUseCaseProtocol {
    
    func getHolidays(completion: @escaping (([Date: [PublicHoliday]], GenericResponse<[PublicHoliday]>?)) -> Void)
}

class PublicHolidayUseCase: PublicHolidayUseCaseProtocol {
    
    let publicHolidayRepository: PublicHolidayRepositoryProtocol?
    
    let userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    init(publicHolidayRepository: PublicHolidayRepositoryProtocol, userDetailsUseCase: UserDetailsUseCaseProtocol) {
        self.publicHolidayRepository = publicHolidayRepository
        self.userDetailsUseCase = userDetailsUseCase
    }
    
    func getHolidays(completion: @escaping (([Date: [PublicHoliday]], GenericResponse<[PublicHoliday]>?)) -> Void) {
        publicHolidayRepository?.getHolidays(token: getToken()) { response in
            guard let holidays = response?.item else {
                return
            }
            completion((Dictionary(grouping: holidays, by: { $0.date ?? Date() }), response))
        }
    }
    
    func getToken() -> String {
        return userDetailsUseCase?.getToken() ?? ""
    }
}
