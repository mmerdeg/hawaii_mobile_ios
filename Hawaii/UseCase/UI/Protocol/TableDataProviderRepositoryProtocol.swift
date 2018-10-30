//
//  LeaveTypeRepositoryProtocol.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol TableDataProviderRepositoryProtocol: GenericRepositoryProtocol {
    
    func getLeaveData(completion: @escaping ([CellData], [Absence], GenericResponse<[Absence]>) -> Void)
    
    func getSicknessData(completion: @escaping ([CellData], [Absence], GenericResponse<[Absence]>) -> Void)
    
    func getBonusData(completion: @escaping ([CellData], [Absence], GenericResponse<[Absence]>) -> Void)
    
    func getLeaveTypeData(completion: @escaping ([Absence]) -> Void)
        
    func getDurationData(completion: @escaping ([SectionData]) -> Void)
    
    func getMultipleDaysDurationData(completion: @escaping ([SectionData]) -> Void)
    
    func getBonusDaysDurationData(completion: @escaping ([SectionData]) -> Void)
    
    func getExpandableData(forDate: Date, completion: @escaping ([ExpandableData]) -> Void)
}
