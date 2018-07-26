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
        completion([CellData(title: "Type of leave", description: AbsenceType.vacation.description),
                    CellData(title: "Duration", description: DurationType.fullday.description)])
    }
    
    func getSicknessData(completion: @escaping ([CellData]) -> Void) {
        completion([CellData(title: "Type of sickness", description: "Sick"),
                    CellData(title: "Duration", description: "Full Day")])
    }
    
    func getLeaveTypeData(completion: @escaping ([SectionData]) -> Void) {
        completion([SectionData(name: "Annual Leave", cells: [CellData(title: AbsenceType.vacation.description, description: nil)]),
                                    SectionData(name: "Deducted Leave", cells: [CellData(title: AbsenceType.trainingAndEducation.description, description: nil)]),
                                    SectionData(name: "Non Deducted Leave", cells: [CellData(title: AbsenceType.businessTravel.description, description: nil),
                                                                                    CellData(title: AbsenceType.deliveryOrAdoption.description, description: nil),
                                                                                    CellData(title: AbsenceType.familySaintDay.description, description: nil),
                                                                                    CellData(title: AbsenceType.funeralFamilyMember.description, description: nil),
                                                                                    CellData(title: AbsenceType.maternityLeave.description, description: nil),
                                                                                    CellData(title: AbsenceType.moving.description, description: nil),
                                                                                    CellData(title: AbsenceType.nationalSportCompetition.description, description: nil),
                                                                                    CellData(title: AbsenceType.ownWedding.description, description: nil),
                                                                                    CellData(title: AbsenceType.illnessOfFamilyMember.description,
                                                                                             description: nil),
                                                                                    CellData(title: AbsenceType.workFromHome.description, description: nil)])])
    }
    
    func getSicknessTypeData(completion: @escaping ([SectionData]) -> Void) {
        completion([SectionData(name: "Sickness Type", cells: [CellData(title: "Sick", description: nil),
                                                                    CellData(title: "Veeery sick", description: nil),
                                                                    CellData(title: "Dying", description: nil)])])
    }
    
    func getDurationData(completion: @escaping ([SectionData]) -> Void) {
        completion([SectionData(name: nil, cells: [CellData(title: DurationType.fullday.description, description: nil),
                                                   CellData(title: DurationType.morning.description, description: nil),
                                                   CellData(title: DurationType.afternoon.description, description: nil)])])
    }
}
