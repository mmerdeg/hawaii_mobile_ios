import Foundation

protocol PublicHolidayRepositoryProtocol: GenericRepositoryProtocol {
    
    func getHolidays(token: String, completion: @escaping (GenericResponse<[PublicHoliday]>?) -> Void)
    
    func add(token: String, holiday: PublicHoliday, completion: @escaping (GenericResponse<PublicHoliday>) -> Void)
    
    func update(token: String, holiday: PublicHoliday, completion: @escaping (GenericResponse<PublicHoliday>) -> Void)
    
    func delete(token: String, holiday: PublicHoliday, completion: @escaping (GenericResponse<Any>?) -> Void)
    
}
