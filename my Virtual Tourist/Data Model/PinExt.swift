//
//  PinExt.swift
//  my Virtual Tourist
//
//  Created by Raafat Ali on 28/01/2019.
//  Copyright © 2019 Raafat Ali. All rights reserved.
//

import Foundation
import  CoreData
// Mark: Managed Object Pin - extention.
extension Pin {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date() // give the creation date the value of current date
        
    }
}
