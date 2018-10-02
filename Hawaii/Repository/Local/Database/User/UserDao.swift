//
//  UserDao.swift
//  Hawaii
//
//  Created by Server on 9/28/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import FMDB

class UserDao: UserDaoProtocol {
    
    var databaseQueue: FMDatabaseQueue?

    let dispatchQueue: DispatchQueue?

    var createUserQuery: String?

    var readUserQuery: String?

    init(dispatchQueue: DispatchQueue, databaseQueue: FMDatabaseQueue) {
        self.databaseQueue = databaseQueue
        self.dispatchQueue = dispatchQueue
        let bundle = Bundle.main
        guard let createUserUrl = bundle.url(forResource: "createUser", withExtension: Constants.sqlExtension),
              let readUserUrl = bundle.url(forResource: "readUser", withExtension: Constants.sqlExtension) else {
                return
        }
        readUserQuery = (try? String(contentsOf: readUserUrl))
        createUserQuery = (try? String(contentsOf: createUserUrl))
    }
    
    func create(entity: User, completion: @escaping (Int) -> Void) {
        dispatchQueue?.async {
            self.databaseQueue?.inTransaction { database, _ in
                do {
                    let values: [Any] = [ entity.id ?? -1,
                                          entity.teamId ?? -1,
                                          entity.leaveProfileId ?? -1,
                                          entity.fullName ?? "",
                                          entity.email ?? "",
                                          entity.userRole ?? "",
                                          entity.jobTitle ?? "",
                                          entity.active ?? false,
                                          entity.yearsOfService ?? -1]
                    try database.executeUpdate(self.createUserQuery ?? "", values: values)
                    
                    completion(Int(database.lastInsertRowId))
                } catch {
                    completion(-1)
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func read(completion: @escaping (User?) -> Void) {
        guard let readUserQuery = readUserQuery else {
            completion(nil)
            return
        }
        dispatchQueue?.async {
            self.databaseQueue?.inTransaction { database, _ in
                guard let resultSet = try? database.executeQuery(readUserQuery, values: nil) else {
                    completion(nil)
                    return
                }
                while resultSet.next() {
                    guard let result = resultSet.resultDictionary as? [String: Any],
                          let userDb = UserDb(parameters: result) else {
                            completion(nil)
                            return
                    }
                    completion(userDb.toUser())
                }
            }
        }
    }
}