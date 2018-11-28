import Foundation
import FMDB

class UserDao: UserDaoProtocol {
    
    var databaseQueue: FMDatabaseQueue?

    let dispatchQueue: DispatchQueue?

    var createUserQuery: String?

    var emptyUsersQuery: String?
    
    var readUserQuery: String?
    
    var createTokenQuery: String?
    
    var emptyTokenQuery: String?
    
    var readTokenQuery: String?

    init(dispatchQueue: DispatchQueue, databaseQueue: FMDatabaseQueue) {
        self.databaseQueue = databaseQueue
        self.dispatchQueue = dispatchQueue
        
        let sqlExtension = "sql"
        let bundle = Bundle.main
        
        guard let createUserUrl = bundle.url(forResource: "createUser", withExtension: sqlExtension),
              let emptyUsersUrl = bundle.url(forResource: "deleteUser", withExtension: sqlExtension),
              let readUserUrl = bundle.url(forResource: "readUser", withExtension: sqlExtension),
              let createTokenUrl = bundle.url(forResource: "createToken", withExtension: sqlExtension),
              let emptyTokenUrl = bundle.url(forResource: "deleteToken", withExtension: sqlExtension),
              let readTokenUrl = bundle.url(forResource: "readToken", withExtension: sqlExtension) else {
                return
        }
        readUserQuery = (try? String(contentsOf: readUserUrl))
        createUserQuery = (try? String(contentsOf: createUserUrl))
        emptyUsersQuery = (try? String(contentsOf: emptyUsersUrl))
        
        readTokenQuery = (try? String(contentsOf: readTokenUrl))
        createTokenQuery = (try? String(contentsOf: createTokenUrl))
        emptyTokenQuery = (try? String(contentsOf: emptyTokenUrl))
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
                                              entity.teamName ?? "",
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
    
    func create(entity: PushTokenDTO, completion: @escaping (Int) -> Void) {
        deleteTokens { success in
            if !success {
                return
            }
            self.dispatchQueue?.async {
                self.databaseQueue?.inTransaction { database, _ in
                    do {
                        let values: [Any] = [ entity.pushTokenId ?? -1,
                                              entity.name ?? "",
                                              entity.platform ?? Platform.iOS,
                                              entity.pushToken ?? ""]
                        try database.executeUpdate(self.createTokenQuery ?? "", values: values)
                        completion(Int(database.lastInsertRowId))
                    } catch {
                        print(error.localizedDescription)
                        completion(-1)
                    }
                }
            }
        }
    }
    
    func read(completion: @escaping (PushTokenDTO?) -> Void) {
        guard let readTokenQuery = readTokenQuery else {
            completion(nil)
            return
        }
        dispatchQueue?.async {
            self.databaseQueue?.inTransaction { database, _ in
                guard let resultSet = try? database.executeQuery(readTokenQuery, values: nil) else {
                    completion(nil)
                    return
                }
                while resultSet.next() {
                    guard let result = resultSet.resultDictionary as? [String: Any],
                        let tokenDb = PushTokenDb(parameters: result) else {
                            completion(nil)
                            return
                    }
                    completion(tokenDb.toPushToken())
                }
            }
        }
    }
    
    func deleteTokens(completion: @escaping (Bool) -> Void) {
        dispatchQueue?.async {
            self.databaseQueue?.inTransaction { database, _ in
                completion(database.executeStatements(self.emptyTokenQuery ?? ""))
            }
        }
    }
}
