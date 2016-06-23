//
//  Solver.swift
//  PPR
//
//  Created by Roman Kotov on 24.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import Foundation
import PromiseKit

public typealias SolverResultFirstMethod =
    (target: Target, criterions: [BaseModelProtocol], alternatives: [BaseModelProtocol])
public typealias SolverResultSecondMethod =
    (target: Target, projects: [BaseProjectProtocol])

public enum ErrorSolver: ErrorType {
    case BadTarget
}

/// Структура для нахождения решения цели
public struct Solver {
    //MARK: * FIELDS *
    /// Синтез
    private let synthesizer: Synthesizer
    /// Решение МПС
    private let solverMPC: SolverMPC
    
    public init() {
        self.synthesizer = Synthesizer()
        self.solverMPC = SolverMPC()
    }
}

extension Solver {
    /**
     Решение задачи распределения ресурсов
     
     - parameter target: Цель содержащая критерии и альтернативы
     - parameter budget: Бюджет, которым мы владеем
     
     - returns: Promise<[BaseProjectProtocol]> Лучшие проекты, которые вписываются в бюджет
     */
    public func findProjects(target: Target, forBudget budget: Double)
        -> Promise<SolverResultSecondMethod> {
            return Promise(resolvers: { (fulfill, reject) in
                // проверяем, чтобы все необходимые поля были заполнены
                guard target.baseMPC != nil &&
                    target.criterionMPCs != nil && target.criterionMPCs!.count > 0 else {
                        reject(ErrorSolver.BadTarget)
                        return
                }
                
                // Решаем главную матрицу цели (определяем важность критериев)
                self.solverMPC.solveMPC(mpc: target.baseMPC!).then({ mpcs -> Promise<MPC> in
                    target.baseMPC = mpcs[0]
                    if let eigenVector = target.baseMPC?.eigenvector {
                        for (index, _) in target.criterions.enumerate() {
                            target.criterions[index].weight = eigenVector[index]
                        }
                    }
                    return self.solverMPC.normalizationColumnsForMPC(target.criterionMPCs![0])
                }).then({ mpc -> Promise<[BaseProjectProtocol]> in
                    return self.synthesizer
                        .usefulnessProjectsWithTargetMPC(target.baseMPC!, projectsMPC: mpc)
                }).then({ (projects) -> Promise<[BaseProjectProtocol]> in
                    var alternatives: [BaseModelProtocol] = []
                    for project in projects { alternatives.append(project as BaseModelProtocol) }
                    target.alternatives = alternatives
                    
                    let solverLinear = SolverLinear()
                    return solverLinear.projects(projects, forBudget: budget)
                }).then({ (resultProjects) -> Void in
                    fulfill((target: target, projects: resultProjects))
                }).error({ (error) in
                    reject(error)
                })
            })
    }
    
    /**
     Возвращает упорядоченные списки критериев и альтернатив наилучшим образом удовлетворящих цели
     
     - parameter target: Цель содержащая критерии и альтернативы
     
     - returns: Promise<[BaseModelProtocol]> цель, упорядоченные списки критериев и альтернатив, по убыванию их полезности
     */
    public func findAlternativeForTarget(target: Target) -> Promise<SolverResultFirstMethod> {
        return Promise(resolvers: { (fulfill, reject) in
            // проверяем, чтобы все необходимые поля были заполнены
            guard target.baseMPC != nil &&
                target.criterionMPCs != nil && target.criterionMPCs!.count > 0 else {
                    reject(ErrorSolver.BadTarget)
                    return
            }
            
            // Решаем главную матрицу цели (определяем важность критериев)
            self.solverMPC.solveMPC(mpc: target.baseMPC!)
                .then({ mpcs -> Promise<[MPC]> in
                    target.baseMPC = mpcs[0]
                    return self.solverMPC.solveMPC(target.criterionMPCs!)
                })
                // Решаем матрицы для каждого критерия (насколько каждая альтернатива удовлетворяет данному критерию)
                .then({ mpcs -> Promise<(criterions: [BaseModelProtocol], alternatives: [BaseModelProtocol])> in
                    target.criterionMPCs = mpcs
                    return self.synthesizer.synthesizeForTargetMPC(target.baseMPC!, criterionMPCs: target.criterionMPCs!)
                })
                // Этап синтеза определяем веса критериев и альтернатив
                .then({ (criterions, alternatives) in
                    target.criterions = criterions
                    target.alternatives = alternatives
                    
                    // Сортируем критерии и альтернативы по убыванию веса и их возвращаем
                    let sortedCriterions = criterions.sort({ (model1, model2) -> Bool in
                        model1.weight > model2.weight
                    })
                    
                    // Сортируем альтернативы по весу
                    let sortedAlternatives = alternatives.sort({ (model1, model2) -> Bool in
                        model1.weight > model2.weight
                    })
                    
                    fulfill((target: target, criterions: sortedCriterions, alternatives: sortedAlternatives))
                })
        })
    }
}