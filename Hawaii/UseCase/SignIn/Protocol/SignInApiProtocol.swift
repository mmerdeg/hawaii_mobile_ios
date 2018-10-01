//
//  SignInApiProtocol.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/31/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol SignInApiProtocol: GenericRepositoryProtocol {
    func signIn(accessToken: String, completion: @escaping (GenericResponse<(String, User)>) -> Void)
}
