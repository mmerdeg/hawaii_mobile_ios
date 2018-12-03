import Foundation

protocol TableDataProviderRepository: GenericRepositoryProtocol {
    
    func getLeaveData(completion: @escaping ([CellData], [Absence], GenericResponse<[Absence]>) -> Void)
    
    func getSicknessData(completion: @escaping ([CellData], [Absence], GenericResponse<[Absence]>) -> Void)
    
    func getBonusData(completion: @escaping ([CellData], [Absence], GenericResponse<[Absence]>) -> Void)
    
    func getLeaveTypeData(completion: @escaping ([Absence]) -> Void)
        
    func getDurationData(completion: @escaping ([SectionData]) -> Void)
    
    func getMultipleDaysDurationData(completion: @escaping ([SectionData]) -> Void)
    
    func getBonusDaysDurationData(completion: @escaping ([SectionData]) -> Void)
    
    func getExpandableData(forDate: Date, completion: @escaping ([ExpandableData]) -> Void)
    
    func getMoreData(completion: @escaping ([SectionData]) -> Void)
}
