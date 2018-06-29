//
//  LeaveTypeRepositoryProtocol.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol TableDataProviderRepositoryProtocol {
    func getLeaveData(completion: @escaping ([CellData]) -> Void)
    
    func getSicknessData(completion: @escaping ([CellData]) -> Void)
    
    func getLeaveTypeData(completion: @escaping ([SectionData]) -> Void)
    
    func getSicknessTypeData(completion: @escaping ([SectionData]) -> Void)
    
    func getDurationData(completion: @escaping ([SectionData]) -> Void)
}
