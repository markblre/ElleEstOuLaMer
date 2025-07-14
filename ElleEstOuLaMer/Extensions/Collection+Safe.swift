//
//  Collection+Safe.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 14/07/2025.
//

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
