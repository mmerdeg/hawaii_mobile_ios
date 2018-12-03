import Foundation

protocol TeamRepository {
    
    func get(completion: @escaping (GenericResponse<[Team]>?) -> Void)
    
    func add(team: Team, completion: @escaping (GenericResponse<Team>) -> Void)
    
    func update(team: Team, completion: @escaping (GenericResponse<Team>) -> Void)
    
    func delete(team: Team, completion: @escaping (GenericResponse<Any>?) -> Void)
    
}
