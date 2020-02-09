//
//  StoredInfo.swift
//  timer
//
//  Created by Valerii Petrychenko on 08.02.2020.
//  Copyright © 2020 Valerii Petrychenko. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class StoredInfo: Object {
    @objc dynamic var time: String = ""
    @objc dynamic var info: String = ""
    
    convenience init(time: String, info: String) {
        self.init()
        
        self.time = time
        self.info = info
    }
}
