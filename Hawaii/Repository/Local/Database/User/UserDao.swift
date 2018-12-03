import Foundation
import FMDB

class UserDao: UserDaoProtocol {
    
    var databaseQueue: FMDatabaseQueue?

    let dispatchQueue: DispatchQueue?

    var createUserQuery: String?

    var deleteUsersQuery: String?
    
    var readUserQuery: String?
    
    var createTokenQuery: String?
    
    var deleteTokensQuery: String?
    
    var readTokenQuery: String?
    
    var readTokensQuery: String?
    
    var deleteTokenQuery: String?

    init(dispatchQueue: DispatchQueue, databaseQueue: FMDatabaseQueue) {
        self.databaseQueue = databaseQueue
        self.dispatchQueue = dispatchQueue
        
        let sqlExtension = "sql"
        let bundle = Bundle.main
        
        guard let createUserUrl = bundle.url(forResource: "createUser", withExtension: sqlExtension),
              let deleteUsersUrl = bundle.url(forResource: "deleteUser", withExtension: sqlExtension),
              let readUserUrl = bundle.url(forResource: "readUser", withExtension: sqlExtension),
              let createTokenUrl = bundle.url(forResource: "createToken", withExtension: sqlExtension),
              let deleteTokensUrl = bundle.url(forResource: "deleteTokens", withExtension: sqlExtension),
              let readTokenUrl = bundle.url(forResource: "readToken", withExtension: sqlExtension),
              let readTokensUrl = bundle.url(forResource: "readTokens", withExtension: sqlExtension),
              let deleteTokenUrl = bundle.url(forResource: "deleteToken", withExtension: sqlExtension) else {
                return
        }
        readUserQuery = (try? String(contentsOf: readUserUrl))
        createUserQuery = (try? String(contentsOf: createUserUrl))
        deleteUsersQuery = (try? String(contentsOf: deleteUsersUrl))
        
        readTokenQuery = (try? String(contentsOf: readTokenUrl))
        createTokenQuery = (try? String(contentsOf: createTokenUrl))
        deleteTokensQuery = (try? String(contentsOf: deleteTokensUrl))
        
        readTokensQuery = (try? String(contentsOf: readTokensUrl))
        deleteTokenQuery = (try? String(contentsOf: deleteTokenUrl))
    }
    
    func create(entity: User, completion: @escaping (Int) -> Void) {
        self.dispatchQueue?.sync {
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
                                          entity.deleted ?? false,
                                          entity.yearsOfService ?? -1]
                    try database.executeUpdate(self.createUserQuery ?? "", values: values)
                    DispatchQueue.main.async {
                        print("Upisao usera")
                        completion(Int(database.lastInsertRowId))
                    }
                } catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        print("Nije upisao usera")
                        completion(-1)
                    }
                }
            }
        }
    }
    
    func create(entity: [PushTokenDTO], userId: Int, completion: @escaping (Int) -> Void) {
        self.dispatchQueue?.sync {
            self.databaseQueue?.inTransaction { database, _ in
                do {
                    for pushToken in entity {
                        let values: [Any] = [ pushToken.pushTokenId ?? -1,
                                              pushToken.name ?? "",
                                              pushToken.platform?.rawValue ?? Platform.iOS.rawValue,
                                              pushToken.pushToken ?? "",
                                              userId]
                        try database.executeUpdate(self.createTokenQuery ?? "", values: values)
                    }
                    DispatchQueue.main.async(execute: {
                        completion(userId)
                    })
                } catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        print("Nije pisao token")
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
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                while resultSet.next() {
                    guard let result = resultSet.resultDictionary as? [String: Any],
                          let userDb = UserDb(parameters: result) else {
                            DispatchQueue.main.async {
                                completion(nil)
                            }
                            return
                    }
                    print("Procitao usera")
                    completion(userDb.toUser())
                }
            }
        }
    }
    
    func emptyUsers(completion: @escaping (Bool) -> Void) {
        dispatchQueue?.sync {
            self.databaseQueue?.inTransaction { database, _ in
                DispatchQueue.main.async {
                    print("Obrisao usere")
                    completion(database.executeStatements(self.deleteUsersQuery ?? ""))
                }
            }
        }
    }
    
    func create(entity: PushTokenDTO, userId: Int, completion: @escaping (Int) -> Void) {
        self.dispatchQueue?.sync {
            self.databaseQueue?.inTransaction { database, _ in
                do {
                    let values: [Any] = [ entity.pushTokenId ?? -1,
                                          entity.name ?? "",
                                          entity.platform?.rawValue ?? Platform.iOS.rawValue,
                                          entity.pushToken ?? "",
                                          userId]
                    try database.executeUpdate(self.createTokenQuery ?? "", values: values)
                    DispatchQueue.main.async {
                        print("Upisao token")
                        completion(Int(database.lastInsertRowId))
                    }
                } catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        print("Nije pisao token")
                        completion(-1)
                    }
                }
            }
        }
    }
    
    func read(userId: Int, completion: @escaping ([PushTokenDTO]?) -> Void) {
        guard let readTokensQuery = readTokensQuery else {
            completion(nil)
            return
        }
        dispatchQueue?.async {
            self.databaseQueue?.inTransaction { database, _ in
                let values: [Any] = [ userId ]
                guard let resultSet = try? database.executeQuery(readTokensQuery, values: values) else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                var tokens: [PushTokenDTO] = []
                while resultSet.next() {
                    guard let result = resultSet.resultDictionary as? [String: Any],
                          let tokenDb = PushTokenDb(parameters: result) else {
                            DispatchQueue.main.async {
                                completion(nil)
                            }
                            return
                    }
                    tokens.append(tokenDb.toPushToken())
                }
                DispatchQueue.main.async {
                    print("Tokeni")
                    completion(tokens)
                }
            }
        }
    }
    
    func read(pushToken: String, completion: @escaping (PushTokenDTO?) -> Void) {
        guard let readTokenQuery = readTokenQuery else {
            completion(nil)
            return
        }
        dispatchQueue?.async {
            self.databaseQueue?.inTransaction { database, _ in
                let values: [Any] = [ pushToken ]
                guard let resultSet = try? database.executeQuery(readTokenQuery, values: values) else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                while resultSet.next() {
                    guard let result = resultSet.resultDictionary as? [String: Any],
                        let tokenDb = PushTokenDb(parameters: result) else {
                            DispatchQueue.main.async {
                                completion(nil)
                            }
                            return
                    }
                    DispatchQueue.main.async {
                        print("Citanje tokena")
                        completion(tokenDb.toPushToken())
                    }
                }
            }
        }
    }
    
    func deleteToken(pushToken: String, completion: @escaping (Bool) -> Void) {
        guard let deleteTokenQuery = deleteTokenQuery else {
            completion(false)
            return
        }
        dispatchQueue?.async {
            self.databaseQueue?.inTransaction { database, _ in
                let values: [Any] = [ pushToken ]
                guard let _ = try? database.executeUpdate(deleteTokenQuery, values: values) else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return
                }
                DispatchQueue.main.async {
                    print("Obrisao token")
                    completion(true)
                }
            }
        }
    }
    
    func deleteTokens(completion: @escaping (Bool) -> Void) {
        dispatchQueue?.sync {
            self.databaseQueue?.inTransaction { database, _ in
                DispatchQueue.main.async {
                    print("Obrisao tokene")
                    completion(database.executeStatements(self.deleteTokensQuery ?? ""))
                }
            }
        }
    }
}
