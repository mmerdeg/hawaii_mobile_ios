import Foundation

protocol TableDataProviderUseCaseProtocol {
    
    func getLeaveData(completion: @escaping ([CellData], [String: [Absence]], GenericResponse<[Absence]>) -> Void)
    
    func getSicknessData(completion: @escaping ([CellData], [String: [Absence]], GenericResponse<[Absence]>) -> Void)
    
    func getBonusData(completion: @escaping ([CellData], [String: [Absence]], GenericResponse<[Absence]>) -> Void)
    
    func getLeaveTypeData(completion: @escaping ([String: [Absence]]) -> Void)
    
    func getDurationData(completion: @escaping ([SectionData]) -> Void)
    
    func getMultipleDaysDurationData(completion: @escaping ([SectionData]) -> Void)
    
    func getBonusDaysDurationData(completion: @escaping ([SectionData]) -> Void)
    
    func getExpandableData(forDate: Date, completion: @escaping ([ExpandableData]) -> Void)
}

class TableDataProviderUseCase: TableDataProviderUseCaseProtocol {
    
    var tableDataProviderRepository: TableDataProviderRepositoryProtocol?
    
    let userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    init(tableDataProviderRepository: TableDataProviderRepositoryProtocol, userDetailsUseCase: UserDetailsUseCaseProtocol) {
        self.tableDataProviderRepository = tableDataProviderRepository
        self.userDetailsUseCase = userDetailsUseCase
    }

    func getLeaveData(completion: @escaping ([CellData], [String: [Absence]], GenericResponse<[Absence]>) -> Void) {
        guard let token = getToken() else {
            completion([], [:], GenericResponse<[Absence]> (success: false, item: nil, statusCode: 401,
                                           error: nil,
                                           message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        tableDataProviderRepository?.getLeaveData(token: token, completion: { data, leaveTypeData, response in
            completion(data, Dictionary(grouping: leaveTypeData, by: { $0.absenceType ?? "" }), response)
        })
    }
    
    func getLeaveTypeData(completion: @escaping ([String: [Absence]]) -> Void) {
        guard let token = getToken() else {
            completion([:])
            return
        }
        tableDataProviderRepository?.getLeaveTypeData(token: token, completion: { data in
            completion(Dictionary(grouping: data, by: { $0.absenceType ?? "" }))
        })
    }
    
    func getSicknessData(completion: @escaping ([CellData], [String: [Absence]], GenericResponse<[Absence]>) -> Void) {
        guard let token = getToken() else {
            completion([], [:], GenericResponse<[Absence]> (success: false, item: nil, statusCode: 401,
                                                            error: nil,
                                                            message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        tableDataProviderRepository?.getSicknessData(token: token, completion: { data, leaveTypeData, response in
            completion(data, Dictionary(grouping: leaveTypeData, by: { $0.absenceType ?? "" }), response)
        })
    }
    
    func getBonusData(completion: @escaping ([CellData], [String: [Absence]], GenericResponse<[Absence]>) -> Void) {
        guard let token = getToken() else {
            completion([], [:], GenericResponse<[Absence]> (success: false, item: nil, statusCode: 401,
                                                            error: nil,
                                                            message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        tableDataProviderRepository?.getBonusData(token: token, completion: { data, bonusTypeData, response  in
            completion(data, Dictionary(grouping: bonusTypeData, by: { $0.absenceType ?? "" }), response)
        })
    }
    
    func getDurationData(completion: @escaping ([SectionData]) -> Void) {
        tableDataProviderRepository?.getDurationData(completion: { data in
            completion(data)
        })
    }
    
    func getMultipleDaysDurationData(completion: @escaping ([SectionData]) -> Void) {
        tableDataProviderRepository?.getMultipleDaysDurationData(completion: { data in
            completion(data)
        })
    }
    
    func getExpandableData(forDate: Date, completion: @escaping ([ExpandableData]) -> Void) {
        tableDataProviderRepository?.getExpandableData(forDate: forDate, completion: { expandableData in
            completion(expandableData)
        })
    }
    
    func getBonusDaysDurationData(completion: @escaping ([SectionData]) -> Void) {
        tableDataProviderRepository?.getBonusDaysDurationData(completion: { data in
            completion(data)
        })
    }
    
    func getToken() -> String? {
        return userDetailsUseCase?.getToken()
    }
}
