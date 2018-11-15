import Foundation

protocol TableDataProviderRepositoryProtocol: GenericRepositoryProtocol {
    
    func getLeaveData(token: String, completion: @escaping ([CellData], [Absence], GenericResponse<[Absence]>) -> Void)
    
    func getSicknessData(token: String, completion: @escaping ([CellData], [Absence], GenericResponse<[Absence]>) -> Void)
    
    func getBonusData(token: String, completion: @escaping ([CellData], [Absence], GenericResponse<[Absence]>) -> Void)
    
    func getLeaveTypeData(token: String, completion: @escaping ([Absence]) -> Void)
        
    func getDurationData(completion: @escaping ([SectionData]) -> Void)
    
    func getMultipleDaysDurationData(completion: @escaping ([SectionData]) -> Void)
    
    func getBonusDaysDurationData(completion: @escaping ([SectionData]) -> Void)
    
    func getExpandableData(forDate: Date, completion: @escaping ([ExpandableData]) -> Void)
}
