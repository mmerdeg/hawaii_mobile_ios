//
//  GenericExpandableData.swift
//  Hawaii
//
//  Created by Ivan Divljak on 12/5/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct GenericExpandableData<T> {
    let item: T?
    let isExpanded: Bool?
}

extension GenericExpandableData {
    init(expandableData: GenericExpandableData, item: T? = nil, isExpanded: Bool? = nil) {
        self.item = item ?? expandableData.item
        self.isExpanded = isExpanded ?? expandableData.isExpanded
    }
    
}
