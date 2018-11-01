import Foundation
import CodableAlamofire
import Alamofire

class TableDataProviderRepository: TableDataProviderRepositoryProtocol {
    
    let leaveTypesUrl = ApiConstants.baseUrl  + "/leavetypes"
    
    func getLeaveData(completion: @escaping ([CellData], [Absence], GenericResponse<[Absence]>) -> Void) {
        guard let url = URL(string: leaveTypesUrl) else {
            return
        }
        genericCodableRequest(value: [Absence].self, url) { response in
            let filteredAbsences = response.item?.filter({
                $0.absenceType == AbsenceType.deducted.rawValue ||
                    $0.absenceType == AbsenceType.nonDecuted.rawValue
            })
            
            completion([CellData(title: LocalizedKeys.Request.leaveType.localized(), description: filteredAbsences?.first?.name),
                        CellData(title: LocalizedKeys.Request.duration.localized(), description: DurationType.fullday.description)],
                       filteredAbsences ?? [],
                       GenericResponse<[Absence]>(genericResponse: response, item: filteredAbsences))
        }
    }
    
    func getSicknessData(completion: @escaping ([CellData], [Absence], GenericResponse<[Absence]>) -> Void) {
        guard let url = URL(string: leaveTypesUrl) else {
            return
        }
        
        genericCodableRequest(value: [Absence].self, url) { response in
            let filteredAbsences = response.item?.filter({
                $0.absenceType == AbsenceType.sick.rawValue
            })
            completion([CellData(title: LocalizedKeys.Request.sicknessType.localized(), description: filteredAbsences?.first?.name),
                        CellData(title: LocalizedKeys.Request.duration.localized(), description: DurationType.fullday.description)],
                       filteredAbsences ?? [],
                       GenericResponse<[Absence]>(genericResponse: response, item: filteredAbsences))
        }
    }
    
    func getBonusData(completion: @escaping ([CellData], [Absence], GenericResponse<[Absence]>) -> Void) {
        guard let url = URL(string: leaveTypesUrl) else {
            return
        }
        
        genericCodableRequest(value: [Absence].self, url) { response in
            let filteredAbsences = response.item?.filter({
                $0.absenceType == AbsenceType.bonus.rawValue
            })
            
            completion([CellData(title: LocalizedKeys.Request.duration.localized(), description: DurationType.fullday.description)],
                       filteredAbsences ?? [],
                       GenericResponse<[Absence]>(genericResponse: response, item: filteredAbsences))
        }
        
    }
    
    func getLeaveTypeData(completion: @escaping ([Absence]) -> Void) {
        guard let url = URL(string: leaveTypesUrl) else {
            return
        }
        Alamofire.request(url).responseDecodableObject { (response: DataResponse<[Absence]>) in
            completion(response.result.value ?? [])
        }
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
       completion([ExpandableData(id: 0, expanded: true, title: LocalizedKeys.Request.startDate.localized(), description: forDate),
                   ExpandableData(id: 0, expanded: true, title: LocalizedKeys.Request.endDate.localized(), description: forDate)])
    }
    
    func getBonusDaysDurationData(completion: @escaping ([SectionData]) -> Void) {
        completion([SectionData(name: nil, cells: [CellData(title: DurationType.fullday.description, description: nil)])])
    }
    
}
