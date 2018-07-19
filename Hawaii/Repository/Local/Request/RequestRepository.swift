//
//  RequestRepository.swift
//  Hawaii
//
//  Created by Server on 6/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

class RequestRepository: RequestRepositoryProtocol {
    func getAll(completion: @escaping ([Request]) -> Void) {
        print(Date())
        //2018-06-28 11:41:55 +0000
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss Z"
        let absence1 = Absence(id: 1, comment: "", absenceType: AbsenceType.vacation, deducted: false, active: true, name: "")
        let absence2 = Absence(id: 2, comment: "", absenceType: AbsenceType.business, deducted: true, active: true, name: "")
        let absence3 = Absence(id: 3, comment: "", absenceType: AbsenceType.workFromHome, deducted: true, active: true, name: "")
        let day1 = Day(id: 1, date: formatter.date(from: "2018-06-01 00:00:00 +0000") ?? Date(), duration: .morning)
        let day2 = Day(id: 2, date: formatter.date(from: "2018-06-02 00:00:00 +0000") ?? Date(), duration: .afternoon)
        let day3 = Day(id: 3, date: formatter.date(from: "2018-06-03 00:00:00 +0000") ?? Date(), duration: .fullday)
        let day4 = Day(id: 4, date: formatter.date(from: "2018-06-05 00:00:00 +0000") ?? Date(), duration: .morning)
        let day5 = Day(id: 5, date: formatter.date(from: "2018-06-06 00:00:00 +0000") ?? Date(), duration: .afternoon)
        let day6 = Day(id: 6, date: formatter.date(from: "2018-06-07 00:00:00 +0000") ?? Date(), duration: .fullday)
        let day7 = Day(id: 7, date: formatter.date(from: "2018-06-09 00:00:00 +0000") ?? Date(), duration: .morning)
        let day8 = Day(id: 8, date: formatter.date(from: "2018-06-10 00:00:00 +0000") ?? Date(), duration: .afternoon)
        let day9 = Day(id: 9, date: formatter.date(from: "2018-06-11 00:00:00 +0000") ?? Date(), duration: .fullday)
        let day10 = Day(id: 10, date: formatter.date(from: "2018-06-13 00:00:00 +0000") ?? Date(), duration: .morning)
        let day11 = Day(id: 11, date: formatter.date(from: "2018-06-13 00:00:00 +0000") ?? Date(), duration: .afternoon)
        
        let day12 = Day(id: 10, date: formatter.date(from: "2018-06-18 00:00:00 +0000") ?? Date(), duration: .morning)
        let day13 = Day(id: 11, date: formatter.date(from: "2018-06-18 00:00:00 +0000") ?? Date(), duration: .afternoon)
        
        let day20 = Day(id: 3, date: formatter.date(from: "2018-06-20 00:00:00 +0000") ?? Date(), duration: .fullday)
        let day21 = Day(id: 3, date: formatter.date(from: "2018-06-21 00:00:00 +0000") ?? Date(), duration: .fullday)
        let day22 = Day(id: 3, date: formatter.date(from: "2018-06-22 00:00:00 +0000") ?? Date(), duration: .fullday)
        let day23 = Day(id: 3, date: formatter.date(from: "2018-06-23 00:00:00 +0000") ?? Date(), duration: .fullday)
        let request1 = Request(id: 1, days: [day20, day21, day22, day23], reason: "Odo na more", requestStatus: RequestStatus.approved,
                               absence: absence1)
        
        let request2 = Request(id: 1, days: [day1], reason: "Rad od kuce", requestStatus: RequestStatus.approved, absence: absence3)
        let request3 = Request(id: 2, days: [day2], reason: "Rad od kuce", requestStatus: RequestStatus.rejected, absence: absence3)
        let request4 = Request(id: 3, days: [day3], reason: "Rad od kuce", requestStatus: RequestStatus.pending, absence: absence3)
        
        let request5 = Request(id: 4, days: [day4], reason: "Dosta mi je posla", requestStatus: RequestStatus.approved, absence: absence1)
        let request6 = Request(id: 5, days: [day5], reason: "Dosta mi je posla", requestStatus: RequestStatus.rejected, absence: absence1)
        let request7 = Request(id: 6, days: [day6], reason: "Dosta mi je posla", requestStatus: RequestStatus.pending, absence: absence1)
        
        let request8 = Request(id: 7, days: [day7], reason: "Konferencija", requestStatus: RequestStatus.approved, absence: absence2)
        let request9 = Request(id: 8, days: [day8], reason: "Konferencija", requestStatus: RequestStatus.rejected, absence: absence2)
        let request10 = Request(id: 9, days: [day9], reason: "Konferencija", requestStatus: RequestStatus.pending, absence: absence2)
        
        let request11 = Request(id: 11, days: [day10], reason: "Odmaranje", requestStatus: RequestStatus.pending, absence: absence1)
        let request12 = Request(id: 12, days: [day11], reason: "Rad od kuce", requestStatus: RequestStatus.rejected, absence: absence3)
        
        let request13 = Request(id: 11, days: [day12], reason: "Konferencija", requestStatus: RequestStatus.approved, absence: absence2)
        let request14 = Request(id: 12, days: [day13], reason: "Rad od kuce", requestStatus: RequestStatus.approved, absence: absence3)
        
        completion([request1, request2, request3, request4, request5, request6, request7, request8, request9, request10, request11, request12,
                    request13, request14])
    }
}
