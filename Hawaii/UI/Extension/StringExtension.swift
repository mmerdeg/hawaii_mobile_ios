//
//  StringExtension.swift
//  Hawaii
//
//  Created by Ivan Divljak on 10/5/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
