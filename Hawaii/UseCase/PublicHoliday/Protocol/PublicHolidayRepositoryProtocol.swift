import Foundation

protocol PublicHolidayRepositoryProtocol: GenericRepositoryProtocol {
    
    func getHolidays(completion: @escaping (GenericResponse<[PublicHoliday]>?) -> Void)
    
    func add(holiday: PublicHoliday, completion: @escaping (GenericResponse<PublicHoliday>) -> Void)
    
    func update(holiday: PublicHoliday, completion: @escaping (GenericResponse<PublicHoliday>) -> Void)
    
    func delete(holiday: PublicHoliday, completion: @escaping (GenericResponse<Any>?) -> Void)
    
}
