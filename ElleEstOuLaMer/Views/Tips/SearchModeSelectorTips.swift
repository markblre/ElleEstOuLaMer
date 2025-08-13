//
//  SearchModeSelectorTips.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 12/08/2025.
//

import TipKit

struct SearchModeSelectorTapTip: Tip {
    var title: Text {
        Text("tipSearchModeTapTitle")
    }

    var message: Text? {
        Text("tipSearchModeTapMessage")
    }

    var image: Image? {
        Image(systemName: "hand.tap")
    }
    
    var options: [Option] {
        MaxDisplayCount(1)
    }
}

struct SearchModeSelectorDragTip: Tip {
    var title: Text {
        Text("tipSearchModeDragTitle")
    }

    var message: Text? {
        Text("tipSearchModeDragMessage")
    }

    var image: Image? {
        Image(systemName: "arrow.up.and.down")
    }
    
    var options: [Option] {
        MaxDisplayCount(1)
    }
}
