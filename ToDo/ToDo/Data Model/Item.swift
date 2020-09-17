//
//  Item.swift
//  ToDo
//
//  Created by Enrique Gongora on 9/16/20.
//  Copyright © 2020 Enrique Gongora. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    // Use dynamic so Realm can monitor if the property changes at runtime
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    // This defines the inverse relationship. So each item has a parent category of type "Category"
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
