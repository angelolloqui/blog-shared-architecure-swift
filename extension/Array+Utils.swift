//
//  Array+Utils.swift
//  My Sports
//
//  Created by Angel Luis Garcia on 14/07/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

public extension Array where Element: Hashable {
    func distinct() -> [Element] {
        return Array(Set(self))
    }
}

public extension Array where Element: Equatable {
    func removing(element: Element) -> [Element] {
        if let index = self.index(of: element) {
            var newArray = self
            newArray.remove(at: index)
            return newArray
        }
        return self
    }
}

public extension Array {
    func sortedBy<R: Comparable>(selector: (Element) -> R) -> [Element] {
        return sorted { selector($0) < selector($1) }
    }

    func minBy<R: Comparable>(selector: (Element) -> R) -> Element? {
        guard count > 0 else { return nil }
        var minElem = self[0]
        var minValue = selector(minElem)
        for index in 1 ..< count {
            let elem = self[index]
            let value = selector(elem)
            if minValue > value {
                minElem = elem
                minValue = value
            }
        }
        return minElem
    }
}
