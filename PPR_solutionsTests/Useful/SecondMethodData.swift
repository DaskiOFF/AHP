//
//  SecondMethodData.swift
//  PPR_solutions
//
//  Created by Roman Kotov on 25.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import Foundation
@testable import PPR_solutions

class UsefulSecondMethod {
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
            ElementOfTheProblem(title: "Новые знакомства"),
            ElementOfTheProblem(title: "Хорошее настроение"),
            ElementOfTheProblem(title: "Возможность получить прибыль"),
            ElementOfTheProblem(title: "Удовлетворенность"),
            ElementOfTheProblem(title: "Получение новых знаний"),
            ElementOfTheProblem(title: "Укрепление здоровья"),
            ElementOfTheProblem(title: "Плюсы в перспективе")
        ]
    }
    
    /// Проекты (альтернативы)
    class var alternatives: [BaseModelProtocol] {
        return [
            Project(title: "Вложиться в строительство дома", weight: 50),
            Project(title: "Вклад в обучение (повышение квалификации)", weight: 40),
            Project(title: "Вклад в банк", weight: 100),
            Project(title: "Оплатить интернет", weight: 30),
            Project(title: "Покупка одежды", weight: 20),
            Project(title: "Новый холодильник", weight: 50),
            Project(title: "Аренда теплицы", weight: 50)
        ]
    }
    
    /// Проекты для теста производительности (альтернативы)
    class var alternativesPerformance: [BaseProjectProtocol] {
        return [
            Project(title: "Вложиться в строительство дома", weight: 50, usefilness: 0.051479831723564906),
            Project(title: "Вклад в обучение (повышение квалификации)", weight: 40, usefilness: 0.19202311591404128),
            Project(title: "Вклад в банк", weight: 100, usefilness: 0.067796567559480894),
            Project(title: "Оплатить интернет", weight: 30, usefilness: 0.086838831047831855),
            Project(title: "Покупка одежды", weight: 20, usefilness: 0.14465920591016859),
            Project(title: "Новый холодильник", weight: 50, usefilness: 0.16039715383211542),
            Project(title: "Аренда теплицы", weight: 50, usefilness: 0.29680529401279704),
            Project(title: "8", weight: 60, usefilness: 0.29680529401279704),
            Project(title: "9", weight: 60, usefilness: 0.29680529401279704),
            Project(title: "10", weight: 60, usefilness: 0.29680529401279704),
            Project(title: "11", weight: 60, usefilness: 0.29680529401279704),
            Project(title: "12", weight: 60, usefilness: 0.29680529401279704),
            Project(title: "13", weight: 60, usefilness: 0.29680529401279704),
            Project(title: "14", weight: 60, usefilness: 0.29680529401279704),
            Project(title: "15", weight: 60, usefilness: 0.29680529401279704),
            Project(title: "16", weight: 60, usefilness: 0.29680529401279704),
            Project(title: "17", weight: 60, usefilness: 0.29680529401279704)
        ]
    }
    
    /// МПС критериев для второго метода
    class var targetMPC: MPC {
        let target = Target(title: "Распределение бюджета")
        
        let testMatr = [
            [1.00,	5.00,	3.00,	1.00,	0.50,	0.33,	2.00],
            [0.20,	1.00,	3.00,	3.00,	2.00,	0.25,	2.00],
            [0.33,	0.33,	1.00,	2.00,	0.33,	0.20,	3.00],
            [1.00,	0.33,	0.50,	1.00,	1.00,	0.25,	1.00],
            [2.00,	0.50,	3.00,	1.00,	1.00,	0.33,	4.00],
            [3.00,	4.00,	5.00,	4.00,	3.00,	1.00,	2.00],
            [0.50,	0.50,	0.33,	1.00,	0.25,	0.50,	1.00]
        ]
        
        let mpc = MPC(title: target, columns: UsefulSecondMethod.criterions)
        return UsefulSecondMethod.setupMatrix(testMatr, toMPC: mpc)
    }
    
    /// Результаты решенной МПС критериев для второго метода
    class var targetSolvedMPC: solvedMPCDataSecond {
        return (eigenvector: [0.1536953, 0.1328236, 0.0782779, 0.0775595, 0.1488732, 0.3451457, 0.0636248])
    }
    
    /// МПС альтернатив по каждому критерию для второго метода
    class var criterionMPCs: [MPC] {
        let matr = [
            [0.10,	0.03,	0.03,	0.06,	0.10,	0.10,	0.51],
            [0.90,	0.13,	0.13,	0.26,	0.90,	0.10,	0.51],
            [0.10,	0.03,	0.26,	0.13,	0.10,	0.10,	0.13],
            [0.10,	0.26,	0.13,	0.26,	0.10,	0.10,	0.03],
            [0.10,	0.13,	0.03,	0.13,	0.10,	0.90,	0.13],
            [0.10,	0.26,	0.03,	0.13,	0.10,	0.90,	0.13],
            [0.90,	0.26,	0.13,	0.26,	0.90,	0.90,	0.51]
        ]
        
        var mpcs: [MPC] = []
        let mpc = MPC(title: ElementOfTheProblem(title: "Criterion for alternative"),
                          columns: UsefulSecondMethod.criterions, rows:UsefulSecondMethod.alternatives)
        mpcs.append(UsefulSecondMethod.setupMatrix(matr, toMPC: mpc))
        
        return mpcs
    }
    
    /// Результаты решенных МПС альтернатив по каждому критерию для второго метода
    class var criterionSolvedMPC: [[Double]] {
        return [
            [0.04,	0.03,	0.04,	0.05,	0.04,	0.03,	0.26],
            [0.39,	0.12,	0.17,	0.21,	0.39,	0.03,	0.26],
            [0.04,	0.03,	0.35,	0.10,	0.04,	0.03,	0.07],
            [0.04,	0.24,	0.17,	0.21,	0.04,	0.03,	0.02],
            [0.04,	0.12,	0.04,	0.10,	0.04,	0.29,	0.07],
            [0.04,	0.24,	0.04,	0.10,	0.04,	0.29,	0.07],
            [0.39,	0.24,	0.17,	0.21,	0.39,	0.29,	0.26]
        ]
    }
    
    /// Результат полезности проектов
    class var usefulnessResult: [Double] {
        return [0.052229227, 0.191522792, 0.067996864, 0.086700403, 0.144506644, 0.160479028, 0.296565043]
    }
}