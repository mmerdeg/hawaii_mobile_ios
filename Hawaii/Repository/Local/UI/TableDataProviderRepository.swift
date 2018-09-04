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
    
    func getLeaveData(completion: @escaping ([CellData], [Absence], Absence) -> Void) {
        guard let url = URL(string: Constants.leaveTypes) else {
            return
        }
        let queue = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
        Alamofire.request(url).responseDecodableObject { (response: DataResponse<[Absence]>) in
           completion([CellData(title: "Type of leave", description: response.result.value?.first?.name),
             CellData(title: "Duration", description: DurationType.fullday.description)],
                      response.result.value ?? [],
                      response.result.value?.first ?? Absence())
        }
    }
    
    func getSicknessData(completion: @escaping ([CellData]) -> Void) {
        completion([CellData(title: "Type of sickness", description: "Sick"),
                    CellData(title: "Duration", description: "Full Day")])
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
    
    func getExpandableData(forDate: Date, completion: @escaping ([ExpandableData]) -> Void) {
       completion([ExpandableData(id: 0, expanded: true, title: "Start date", description: forDate),
        ExpandableData(expanded: false, description: forDate),
        ExpandableData(id: 0, expanded: true, title: "End date", description: forDate),
        ExpandableData(expanded: false, description: forDate)])
    }
    
}
