//
//  DataController.swift
//  my Virtual Tourist
// as in MooSkine //
//  Created by Raafat Ali on 28/01/2019.
//  Copyright © 2019 Raafat Ali. All rights reserved.
//

import Foundation
import CoreData

class DataController {
   let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    var bgContext:NSManagedObjectContext! // background context
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    // contexts Configuration
    func ContextConfiguration() {
        bgContext = persistentContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        bgContext.automaticallyMergesChangesFromParent = true
        
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    
    func load(completion: (() -> Void)? = nil ) {
        persistentContainer.loadPersistentStores { (storeDescription, err) in
            guard err == nil else { fatalError(err as! String)}
            
         self.autoSaveViewContext()
         self.ContextConfiguration()
            completion?()
        }
   
    }
    
    
    
}




extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30){
       // print("autosaving")
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
