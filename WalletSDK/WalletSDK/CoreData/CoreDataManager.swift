//
//  WalletDataModel.swift
//  WalletSDK
//
//  Created by dong jun park on 4/25/24.
//

import Foundation
import CoreData

class CoreDataManager {
    
    public static let shared = CoreDataManager()
    let identifier: String  = "org.omnione.did.sdk.wallet"
    let model: String       = "WalletModel"
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let messageKitBundle = Bundle(identifier: self.identifier)
        let modelURL = messageKitBundle!.url(forResource: self.model, withExtension: "momd")!
        let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: self.model, managedObjectModel: managedObjectModel!)
        container.loadPersistentStores { (storeDescription, error) in
        
            if let err = error{
                fatalError("Loading of store failed:\(err)")
            }
            print("succeed")
        }
        
        return container
    }()
    
    @discardableResult
    public func insertCaPakage(pkgName: String) -> Bool {
            
        let context = persistentContainer.viewContext
        let ca = NSEntityDescription.insertNewObject(forEntityName: "CaEntity", into: context) as! CaEntity
        ca.idx = UUID().uuidString
        ca.pkgName = pkgName
        ca.createDate = DateUtil.calculateTimeAfter(min: 0, sec: 0)
        
        do {
            try context.save()
            print("Ca saved succesfully")
            print("CaAppId \(String(describing: ca.idx)): \(String(describing: ca.pkgName)) \(String(describing: ca.createDate))")
            return true
            
        } catch let error {
            print("Failed to insert Ca: \(error.localizedDescription)")
        }
        return false
    }
    
    public func selectCaPakage() -> Ca? {
            
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<CaEntity>(entityName: "CaEntity")
        
        do {
            let cas = try context.fetch(fetchRequest)
            for (_, ca) in cas.enumerated() {
                print("CaAppId \(String(describing: ca.idx)): \(String(describing: ca.pkgName)) \(String(describing: ca.createDate))")
                return Ca(idx: ca.idx!, createDate: ca.createDate!, pkgName: ca.pkgName!)
            }
            
        } catch let fetchErr {
            print("Failed to fetch Person:",fetchErr)
        }
        
        return nil
    }
    
    @discardableResult
    public func deleteCaPakage() -> Bool {
        
        let context = persistentContainer.viewContext
        // 모든 데이터 요청
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CaEntity")

        do {
            let objects = try context.fetch(fetchRequest)
            for case let object as NSManagedObject in objects {
                context.delete(object) // 데이터 삭제
            }
            try context.save() // 변경 사항 저장
            return true
        } catch {
            print("Delete failed: \(error)")
        }
        
        return false
    }
    
    @discardableResult
    public func insertToken(walletId: String, hWalletToken: String, purpose: String, pkgName: String, nonce: String, pii: String) -> Bool {
        deleteToken()
        let context = persistentContainer.viewContext
        let token = NSEntityDescription.insertNewObject(forEntityName: "TokenEntity", into: context) as! TokenEntity
        token.idx = UUID().uuidString
        token.walletId = walletId
        token.hWalletToken = hWalletToken
        token.purpose = purpose
        token.pkgName = pkgName
        token.nonce = nonce
        token.pii = pii
        token.validUntil = DateUtil.calculateTimeAfter(min: 30, sec: 0)
        token.createDate = DateUtil.calculateTimeAfter(min: 0, sec: 0)
        
        do {
            try context.save()
            print("token saved succesfully")
            print("save Token idx: \(String(describing: token.idx)) pkgName: \(String(describing: token.pkgName)) walletId: \(String(describing: token.walletId)) hWalletToken: \(String(describing: token.hWalletToken)) nonce: \(String(describing: token.nonce)) pii: \(String(describing: token.pii)) validUntil:  \(String(describing: token.validUntil)) createDate: \(String(describing: token.createDate)) purpose: \(String(describing: token.purpose))")
            return true
        } catch let error {
            print("Failed to insert token: \(error.localizedDescription)")
        }
        return false
    }
    
    public func selectToken() -> Token? {
            
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TokenEntity>(entityName: "TokenEntity")
        
        do {
            let tokens = try context.fetch(fetchRequest)
            for (_, token) in tokens.enumerated() {
                print("select Token idx: \(String(describing: token.idx)) pkgName: \(String(describing: token.pkgName)) walletId: \(String(describing: token.walletId)) hWalletToken: \(String(describing: token.hWalletToken)) nonce: \(String(describing: token.nonce)) pii: \(String(describing: token.pii)) validUntil:  \(String(describing: token.validUntil)) createDate: \(String(describing: token.createDate)) purpose: \(String(describing: token.purpose))")
                
                return Token(idx: token.idx!, walletId: token.walletId!, hWalletToken: token.hWalletToken!, validUntil: token.validUntil!, purpose: token.purpose!, nonce: token.nonce!, pkgName: token.pkgName!, pii: token.pii!, createDate: token.createDate!)
            }
            
        } catch let fetchErr {
            print("Failed to fetch Person:",fetchErr)
        }
        
        return nil
    }
    
    @discardableResult
    public func deleteToken() -> Bool {
        
        let context = persistentContainer.viewContext
        // 모든 데이터 요청
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TokenEntity")

        do {
            let objects = try context.fetch(fetchRequest)
            for case let object as NSManagedObject in objects {
                context.delete(object) // 데이터 삭제
            }
            try context.save() // 변경 사항 저장
            return true
        } catch {
            print("Delete failed: \(error)")
        }
        
        return false
    }
    
    @discardableResult
    public func insertUser(finalEncKey: String, pii: String) -> Bool {
            
        self.deleteUser()
        let context = persistentContainer.viewContext
        let user = NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: context) as! UserEntity
        user.idx = UUID().uuidString
        user.finalEncKey = finalEncKey
        user.pii = pii
        user.createDate = DateUtil.calculateTimeAfter(min: 0, sec: 0)
