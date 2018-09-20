//
//  Page.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/20/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct Page: Codable {
    
    let content: [User]?
    let first: Bool?
    let last: Bool?
    let number: Int?
    let numberOfElements: Int?
    let pageable: Pageable?
    let size: Int?
    let sort: Sort?
    let totalElements: Int?
    let totalPages: Int?
}
