//
//  CustomLocationTip.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 12/08/2025.
//

import TipKit

struct CustomLocationTip: Tip {
    var title: Text {
        Text("tipCustomLocationTitle")
    }

    var message: Text? {
        Text("tipCustomLocationMessage")
    }

    var image: Image? {
        Image(systemName: "location.circle")
    }
    
    var options: [Option] {
        MaxDisplayCount(1)
    }
}
