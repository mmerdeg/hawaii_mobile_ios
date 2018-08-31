//
//  LeaveTypeUseCase.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol TableDataProviderUseCaseProtocol {
    
    func getLeaveData(completion: @escaping ([CellData], [String: [Absence]], Absence) -> Void)
    
    func getSicknessData(completion: @escaping ([CellData]) -> Void)
    
    func getLeaveTypeData(completion: @escaping ([String: [Absence]]) -> Void)
    
    func getSicknessTypeData(completion: @escaping ([SectionData]) -> Void)
    
    func getDurationData(completion: @escaping ([SectionData]) -> Void)
    
    func getExpandableData(forDate: Date, completion: @escaping ([ExpandableData]) -> Void)
}

class TableDataProviderUseCase: TableDataProviderUseCaseProtocol {
    
    
    
    var tableDataProviderRepository: TableDataProviderRepositoryProtocol?
    
    init(tableDataProviderRepository: TableDataProviderRepositoryProtocol) {
        self.tableDataProviderRepository = tableDataProviderRepository
    }

    func getLeaveData(completion: @escaping ([CellData], [String: [Absence]], Absence) -> Void) {
        tableDataProviderRepository?.getLeaveData(completion: { data, leaveTypeData, absence in
            completion(data, Dictionary(grouping: leaveTypeData, by: { $0.absenceType ?? "" }), absence)
        })
    }
    
    func getSicknessData(completion: @escaping ([CellData]) -> Void) {
        tableDataProviderRepository?.getSicknessData(completion: { data in
            completion(data)
        })
    }
    
    func getLeaveTypeData(completion: @escaping ([String: [Absence]]) -> Void) {
        tableDataProviderRepository?.getLeaveTypeData(completion: { data in
            completion(Dictionary(grouping: data, by: { $0.absenceType ?? "" }))
        })
    }
    
    func getSicknessTypeData(completion: @escaping ([SectionData]) -> Void) {
        tableDataProviderRepository?.getSicknessTypeData(completion: { data in
            completion(data)
        })
    }
    
    func getDurationData(completion: @escaping ([SectionData]) -> Void) {
        tableDataProviderRepository?.getDurationData(completion: { data in
            completion(data)
        })
    }
    
    func getExpandableData(forDate: Date, completion: @escaping ([ExpandableData]) -> Void) {
        tableDataProviderRepository?.getExpandableData(forDate: forDate, completion: { expandableData in
            completion(expandableData)
        })
    }
}
