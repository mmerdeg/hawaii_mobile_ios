//
//  EncodableExtension.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/5/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

extension Encodable {
    var dictionary: [String: Any]? {
        let encoder = JSONEncoder()
        let formatter = RequestDateFormatter()
        
        encoder.dateEncodingStrategy = .formatted(formatter)
        
        guard let data = try? encoder.encode(self) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
