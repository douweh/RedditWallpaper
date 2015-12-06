//
//  Wallpaper+CoreDataProperties.swift
//  
//
//  Created by Douwe Homans on 12/6/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Wallpaper {

    @NSManaged var createdAt: NSDate?
    @NSManaged var name: String?
    @NSManaged var path: String?
    @NSManaged var remoteId: String?
    @NSManaged var remoteUrl: String?

}
