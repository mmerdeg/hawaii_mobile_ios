import Foundation

protocol PublicHolidayRepositoryProtocol: GenericRepositoryProtocol {
    
    func getHolidays(token: String, completion: @escaping (GenericResponse<[PublicHoliday]>?) -> Void)
}
