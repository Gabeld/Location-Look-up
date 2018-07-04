//
//  City.swift
//  SearchImplem
//
//  Created by Alex Dinu on 28/06/2018.
//  Copyright © 2018 Alex Dinu. All rights reserved.
//

import Foundation

class City: NSObject {
    
    let name: String
    let country: String
    let adminName: String
    
    init(name: String, country: String, adminName: String) {
        self.name = name
        self.country = country
        self.adminName = adminName
    }
}
