import Foundation
import Alamofire
import CodableAlamofire

protocol RequestUseCase {
    
    func getAll(completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllForCalendar(completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void)
    
    func getBy(id: Int, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllBy(id: Int, completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void)
    
    func add(request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func updateRequest(request: Request, completion: @escaping (GenericResponse<Request>) -> Void)
    
    func getAllByTeam(from: Date, teamId: Int, completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void)
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void)
    
    func getAvailableRequestYears(completion: @escaping (GenericResponse<Year>) -> Void)
    
    func getAvailableRequestYearsForSearch(completion: @escaping (GenericResponse<Year>) -> Void)
    
    func populateDaysBetween(startDate: Date, endDate: Date, durationType: DurationType) -> [Day]
}

class RequestUseCaseImplementation: RequestUseCase {
    
    let requestRepository: RequestRepository?
    
    let userUseCase: UserUseCase?
    
    init(entityRepository: RequestRepository, userUseCase: UserUseCase) {
        self.requestRepository = entityRepository
        self.userUseCase = userUseCase
    }
    
    func getBy(id: Int, completion: @escaping (GenericResponse<Request>) -> Void) {
        requestRepository?.getBy(id: id, completion: { response in
            completion(response)
        })
    }
    
    func getAll(completion: @escaping (GenericResponse<[Request]>) -> Void) {
        requestRepository?.getAll { requests in
            completion(requests)
        }
    }
    
    func getAllBy(id: Int, completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void) {
        requestRepository?.getAllBy(id: id) { requests in
            completion(self.handle(requests))
        }
    }
    
    func add(request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        requestRepository?.add(request: request) {request in
            completion(request)
        }
    }
    
    func getAllForCalendar(completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void) {
        requestRepository?.getAll { response in
            completion(self.handle(response))
        }
    }
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        userUseCase?.readUser(completion: { user in
            self.requestRepository?.getAllByDate(userId: user?.id ?? -1, from: from, toDate: toDate) { requests in
                completion(requests)
            }
        })
    }
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        requestRepository?.getAllPendingForApprover(approver: approver) { requests in
            completion(requests)
        }
    }
    
    func updateRequest(request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        requestRepository?.updateRequest(request: request) { request in
            completion(request)
        }
    }
    
    func getAllByTeam(from: Date, teamId: Int, completion: @escaping (GenericResponse<[Date: [Request]]>) -> Void) {
        if teamId != -1 {
            requestRepository?.getAllByTeam(date: from, teamId: teamId) { response in
                completion(self.handle(response))
            }
        } else {
            requestRepository?.getAllForAllEmployees(date: from) { response in
                completion(self.handle(response))
            }
        }
    }
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        requestRepository?.getAllForEmployee(byEmail: email) { requestsResponse in
            completion(requestsResponse)
        }
    }
    
    func getAvailableRequestYears(completion: @escaping (GenericResponse<Year>) -> Void) {
        requestRepository?.getAvailableRequestYears { requestsResponse in
            completion(requestsResponse)
        }
    }
    
    func getAvailableRequestYearsForSearch(completion: @escaping (GenericResponse<Year>) -> Void) {
        requestRepository?.getAvailableRequestYearsForSearch(completion: { requestsResponse in
            completion(requestsResponse)
        })
    }
    
    func handle(_ response: GenericResponse<[Request]>?) -> GenericResponse<[Date: [Request]]> {
        if !(response?.success ?? false) {
            return GenericResponse<[Date: [Request]]> (success: response?.success,
                                                       item: nil, statusCode: response?.statusCode,
                                                       error: response?.error,
                                                       message: response?.error?.localizedDescription)
        }
        var dict: [Date: [Request]] = [:]
        response?.item?.forEach({ request in
            request.days?.forEach({ day in
                if (request.requestStatus == RequestStatus.approved ||
                    request.requestStatus == RequestStatus.pending ||
                    request.requestStatus == RequestStatus.cancelationPending) &&
                    request.absence?.absenceType != AbsenceType.bonus.rawValue {
                    if let date = day.date {
                        if dict[date] != nil {
                            if !(dict[date]?.contains(request) ?? true) {
                                dict[date]?.append(request)
                            }
                        } else {
                            dict[date] = [request]
                        }
                    }
                }
            })
        })
        return GenericResponse<[Date: [Request]]> (success: response?.success,
                                                   item: dict, statusCode: response?.statusCode,
                                                   error: response?.error,
                                                   message: response?.error?.localizedDescription)
    }
    
    func populateDaysBetween(startDate: Date, endDate: Date, durationType: DurationType) -> [Day] {
        var days: [Day] = []
      
        switch durationType {
        case .afternoonFirst:
            days.append(Day(id: nil, date: startDate, duration: DurationType.afternoon, requestId: nil))
            for currentDate in getDaysBetweeen(startDate: startDate.tomorrow, endDate: endDate) {
                days.append(Day(id: nil, date: currentDate, duration: DurationType.fullday, requestId: nil))
            }
        case .morningLast:
            for currentDate in getDaysBetweeen(startDate: startDate, endDate: endDate.yesterday) {
                days.append(Day(id: nil, date: currentDate, duration: DurationType.fullday, requestId: nil))
            }
            days.append(Day(id: nil, date: endDate, duration: DurationType.morning, requestId: nil))
        case .morningAndAfternoon:
            days.append(Day(id: nil, date: startDate, duration: DurationType.afternoon, requestId: nil))
            for currentDate in getDaysBetweeen(startDate: startDate.tomorrow, endDate: endDate.yesterday) {
                days.append(Day(id: nil, date: currentDate, duration: DurationType.fullday, requestId: nil))
            }
            days.append(Day(id: nil, date: endDate, duration: DurationType.morning, requestId: nil))
        default:
            for currentDate in getDaysBetweeen(startDate: startDate, endDate: endDate) {
                days.append(Day(id: nil, date: currentDate, duration: durationType, requestId: nil))
            }
        }
        return days
    }
    
    func getDaysBetweeen(startDate: Date, endDate: Date) -> [Date] {
        let components = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
        guard let numberOfDays = components.day else {
            return []
        }
        if Calendar.current.compare(startDate, to: endDate, toGranularity: .day) == .orderedSame {
            return [startDate]
        } else if numberOfDays == 0 {
            return [startDate, endDate]
        }
        var dates: [Date] = []
        for currentDay in 0...numberOfDays {
            dates.append(startDate.addingTimeInterval(24 * 3600 * Double(currentDay)))
        }
        return dates
    }
    
}
