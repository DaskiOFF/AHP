//
//  Target.swift
//  PPR
//
//  Created by Roman Kotov on 03.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import Foundation

public enum Method {
    /// Выбор альтернативы (Ранжирование альтернатив)
    case ChoiceOfAlternatives
    /// Распределение ресурсов
    case AllocationOfResources
}

/// Модель для описание цели задачи выбора
public class Target: BaseProtocol {
    // MARK: Variables ( Переменные )
    /// Описание цели
    public var title: String
    /// Метод
    public var methodType: Method
    
    /// Матрица парных сравнений критериев (на сколько они удовлетворяют цели)
    ///
    /// Строки и столбцы это критерии
    public var baseMPC: MPC? {
        set {
            self._baseMPC = newValue
        }
        get {
            // Если еще не инициализированна или количество столбцов не совпадает с количеством критериев
            if self._baseMPC == nil {
                self._baseMPC = MPC(title: self, columns: [])
            }
            
            return self._baseMPC
        }
    }
    private var _baseMPC: MPC?
    
    /// Матрицы парных сравнений
    ///
    /// Первый метод: Для каждого критерия (насколько альтернативы удовлетворяют цели по данному критерию)
    ///
    /// Второй метод: 1 матрица парных сравнений строки - проекты, столбцы - критерии
    public var criterionMPCs: [MPC]? {
        set {
            self._criterionMPCs = newValue
        }
        get {
            guard self.criterions.count > 0 && self.alternatives.count > 0 else {
                return nil
            }
            
            if self.methodType == .AllocationOfResources {
                func criterionMPCsNew() -> [MPC] {
                    return [MPC(title: self, columns: self.criterions, rows: [])]
                }
                
                // Список еще не инициализирован или без элементов
                if self._criterionMPCs == nil || self._criterionMPCs?.count == 0 {
                    self._criterionMPCs = criterionMPCsNew()
                    return self._criterionMPCs
                }
            
                return self._criterionMPCs
            }
            
            if self._criterionMPCs == nil {
                self._criterionMPCs = []
                for i in 0..<self.criterions.count {
                    self._criterionMPCs?
                        .append(MPC(title: self.criterions[i], columns: []))
                }
            }
            
            return self._criterionMPCs
        }
    }
    private var _criterionMPCs: [MPC]?
    
    /// Список критериев
    public var criterions: [BaseModelProtocol]
    /// Список альтернатив
    public var alternatives: [BaseModelProtocol]
    
    // MARK: Inits ( Конструкторы )
    
    /**
     Инициализация цели с ее описанием
     
     - parameter title: Описание цели
     
     - returns: Инициализированный экземпляр цели с пустыми списками и методом "Выбор альтернативы"
     */
    required public init(title: String) {
        self.title = title
        
        self.methodType = .ChoiceOfAlternatives
        self.criterions = []
        self.alternatives = []
    }
    
    /**
     Инициализация цели с ее описанием
     
     - parameter title: Описание цели
     - parameter method: Метод
     
     - returns: Инициализированный экземпляр цели с пустыми списками и переданным методом
     */
    public convenience init(title: String, method: Method) {
        self.init(title: title)
        self.methodType = method
    }
}

// удаление элемента
extension Target {
    /**
     Добавить критерий
     
     - parameter criterion: Добавляемый критерий
     */
    public func addCriterion(criterion: BaseModelProtocol) {
        self.criterions.append(criterion)
        self.baseMPC?.addRow(criterion, column: criterion)
        
        guard let _ = self.criterionMPCs else { return }
        if self.methodType == .ChoiceOfAlternatives && self.criterionMPCs?.count != self.criterions.count {
            self._criterionMPCs?.append(MPC(title: criterion, columns: self.alternatives))
        } else if self.methodType == .AllocationOfResources {
            self.criterionMPCs?[0].addCol(criterion)
        }
    }
    
    /**
     Добавить альтернативу/проект
     
     - parameter alternative: Добавляемая альтернатива/проект
     */
    public func addAlternative(alternative: BaseModelProtocol) {
        self.alternatives.append(alternative)
        guard let _ = self.criterionMPCs else { return }
        if self.methodType == .ChoiceOfAlternatives {
            for mpc in self.criterionMPCs! {
                mpc.addRow(alternative, column: alternative)
            }
        } else if self.methodType == .AllocationOfResources {
            self.criterionMPCs?[0].addRow(alternative)
        }
    }
    
    /**
     Удаление критерия по индексу
     
     - parameter index: Индекс удаляемого критерия
     */
    public func removeCriterionWithIndex(index: Int) {
        self.baseMPC?.removeRow(index, column: index)
        self.criterions.removeAtIndex(index)
        
        guard let _ = self.criterionMPCs else { return }
        if self.methodType == .ChoiceOfAlternatives && self.criterionMPCs?.count != self.criterions.count {
            self.criterionMPCs?.removeAtIndex(index)
        } else if self.methodType == .AllocationOfResources {
            self.criterionMPCs?[0].removeCol(index)
        }
    }
    
    /**
     Удаление альтернативы/проекта по индексу
     
     - parameter index: Индекс удаляемой альтернативы/проекта
     */
    public func removeAlternativeWithIndex(index: Int) {
        if self.methodType == .ChoiceOfAlternatives {
            for mpc in self.criterionMPCs! {
                mpc.removeRow(index, column: index)
            }
        } else {
            self.criterionMPCs?[0].removeRow(index)
        }
        
        self.alternatives.removeAtIndex(index)
    }
}