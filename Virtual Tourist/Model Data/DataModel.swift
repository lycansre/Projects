//
//  DataModel.swift
//  Virtual Tourist
//
//  Created by Programmer on 20/06/2019.
//  Copyright © 2019 Programmer. All rights reserved.
//

import Foundation
import CoreData

class DataModel {
    static let shared = DataModel()
    
    let virtualTouristPersistentContainer = NSPersistentContainer(name: "CoreData")
    
    var viewContext: NSManagedObjectContext {
        return virtualTouristPersistentContainer.viewContext
    }
    
    func load() {
        virtualTouristPersistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
        }
    }
}
