import Foundation

protocol LeaveProfileRepositoryProtocol {
    
    func get(completion: @escaping (GenericResponse<[LeaveProfile]>?) -> Void)
    
    func add(leaveProfile: LeaveProfile, completion: @escaping (GenericResponse<LeaveProfile>) -> Void)
    
    func update(leaveProfile: LeaveProfile, completion: @escaping (GenericResponse<LeaveProfile>) -> Void)
    
    func delete(leaveProfile: LeaveProfile, completion: @escaping (GenericResponse<Any>?) -> Void)
    
}
