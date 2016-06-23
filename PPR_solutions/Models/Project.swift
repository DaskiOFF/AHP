//
//  Project.swift
//  PPR
//
//  Created by Roman Kotov on 23.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import Foundation

/** Класс проекта для второго метода
 
 Проект с названием, ценой и полезностью*/
public class Project: BaseProjectProtocol {
    /// Название проекта
    public var title: String
    /// Стоимость
    public var weight: Double
    /// Полезность
    public var usefulness: Double
    
    /**
     Инициализация экземпляра проекта
     
     - parameter title: Название проекта
     
     - returns: Инициализированный экземпляр проекта
     */
    required public init(title: String) {
        self.title = title
        self.weight = 0.0
        self.usefulness = 0.0
    }
    
    /**
     Инициализация экземпляра проекта
     
     - parameter title: Название проекта
     - parameter weight: Вес (стоимость) проекта
     
     - returns: Инициализированный экземпляр проекта
     */
    public convenience init(title: String, weight: Double) {
        self.init(title: title)
        self.weight = weight
    }
    
    /**
     Инициализация экземпляра проекта
     
     - parameter title: Название проекта
     - parameter weight: Вес (стоимость) проекта
     - parameter usefulness: Полезность проекта
     
     - returns: Инициализированный экземпляр проекта
     */
    convenience init(title: String, weight: Double, usefilness: Double) {
        self.init(title: title)
        self.weight = weight
        self.usefulness = usefilness
    }
}