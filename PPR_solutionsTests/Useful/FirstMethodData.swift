//
//  FirstMethodData.swift
//  PPR_solutions
//
//  Created by Roman Kotov on 25.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import Foundation
import PPR_solutions

class UsefulFirstMethod {
    class func setupMatrix(matrix: [[Double]], toMPC mpc: MPC) -> MPC {
        var resultMPC = mpc
        
        for i in 0..<mpc.countRows {
            for j in 0..<mpc.countColumns {
                resultMPC[i, j] = matrix[i][j]
            }
        }
        
        return resultMPC
    }
    
    /// Критерии
    class var criterions: [BaseModelProtocol] {
        return [
            ElementOfTheProblem(title: "Criterion 1"),
            ElementOfTheProblem(title: "Criterion 2"),
            ElementOfTheProblem(title: "Criterion 3"),
            ElementOfTheProblem(title: "Criterion 4"),
            ElementOfTheProblem(title: "Criterion 5")
        ]
    }
    
    /// Альтернативы
    class var alternatives: [BaseModelProtocol] {
        return [
            ElementOfTheProblem(title: "Alternative 11"),
            ElementOfTheProblem(title: "Alternative 22"),
            ElementOfTheProblem(title: "Alternative 33"),
            ElementOfTheProblem(title: "Alternative 44")
        ]
    }
    
    /// МПС критериев для первого метода
    class var targetMPC: MPC {
        let target = Target(title: "Target 0")
        
        let testMatr = [
            [1,      3,     2,     1,     7],
            [0.33,   1,     0.33,  0.5,   3],
            [0.5,    3,     1,     3,     4],
            [1,      2,     0.33,  1,     4],
            [0.14,   0.33,  0.25,  0.25,  1]
        ]
        
        let mpc = MPC(title: target, columns: UsefulFirstMethod.criterions)
        return UsefulFirstMethod.setupMatrix(testMatr, toMPC: mpc)
    }
    
    /// Результаты решенной МПС критериев для первого метода
    class var targetSolvedMPC: solvedMPCData {
        return (eigenvector: [0.344, 0.114, 0.291, 0.198, 0.051],
                lambdaMax: 5.34,
                iS: 0.09,
                sI: 1.12,
                oS: 0.077)
    }
    
    /// МПС альтернатив по каждому критерию для первого метода
    class var criterionMPCs: [MPC] {
        let matrs = [
            [
                [ 1.00, 7.00, 4.00, 5.00 ],
                [ 0.14, 1.00, 0.20, 0.33 ],
                [ 0.25, 5.00, 1.00, 3.00 ],
                [ 0.20, 3.00, 0.33, 1.00 ]
            ],
            [
                [ 1.00, 4.00, 1.00, 0.20 ],
                [ 0.25, 1.00, 0.25, 0.14 ],
                [ 1.00, 4.00, 1.00, 0.20 ],
                [ 5.00, 7.00, 5.00, 1.00 ]
            ],
            
            [
                [ 1.00, 0.20, 0.50, 0.17 ],
                [ 5.00, 1.00, 4.00, 0.25 ],
                [ 2.00, 0.25, 1.00, 0.17 ],
                [ 6.00, 4.00, 6.00, 1.00 ]
            ],
            
            [
                [ 1.00, 0.17, 0.33, 2.00 ],
                [ 6.00, 1.00, 4.00, 6.00 ],
                [ 3.00, 0.25, 1.00, 3.00 ],
                [ 0.50, 0.17, 0.33, 1.00 ]
            ],
            
            [
                [ 1.00, 0.14, 0.25, 0.11 ],
                [ 7.00, 1.00, 2.00, 0.33 ],
                [ 4.00, 0.50, 1.00, 0.25 ],
                [ 9.00, 3.00, 4.00, 1.00 ]
            ]
        ]
        
        var mpcs: [MPC] = []
        
        for i in 0..<matrs.count {
            let mpc = MPC(title: ElementOfTheProblem(title: "Criterion for alternative\(i)"),
                          columns: UsefulFirstMethod.alternatives)
            mpcs.append(UsefulFirstMethod.setupMatrix(matrs[i], toMPC: mpc))
        }
        
        return mpcs
    }
    
    /// Результаты решенных МПС альтернатив по каждому критерию для первого метода
    class var criterionSolvedMPCs: [solvedMPCData] {
        let eigenvectors = [
            [ 0.59179, 0.05375, 0.23941, 0.11505 ],
            [ 0.16205, 0.05267, 0.16205, 0.62322 ],
            [ 0.06136, 0.25535, 0.09175, 0.59154 ],
            [ 0.10175, 0.61047, 0.21584, 0.07195 ],
            [ 0.04338, 0.25405, 0.14535, 0.55722 ]
        ]
        let lambdas = [ 4.201, 4.154, 4.242, 4.121, 4.089 ]
        let iSs = [ 0.067, 0.051, 0.081, 0.040, 0.030 ]
        let sIs = [ 0.900, 0.900, 0.900, 0.900, 0.900 ]
        let oSs = [ 0.074, 0.057, 0.090, 0.045, 0.033 ]
        
        var result: [solvedMPCData] = []
        for i in 0..<eigenvectors.count {
            result.append((eigenvector: eigenvectors[i],
                lambdaMax: lambdas[i],
                iS: iSs[i],
                sI: sIs[i],
                oS: oSs[i]))
        }
        
        return result
    }
    
    /// Результат этапа синтеза для первого метода
    class var synthesizeResult: [Double] {
        return [0.263, 0.233, 0.178, 0.326]
    }
}