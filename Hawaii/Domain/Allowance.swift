//
//  Allowance.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/31/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct Allowance: Codable {
    
    let id: Int?
    let year: Int?
    let annual: Int?
    let takenAnnual: Int?
    let pendingAnnual: Int?
    let sickness: Int?
    let bonus: Int?
    let carriedOver: Int?
    let manualAdjust: Int?
    let training: Int?
    let pendingTraining: Int?
    let takenTraining: Int?
    
}
