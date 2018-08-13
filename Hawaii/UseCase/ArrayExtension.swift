//
//  ArrayExtension.swift
//  Hawaii
//
//  Created by Server on 8/10/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key: Element] {
        var dict = [Key: Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}
