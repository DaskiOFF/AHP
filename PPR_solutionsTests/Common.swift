//
//  Common.swift
//  PPR_solutions
//
//  Created by Roman Kotov on 28.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import Foundation

typealias solvedMPCData =
    (eigenvector: [Double], lambdaMax: Double, iS: Double, sI: Double, oS: Double)

typealias solvedMPCDataSecond = [Double]

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}