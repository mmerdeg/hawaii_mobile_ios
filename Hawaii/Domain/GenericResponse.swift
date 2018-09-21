//
//  GenericResponse.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/21/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct GenericResponse<T> {
    let success: Bool?
    let items: [T]?
    let error: Error?
    let message: String?
}

struct GenericResponseSingle<T> {
    let success: Bool?
    let item: T?
    let error: Error?
    let message: String?
}
