//
//  Criterion.swift
//  PPR
//
//  Created by Roman Kotov on 03.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import Foundation

///  Модель описания критерия или альтернативы задачи выбора
public class ElementOfTheProblem: BaseModelProtocol {
    /// Название
    public var title: String
    /// Вес
    public var weight: Double
    
    /**
     Инициализация экземпляра критерия или альтернативы с названием
     
     - parameter title: Название критерия или альтернативы
     
     - returns: Инициализированный экземпляр критерия или альтернативы
     */
    required public init(title: String) {
        self.title = title
        self.weight = 0.0
    }
}