//
//  SectionData.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct SectionData {
    
    let name: String?
    let cells: [CellData]?
    
}

extension SectionData {
    
    init(sectionData: SectionData? = nil, name: String? = nil, cells: [CellData]? = nil) {
        self.name = name ?? sectionData?.name
        self.cells = cells ?? sectionData?.cells
    }
    
}
