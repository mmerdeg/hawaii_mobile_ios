import Foundation

protocol PublicHolidayUseCaseProtocol {
    
    func getHolidays(completion: @escaping (([Date: [PublicHoliday]], GenericResponse<[PublicHoliday]>?)) -> Void)
    
    func getAllByYear(completion: @escaping (([Date: [PublicHoliday]], GenericResponse<[PublicHoliday]>?)) -> Void)
}

class PublicHolidayUseCase: PublicHolidayUseCaseProtocol {
    
    let publicHolidayRepository: PublicHolidayRepositoryProtocol?
    
    init(publicHolidayRepository: PublicHolidayRepositoryProtocol) {
        self.publicHolidayRepository = publicHolidayRepository
    }
    
    func getHolidays(completion: @escaping (([Date: [PublicHoliday]], GenericResponse<[PublicHoliday]>?)) -> Void) {
        publicHolidayRepository?.getHolidays() { response in
            guard let holidays = response?.item else {
                return
            }
            completion((Dictionary(grouping: holidays, by: { $0.date ?? Date() }), response))
        }
    }
    
    func getAllByYear(completion: @escaping (([Date: [PublicHoliday]], GenericResponse<[PublicHoliday]>?)) -> Void) {
        publicHolidayRepository?.getHolidays() { response in
            guard let holidays = response?.item else {
                return
            }
            completion((Dictionary(grouping: holidays, by: { $0.date ?? Date() }), response))
        }
    }
}
