//
//  Synthesizer.swift
//  PPR
//
//  Created by Roman Kotov on 24.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import Foundation
import PromiseKit

/// Класс для выполнения этапа синтеза (определения весов) в первом методе.
/// Определения полезности во втором методе
struct Synthesizer {
    /**
     Вычисляем полезность для каждого проекта
     
     - parameter targetMPC: МПС цели
     - parameter mpcs: МПС c проектами в строках
     
     - returns: Список проектов с полезностью
     */
    func usefulnessProjectsWithTargetMPC(targetMPC: MPC, projectsMPC: MPC)
        -> Promise<[BaseProjectProtocol]> {
            /// Расчет полезности по собственным векторам
            func usefulness(evectorTarget evT: [Double],
                                          andEigenvectorProject evP: [Double]) -> Double {
                var result = 0.0
                for i in 0..<evT.count { result += evT[i] * evP[i] }
                return result
            }
            
            return Promise(resolvers: { (fulfill, _) -> Void in
                guard let eigenvector = targetMPC.eigenvector else { fulfill([]); return }
                var projects = projectsMPC.rows
                var resultProjects: [BaseProjectProtocol] = []
                
                for i in 0..<projects.count {
                    if var project = projects[i] as? BaseProjectProtocol {
                        
                        project.usefulness =
                            usefulness(evectorTarget: eigenvector, andEigenvectorProject: projectsMPC[i])
                        resultProjects.append(project)
                    }
                }
                
                fulfill(resultProjects)
            });
    }
    
    /**
     Этап синтеза по МПС цели и МПС по критериям. Определяем веса.
     
     
     - parameter targetMPC: МПС цели
     - parameter mpcs: МПС по критериям
     
     - returns: Promise<(criterions, alternatives)> с установленными весами
     */
    func synthesizeForTargetMPC(targetMPC: MPC, criterionMPCs mpcs: [MPC])
        -> Promise<(criterions: [BaseModelProtocol], alternatives: [BaseModelProtocol])> {
            return Promise(resolvers: { (fulfill, _) -> Void in
                /// Вес цели (т.к. она одна = 1)
                let weightTarget = 1.0
                
                // Вычисляем веса критериев
                /// Количество критериев
                let countCriterions = targetMPC.eigenvector!.count
                /// Веса критериев
                var weightCriterions = [Double](count: countCriterions, repeatedValue: 0.0)
                
                /// Критерии
                var criterions: [BaseModelProtocol] = []
                for i in 0..<countCriterions {
                    let weight = weightTarget * targetMPC.eigenvector![i]
                    
                    var criterion: BaseModelProtocol = targetMPC.columns[i]
                    criterion.weight = weight
                    criterions.append(criterion)
                    
                    weightCriterions[i] = weight
                }
                
                // Вычисляем веса альтернатив
                let countAlternatives = mpcs[0].columns.count
                var weightAlternatives = [Double](count: countAlternatives, repeatedValue: 0.0)
                
                // Находим веса альтернатив
                // Проходимся по весам критериев
                for idxCrit in 0..<countCriterions {
                    // Проходимся по собственным векторам критериев
                    for idxAlter in 0..<countAlternatives {
                        weightAlternatives[idxAlter] += weightCriterions[idxCrit] * mpcs[idxCrit].eigenvector![idxAlter]
                    }
                }
                
                // Вычисляем согласованность q / w
                var q = weightTarget * targetMPC.iS!
                var w = weightTarget * targetMPC.sI!
                
                for i in 0..<countCriterions {
                    q += weightCriterions[i] * mpcs[i].iS!
                    w += weightCriterions[i] * mpcs[i].sI!
                }
                
                let s = q / w
                print("Согласованность = %0.4f", s)
                
                // Составляем результирующий массив
                var alternatives: [BaseModelProtocol] = []
                for i in 0..<countAlternatives {
                    var alternative: BaseModelProtocol = mpcs[0].columns[i]
                    alternative.weight = weightAlternatives[i]
                    alternatives.append(alternative)
                }
                
                fulfill((criterions: criterions, alternatives: alternatives));
            })
    }
}