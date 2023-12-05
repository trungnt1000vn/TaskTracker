//
//  DatabaseManger.swift
//  tasktracker
//
//  Created by Trung on 05/12/2023.
//

import Foundation
import Firebase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
extension DatabaseManager{
    public func userExists(with email:String,completion:@escaping((Bool)-> Void)){
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            guard  snapshot.value as? [String: Any] != nil else{
                completion(false)
                return
            }
            completion(true)
        })
    }
    public func insertUser(with user: AppUser, completion: @escaping(Bool) -> Void){
        database.child(user.safeEmail).setValue(["first name": user.firstName,
                                                 "last_name": user.lastName], withCompletionBlock:{[weak self] error , _ in
            guard let strongSelf = self else {
                return
            }
            guard error == nil else{
                print("failed to write to database")
                completion(false)
                return
            }
            /*
             users => [
             [
             "name":
             "safe_email":
             ]
             
             ]
             */
            strongSelf.database.child("users").observeSingleEvent(of: .value, with: {
                snapshot in
                if var usersCollection = snapshot.value as? [[String:String]]{
                    //append to user dictionary
                    let newElement: [[String:String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    usersCollection.append(contentsOf: newElement)
                    strongSelf.database.child("users").setValue(usersCollection,withCompletionBlock: { error , _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                else{
                    //create that array
                    let newCollection: [[String:String]] = [
                        ["name": user.firstName + " " + user.lastName,
                         "email": user.safeEmail
                        ]
                    ]
                    strongSelf.database.child("users").setValue(newCollection,withCompletionBlock: { error , _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
            
            completion(true)
        })
    }
    public func getDataFor(path: String, completion :@escaping (Result<Any, Error>) -> Void){
        self.database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    public enum DatabaseError: Error{
        case failedToFetch
    }
}
struct AppUser{
    let firstName: String
    let lastName: String
    let emailAddress: String
    var safeEmail: String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName: String{
        return "\(safeEmail)_profile_picture.png"
    }
}
