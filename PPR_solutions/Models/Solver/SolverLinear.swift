//
//  SolverLinear.swift
//  PPR_solutions
//
//  Created by Roman Kotov on 27.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import Foundation
import PromiseKit

public enum SolverLinearErrorType: ErrorType {
    case BadBudget
}

typealias MiniProject = (p: Double, w: Double, mask: Int)

/// Структура для решения задач линейного программирования во втором методе
struct SolverLinear {
    /**
     Получение списка проектов удовлетворяющих ограничению на бюджет и сумма полезностей которых максимальна
     для данного ограничения бюджета
     
     - parameter projects: Список всех проектов
     - parameter maxBudget: Ограничение на бюджет (верхняя граница)
     
     - returns: Promise<[BaseProjectProtocol]> Список проектов не превышающих бюджет с максимальной полезностью
     */
    func projects(projects: [BaseProjectProtocol], forBudget budget: Double) -> Promise<[BaseProjectProtocol]> {
        return Promise(resolvers: { (fulfill, reject) in
            guard budget >= 0.0 else {
                reject(SolverLinearErrorType.BadBudget);
                return
            }
            
            if budget == 0 {
                fulfill([])
                return
            }
            
            let projectsOpt = projects.filter { return $0.weight <= budget }
            let resultProjects = self.meetInTheMiddleForProjects(projectsOpt, andBudget: budget)
            
            fulfill(resultProjects)
        })
    }
    
    /**
     Метод решения с помощью грубой силы (перебор всех вариантов)
     Оптимизированный
     
     - parameter projects: Список всех проектов
     - parameter maxBudget: Ограничение на бюджет (верхняя граница)
     
     - returns: [BaseProjectProtocol] Список проектов не превышающих бюджет с максимальной полезностью
     */
    func brutforceForProjects(projects: [BaseProjectProtocol], andBudget budget: Double) -> [BaseProjectProtocol] {
        /// Результат содержащий проекты, их суммарную полезность и стоимость
        var result = (projects: [BaseProjectProtocol](), usefilness: 0.0, weight: 0.0)
        /// Результирующая комбинация подмножества
        var resultComb: [Int8] = [Int8](count: projects.count, repeatedValue: 0)
        
        func updateResultProjects() {
            var tmpResult = (projects: [BaseProjectProtocol](), usefilness: 0.0, weight: 0.0)
            for i in 0..<resultComb.count where resultComb[i] == 1 {
                let project = projects[i]
                tmpResult.projects.append(project)
                tmpResult.usefilness += project.usefulness
                tmpResult.weight += project.weight
                if tmpResult.weight > budget {
                    return
                }
            }
            
            if (tmpResult.usefilness >= result.usefilness &&
                tmpResult.weight <= budget) {
                    result = tmpResult
            }
        }
        
        func comb(i: Int = 0) {
            for x: Int8 in 0...1 {
                resultComb[i] = x
                if i >= projects.count - 1 {
                    updateResultProjects()
                } else {
                    comb(i + 1)
                }
            }
        }
        
        comb()
        
        return result.projects
    }
    
