//
//  LeaveTypeRepositoryProtocol.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol TableDataProviderRepositoryProtocol {
    
    func getLeaveData(completion: @escaping ([CellData], [Absence], Absence) -> Void)
    
    func getSicknessData(completion: @escaping ([CellData]) -> Void)
    
    func getLeaveTypeData(completion: @escaping ([Absence]) -> Void)
    
    func getSicknessTypeData(completion: @escaping ([SectionData]) -> Void)
    
    func getDurationData(completion: @escaping ([SectionData]) -> Void)
    
    func getMultipleDaysDurationData(completion: @escaping ([SectionData]) -> Void)
    
    func getExpandableData(forDate: Date, completion: @escaping ([ExpandableData]) -> Void)
    
}
