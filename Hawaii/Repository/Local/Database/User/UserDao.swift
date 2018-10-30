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

    var emptyUsersQuery: String?
    
    var readUserQuery: String?

    init(dispatchQueue: DispatchQueue, databaseQueue: FMDatabaseQueue) {
        self.databaseQueue = databaseQueue
        self.dispatchQueue = dispatchQueue
        
        let sqlExtension = "sql"
        let bundle = Bundle.main
        
        guard let createUserUrl = bundle.url(forResource: "createUser", withExtension: sqlExtension),
              let emptyUsersUrl = bundle.url(forResource: "deleteUser", withExtension: sqlExtension),
              let readUserUrl = bundle.url(forResource: "readUser", withExtension: sqlExtension) else {
                return
        }
        readUserQuery = (try? String(contentsOf: readUserUrl))
        createUserQuery = (try? String(contentsOf: createUserUrl))
        emptyUsersQuery = (try? String(contentsOf: emptyUsersUrl))
    }
    
    func create(entity: User, completion: @escaping (Int) -> Void) {
        emptyUsers { success in
            if !success {
                return
            }
            self.dispatchQueue?.async {
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
                        print(error.localizedDescription)
                        completion(-1)
                    }
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
    
    func emptyUsers(completion: @escaping (Bool) -> Void) {
        dispatchQueue?.async {
            self.databaseQueue?.inTransaction { database, _ in
                completion(database.executeStatements(self.emptyUsersQuery ?? ""))
            }
        }
    }
}
