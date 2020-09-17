//
//  Category.swift
//  ToDo
//
//  Created by Enrique Gongora on 9/16/20.
//  Copyright © 2020 Enrique Gongora. All rights reserved.
//

import Foundation
import RealmSwift

// This class is a realm object, so we subclass Object
class Category: Object {
    // Use dynamic so Realm can monitor if the property changes at runtime
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
}
