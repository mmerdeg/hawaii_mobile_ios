//
//  ExpandableData.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/30/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct ExpandableData {
    
    let id: Int?
    let expanded: Bool?
    let title: String?
    let description: Date?
    
}

extension ExpandableData {
    
    init(expandableData: ExpandableData? = nil, id: Int? = nil, expanded: Bool? = nil, title: String? = nil, description: Date? = nil) {
        self.expanded = expanded ?? expandableData?.expanded
        self.title = title ?? expandableData?.title
        self.description = description ?? expandableData?.description
        self.id = id ?? expandableData?.id
    }
    
    init(expanded: Bool, description: Date) {
        self.expanded = expanded
        self.title = ""
        self.description = description
        self.id = 1
    }
    
}

extension ExpandableData: Equatable {
    static func == (lhs: ExpandableData, rhs: ExpandableData) -> Bool {
        return lhs.expanded == rhs.expanded &&
            lhs.title == rhs.title &&
            lhs.description == rhs.description &&
            lhs.id == rhs.id
    }
}
