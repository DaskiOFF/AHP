//
//  BaseProjectProtocol.swift
//  PPR
//
//  Created by Roman Kotov on 23.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import Foundation

public protocol BaseProjectProtocol: BaseModelProtocol {
    /// Полезность
    var usefulness: Double { get set }
}