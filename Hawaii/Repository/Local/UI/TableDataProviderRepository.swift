//
//  LeaveTypeRepository.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

class TableDataProviderRepository: TableDataProviderRepositoryProtocol {
    func getLeaveData(completion: @escaping ([CellData]) -> Void) {
        completion([CellData(title: "Type of leave", description: "Vacation"),
                    CellData(title: "Duration", description: "Full Day")])
    }
    
    func getSicknessData(completion: @escaping ([CellData]) -> Void) {
        completion([CellData(title: "Type of sickness", description: "Sick"),
                    CellData(title: "Duration", description: "Full Day")])
    }
    
    func getLeaveTypeData(completion: @escaping ([SectionData]) -> Void) {
        completion([SectionData(name: "Annual Leave", cells: [CellData(title: "Annual leave - Vacation", description: nil)]),
                                    SectionData(name: "Deducted Leave", cells: [CellData(title: "Training & Education", description: nil)]),
                                    SectionData(name: "Non Deducted Leave", cells: [CellData(title: "Business travel", description: nil),
                                                                                    CellData(title: "Delivery or adoption", description: nil),
                                                                                    CellData(title: "Family Saint day", description: nil),
                                                                                    CellData(title: "Funeral family member", description: nil),
                                                                                    CellData(title: "Maternity Leave", description: nil),
                                                                                    CellData(title: "Moving", description: nil),
                                                                                    CellData(title: "National sport competition", description: nil),
                                                                                    CellData(title: "Own wedding", description: nil),
                                                                                    CellData(title: "Serious illness of close family member",
                                                                                             description: nil),
                                                                                    CellData(title: "Work from home", description: nil)])])
    }
    
    func getSicknessTypeData(completion: @escaping ([SectionData]) -> Void) {
        completion([SectionData(name: "Sickness Type", cells: [CellData(title: "Sick", description: nil),
                                                                    CellData(title: "Veeery sick", description: nil),
                                                                    CellData(title: "Dying", description: nil)])])
    }
    
    func getDurationData(completion: @escaping ([SectionData]) -> Void) {
        completion([SectionData(name: nil, cells: [CellData(title: "Morning only", description: nil),
                                                   CellData(title: "Afternoon only", description: nil),
                                                   CellData(title: "Full Day", description: nil)])])
    }
}
