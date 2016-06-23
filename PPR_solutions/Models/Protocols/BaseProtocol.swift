//
//  BaseProtocol.swift
//  PPR
//
//  Created by Roman Kotov on 23.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import Foundation

public protocol BaseProtocol {
    /// Имя
    var title: String { get set }
    
    /// Инициализация объекта с заголовком
    init(title: String)
}