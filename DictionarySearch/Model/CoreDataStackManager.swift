//
//  CoreDataStackManager.swift
//  DictionarySearch
//
//  Created by hwjoy on 2019/5/25.
//  Copyright © 2019 redant. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStackManager: NSObject {

    static let sharedInstance = CoreDataStackManager(name: "DictionarySearch")
    
    private let modelName: String
    
    init(name: String) {
        modelName = name
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DictionarySearch")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                #if DEBUG
                fatalError("Unresolved error \(error), \(error.userInfo)")
                #endif
            }
        })
        return container
    }()
    
    lazy var managedObjectContext = persistentContainer.viewContext
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = managedObjectContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                #if DEBUG
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                #endif
            }
        }
    }
    
    func loadDataFile(fileName: String?, callback: @escaping (_ : Bool) -> Void) {
        guard let filePath = DataFileManager.getFilePath(fileName: fileName) else {
            DispatchQueue.main.async(execute: {
                callback(false)
            })
            return
        }
        
        do {
            // 关键字\t释义\t权重\n
            let fileText = try String(contentsOf: URL(fileURLWithPath: filePath), encoding: .utf8)
            let dataLines = fileText.components(separatedBy: "\n")
            guard dataLines.count > 0 else {
                DispatchQueue.main.async(execute: {
                    callback(false)
                })
                return
            }
            
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.parent = managedObjectContext
            
            for lineItem in dataLines {
                autoreleasepool {
                    let dataItems = lineItem.components(separatedBy: "\t")
                    if dataItems.count == 3 {
                        insertData(key: dataItems[0], paraphrase: dataItems[1], weight: dataItems[2], context: context)
                    }
                }
            }
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    #if DEBUG
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    #endif
                }
            }
            
            DispatchQueue.main.async(execute: {
                callback(true)
            })
        } catch {
            let nserror = error as NSError
            print(nserror.localizedDescription)
            DispatchQueue.main.async(execute: {
                callback(false)
            })
        }
    }

    func insertData(key: String, paraphrase: String, weight: String, context: NSManagedObjectContext) {
        let newData = DictionaryData(context: context)
        newData.key = key
        newData.paraphrase = paraphrase
        newData.weight = Int16(weight) ?? 0
//        print("[D] Insert New Data")
    }
    
}
