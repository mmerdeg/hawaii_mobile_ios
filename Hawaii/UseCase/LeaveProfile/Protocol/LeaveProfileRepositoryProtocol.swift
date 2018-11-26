import Foundation

protocol LeaveProfileRepositoryProtocol {
    
    func get(completion: @escaping (GenericResponse<[LeaveProfile]>?) -> Void)
    
}