//        user.updateDate = DateUtil.calculateTimeAfter(min: 0, sec: 0)
        
        do {
            try context.save()
            print("user saved succesfully")
            print("save User idx: \(String(describing: user.idx)) pii: \(String(describing: user.pii)) createDate: \(String(describing: user.createDate)) finalEncKey: \(String(describing: user.finalEncKey))")
            return true
        } catch let error {
            print("Failed to insert user: \(error.localizedDescription)")
        }
        return false
    }
    
    public func selectUser() -> User? {
            
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        
        do {
            let users = try context.fetch(fetchRequest)
            for (_, user) in users.enumerated() {
                print("select User idx: \(String(describing: user.idx)) pii: \(String(describing: user.pii)) createDate: \(String(describing: user.createDate)) finalEncKey: \(String(describing: user.finalEncKey))")
                
                return User(idx: user.idx ?? "", pii: user.pii ?? "", finalEncKey: user.finalEncKey ?? "", createDate: user.createDate ?? "", updateDate: user.updateDate ?? "")
            }
            
        } catch let fetchErr {
            print("Failed to select Person:",fetchErr)
        }
        
        return nil
    }
    
    public func updateUser(finalEncKey: String) -> Bool {
        print("enc: \(finalEncKey)")
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        fetchRequest.predicate = NSPredicate(format: "finalEncKey == %@", "")

        do {
            let users = try context.fetch(fetchRequest)
            
            if let user = users.first {
                print("updateUser finalEncKey: \(finalEncKey)")
                user.finalEncKey = finalEncKey
            }
            
            try context.save()
            return true
        } catch {
            print("Failed to update finalCek value: \(error)")
        }
        return false
    }
    
    @discardableResult
    public func deleteUser() -> Bool {
        
        let context = persistentContainer.viewContext
        // 모든 데이터 요청
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")

        do {
            let objects = try context.fetch(fetchRequest)
            for case let object as NSManagedObject in objects {
                context.delete(object) // 데이터 삭제
            }
            try context.save() // 변경 사항 저장
            return true
        } catch {
            print("Delete failed: \(error)")
        }
        
        return false
    }
}
