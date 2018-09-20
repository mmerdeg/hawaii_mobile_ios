//
//  Pagable.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/20/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct Pageable: Codable {
    
    let offset: Int?
    let pageNumber: Int?
    let pageSize: Int?
    let paged: Bool?
    let unpaged: Bool?
    let sort: Sort?
}
