//
//  LeaveTypeUseCase.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

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
    
    init(tableDataProviderRepository: TableDataProviderRepositoryProtocol) {
        self.tableDataProviderRepository = tableDataProviderRepository
    }

    func getLeaveData(completion: @escaping ([CellData], [String: [Absence]], GenericResponse<[Absence]>) -> Void) {
        tableDataProviderRepository?.getLeaveData(completion: { data, leaveTypeData, response in
            completion(data, Dictionary(grouping: leaveTypeData, by: { $0.absenceType ?? "" }), response)
        })
    }
    
    func getLeaveTypeData(completion: @escaping ([String: [Absence]]) -> Void) {
        tableDataProviderRepository?.getLeaveTypeData(completion: { data in
            completion(Dictionary(grouping: data, by: { $0.absenceType ?? "" }))
        })
    }
    
    func getSicknessData(completion: @escaping ([CellData], [String: [Absence]], GenericResponse<[Absence]>) -> Void) {
        tableDataProviderRepository?.getSicknessData(completion: { data, leaveTypeData, response in
            completion(data, Dictionary(grouping: leaveTypeData, by: { $0.absenceType ?? "" }), response)
        })
    }
    
    func getBonusData(completion: @escaping ([CellData], [String: [Absence]], GenericResponse<[Absence]>) -> Void) {
        tableDataProviderRepository?.getBonusData(completion: { data, bonusTypeData, response  in
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
}
