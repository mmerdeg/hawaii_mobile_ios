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
    let item: T?
    let statusCode: Int?
    let error: Error?
    let message: String?
}

extension GenericResponse {
    init(genericResponse: GenericResponse? = nil, item: T? = nil) {
        self.success = genericResponse?.success
        self.item = item ?? genericResponse?.item
        self.statusCode = genericResponse?.statusCode
        self.error = genericResponse?.error
        self.message = genericResponse?.message
    }
}