    /**
     Решение задачи линейного программирования методом "Встреча в середине"

     - parameter projects: Список всех проектов
     - parameter maxBudget: Ограничение на бюджет (верхняя граница)
     
     - returns: [BaseProjectProtocol] Список проектов не превышающих бюджет с максимальной полезностью
     */
    func meetInTheMiddleForProjects(projects: [BaseProjectProtocol], andBudget budget: Double) -> [BaseProjectProtocol] {
        /// Количество проектов
        let countProjects = projects.count
        /// Количество элементов в левой части
        let leftPartElementsCount = countProjects / 2
        /// Количество элементов в правой части
        let rightPartElementsCount = countProjects - leftPartElementsCount
        
        /// Количество подмножеств для левой части массива проектов
        let countL = 1 << leftPartElementsCount             // 2 ^ leftPartElementsCount
        /// Количество подмножеств для правой части массива проектов
        let countR = 1 << rightPartElementsCount   // 2 ^ rightPartElementsCount
        
        /// Массив содержит элементы, которые являются результатами сумм полезностей проектов
        /// и стоимостей проектов для конкретного подмножества
        ///
        /// Проекты входящие в подмножество представлены в виде маски
        var sumL = [MiniProject](count: countL, repeatedValue: (p: 0.0, w: 0.0, mask: 0))
        
        // i - представляет собой маску подмножества для левой части массива проектов
        for i in 0..<countL {
            // j - представляет собой номер проекта из левой части
            for j in 0..<leftPartElementsCount {
                // Если в i j-ый бит установлен в 1, значит j-ый проект входит в подмножество
                if (i & (1 << j)) > 0 {
                    let project = projects[j]
                    sumL[i] = (p: sumL[i].p + project.usefulness,
                               w: sumL[i].w + project.weight,
                               mask: i)
                }
            }
        }
        
        // Сортируем по возрастанию полезности
        sumL = sumL.sort({ (obj1, obj2) -> Bool in
            return obj1.p < obj2.p
        })
        
        // i - представляет собой маску подмножества для левой части массива проектов
        var i = 1
        while i < sumL.count {
            // j - представляет собой маску подмножества для левой части массива проектов
            var j = 1
            while j < sumL.count {
                // Удаляем элементы, у которых большой бюджет и маленькая полезность по сравнению с другими
                if i != j && (sumL[i].w > budget || (sumL[j].w <= sumL[i].w && sumL[j].p >= sumL[i].p)) {
                    sumL[i] = (p: 0.0, w: 0, mask: 0)
                    sumL.removeAtIndex(i)
                    i -= 1
                    break
                }
                j += 1
            }
            i += 1
        }
        
        /// Суммарная стоимость текущего набора проектов из правой части списка проектов
        var currentWeight = 0.0
        /// Суммарная полезность текущего набора проектов из правой части списка проектов
        var currentUsefulness = 0.0
        /// Ответ (полезность)
        var answerUsefulness = 0.0
        /// Ответ (маска)
        var answerMask = 0
        
        // i - представляет собой маску подмножества для правой части массива проектов
        for i in 0..<countR {
            currentWeight = 0
            currentUsefulness = 0
            
            // j - представляет собой номер проекта из правой части
            for j in 0..<rightPartElementsCount {
                // Если в i j-ый бит установлен в 1, значит j-ый проект входит в подмножество
                if (i & (1 << j)) > 0 {
                    currentUsefulness += projects[leftPartElementsCount + j].usefulness
                    currentWeight += projects[leftPartElementsCount + j].weight
                    // Если суммарная стоимость превышает бюджет, то данное подмножество проектов нам не подходит
                    if currentWeight > budget { break }
                }
            }
            // Если суммарная стоимость превышает бюджет, то данное подмножество проектов нам не подходит
            if currentWeight > budget { continue }
            
            
            /// Позиция подмножества с максимальным весом не превышающим (budget - currentWeight)
            var index = 0
            /// Временная переменная, используется для того, чтобы в массиве найти подмножество судовлетворяющим
            /// весом и максимальной полезностью
            var tmpUsefulness = 0.0
            for k in 0..<sumL.count {
                if sumL[k].p >= tmpUsefulness && sumL[k].w <= (budget - currentWeight) {
                    tmpUsefulness = sumL[k].p
                    index = k
                }
            }
            
            if sumL[index].p + currentUsefulness > answerUsefulness {
                answerUsefulness = sumL[index].p + currentUsefulness
                // Побитовая операция "или" между маской подмножества из левой части и текущего сдвинутого влево
                // 0011 | 1101 = 1101 0011
                answerMask = sumL[index].mask | (i << leftPartElementsCount)
            }
        }
        
        /// Результирующий список проектов
        var result = [BaseProjectProtocol]()
        // Добавляем проекты из левой части
        for i in 0..<leftPartElementsCount {
            if (answerMask & (1 << i)) > 0 {
                result.append(projects[i])
            }
        }
        // Добавляем проекты из правой части
        for i in 0..<rightPartElementsCount {
            if (answerMask & (1 << (i + leftPartElementsCount))) > 0 {
                result.append(projects[leftPartElementsCount + i])
            }
        }
        
        return result
    }
}