import Foundation

protocol PublicHolidayRepositoryProtocol: GenericRepositoryProtocol {
    
    func getHolidays(completion: @escaping (GenericResponse<[PublicHoliday]>?) -> Void)
    
}
