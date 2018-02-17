//
//  ObjectViewModels.swift
//  Automobile
//
//  Created by Ahmad Ansari on 17/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import Foundation
import Localize_Swift

class ManufacturerViewModel: NSObject {

    weak var manufacturer: Manufacturer?
    
    init(manufacturer: Manufacturer) {
        super.init()
        self.manufacturer = manufacturer
    }
    
    func name() -> String {
        if (self.manufacturer?.name?.isEmpty == false) {
            return (self.manufacturer?.name)!
        }
        return "Unknown".localized()
    }
}


class ModelVM: NSObject {
    
    weak var model: Model?
    
    init(model: Model) {
        super.init()
        self.model = model
    }
    
    func name() -> String {
        if (self.model?.name?.isEmpty == false) {
            return (self.model?.name)!
        }
        return "Unknown".localized()
    }
}

