//
//  SignInApiProtocol.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/31/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol SignInApiProtocol: GenericResponseProtocol {
    func signIn(accessToken: String, completion: @escaping (GenericResponseSingle<String>) -> Void)
}
