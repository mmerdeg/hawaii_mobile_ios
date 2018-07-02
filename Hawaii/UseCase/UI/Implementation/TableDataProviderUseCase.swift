//
//  LeaveTypeUseCase.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol TableDataProviderUseCaseProtocol {
    
    func getLeaveData(completion: @escaping ([CellData]) -> Void)
    
    func getSicknessData(completion: @escaping ([CellData]) -> Void)
    
    func getLeaveTypeData(completion: @escaping ([SectionData]) -> Void)
    
    func getSicknessTypeData(completion: @escaping ([SectionData]) -> Void)
    
    func getDurationData(completion: @escaping ([SectionData]) -> Void)
}

class TableDataProviderUseCase: TableDataProviderUseCaseProtocol {
    
    var tableDataProviderRepository: TableDataProviderRepositoryProtocol?

    func getLeaveData(completion: @escaping ([CellData]) -> Void) {
        tableDataProviderRepository?.getLeaveData(completion: { data in
            completion(data)
        })
    }
    
    func getSicknessData(completion: @escaping ([CellData]) -> Void) {
        tableDataProviderRepository?.getSicknessData(completion: { data in
            completion(data)
        })
    }
    
    func getLeaveTypeData(completion: @escaping ([SectionData]) -> Void) {
        tableDataProviderRepository?.getLeaveTypeData(completion: { data in
            completion(data)
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
    
    init(tableDataProviderRepository: TableDataProviderRepositoryProtocol) {
        self.tableDataProviderRepository = tableDataProviderRepository
    }
}
