//
//  LeaveTypeRepository.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import CodableAlamofire
import Alamofire

class TableDataProviderRepository: TableDataProviderRepositoryProtocol {
    
    func getLeaveData(completion: @escaping ([CellData], [Absence], GenericResponse<[Absence]>) -> Void) {
        guard let url = URL(string: Constants.leaveTypes) else {
            return
        }
        genericRequest(value: [Absence].self, url) { response in
            let filteredAbsences = response.item?.filter({
                $0.absenceType == AbsenceType.deducted.rawValue ||
                    $0.absenceType == AbsenceType.nonDecuted.rawValue
            })
            
            completion([CellData(title: "Type of leave", description: filteredAbsences?.first?.name),
                        CellData(title: "Duration", description: DurationType.fullday.description)],
                       filteredAbsences ?? [],
                       GenericResponse<[Absence]>(genericResponse: response, item: filteredAbsences))
        }
    }
    
    func getSicknessData(completion: @escaping ([CellData], [Absence], GenericResponse<[Absence]>) -> Void) {
        guard let url = URL(string: Constants.leaveTypes) else {
            return
        }
        
        genericRequest(value: [Absence].self, url) { response in
            let filteredAbsences = response.item?.filter({
                $0.absenceType == AbsenceType.sick.rawValue
            })
            completion([CellData(title: "Type of leave", description: filteredAbsences?.first?.name),
                        CellData(title: "Duration", description: DurationType.fullday.description)],
                       filteredAbsences ?? [],
                       GenericResponse<[Absence]>(genericResponse: response, item: filteredAbsences))
        }
    }
    
    func getBonusData(completion: @escaping ([CellData], [Absence], GenericResponse<[Absence]>) -> Void) {
        guard let url = URL(string: Constants.leaveTypes) else {
            return
        }
        
        genericRequest(value: [Absence].self, url) { response in
            let filteredAbsences = response.item?.filter({
                $0.absenceType == AbsenceType.bonus.rawValue
            })
            
            completion([CellData(title: "Duration", description: DurationType.fullday.description)],
                       filteredAbsences ?? [],
                       GenericResponse<[Absence]>(genericResponse: response, item: filteredAbsences))
        }
        
    }
    
    func getLeaveTypeData(completion: @escaping ([Absence]) -> Void) {
        guard let url = URL(string: Constants.leaveTypes) else {
            return
        }
        Alamofire.request(url).responseDecodableObject { (response: DataResponse<[Absence]>) in
            completion(response.result.value ?? [])
        }
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
    
    func getMultipleDaysDurationData(completion: @escaping ([SectionData]) -> Void) {
        completion([SectionData(name: nil, cells: [CellData(title: DurationType.fullday.description, description: nil),
                                                   CellData(title: DurationType.afternoonFirst.description, description: nil),
                                                   CellData(title: DurationType.morningLast.description, description: nil),
                                                   CellData(title: DurationType.morningAndAfternoon.description, description: nil)])])
    }
    
    func getExpandableData(forDate: Date, completion: @escaping ([ExpandableData]) -> Void) {
       completion([ExpandableData(id: 0, expanded: true, title: "Start date", description: forDate),
                   ExpandableData(id: 0, expanded: true, title: "End date", description: forDate)])
    }
    
    func getBonusDaysDurationData(completion: @escaping ([SectionData]) -> Void) {
        completion([SectionData(name: nil, cells: [CellData(title: DurationType.fullday.description, description: nil)])])
    }
    
}
