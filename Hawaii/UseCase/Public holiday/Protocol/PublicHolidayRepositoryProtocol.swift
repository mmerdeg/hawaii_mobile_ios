//
//  ProtocolRepositoryProtocol.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/7/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol PublicHolidayRepositoryProtocol {
    func getHolidays(completion: @escaping (PublicHolidayResponse?) -> Void)
}
