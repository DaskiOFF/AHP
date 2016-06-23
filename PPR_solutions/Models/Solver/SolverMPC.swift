//
//  SolverMPC.swift
//  PPR
//
//  Created by Roman Kotov on 24.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import Foundation
import PromiseKit

/// Структура для нахождения собственного вектора и lambdaMax Матрицы Парных Сравнений
struct SolverMPC {
    /**
     Вычисления для матрицы парных сравнений. Нахождение собственного вектора и lambdaMax
     
     - parameter mpc: Матрица Парных Сравнений
     
     - returns: PMKPromise с массивом новых, решенных МПС (в данном случае из 1-го элемента)
     */
    func solveMPC(mpc mpc: MPC) -> Promise<[MPC]> {
        return self.solveMPC([mpc])
    }
    
    /**
     Вычисления для матрицы парных сравнений. Нахождение собственного вектора и lambdaMax
     
     - parameter mpcs: Матрицы Парных Сравнений
     
     - returns: PMKPromise с массивом новых, решенных МПС
     */
    func solveMPC(mpcs: [MPC]) -> Promise<[MPC]> {
        return Promise(resolvers: { (fulfill, _) -> Void in
            var solvedMPCs: [MPC] = []
            
            for mpc in mpcs {
                // Получаем нормированное значение собственного вектора
                let eigenvectorNormalized = self.eigenvectorNormalizedForMatrix(mpc)

                // Получаем максимальное собственное число
                let eigenvalue = self.eigenvalueForMatrix(mpc, andEigenvectorNormalized: eigenvectorNormalized)

                // Создаем новый экземпляр МПС
                solvedMPCs.append(MPC(mpc: mpc, eigenvector: eigenvectorNormalized, lambdaMax: eigenvalue))
            }
            
            fulfill(solvedMPCs)
        })
    }
    
    /**
     Нормировка столбцов MPC
     
     - parameter mpc: МПС нормировку столбцов которой необходимо произвести
     
     - returns: Promise<MPC> МПС с нормированными столбцами
     */
    func normalizationColumnsForMPC(mpc: MPC) -> Promise<MPC> {
        return Promise(resolvers: { (fulfill, _) -> Void in
            let resultMPC = MPC(title: mpc.title, columns: mpc.columns, rows: mpc.rows)
            var sums = [Double](count: resultMPC.countColumns, repeatedValue: 0.0)
            
            for row in 0..<mpc.countRows {
                for col in 0..<mpc.countColumns {
                    sums[col] += mpc[row, col]
                }
            }
            
            for row in 0..<mpc.countRows {
                for col in 0..<mpc.countColumns {
                    resultMPC[row, col] = mpc[row, col] / sums[col]
                }
            }
            
            fulfill(resultMPC)
        })
    }
    
    // MARK: Additional Helpers ( Дополнительные функции )
    
    /**
     Получить нормализованный вектор для матрицы
     
     - parameter matrix: матрица для которой необходимо найти собственный вектор
     
     - returns: Собственный вектор
     */
    private func eigenvectorNormalizedForMatrix(matrix: MPC) -> [Double] {
        // 1. Определяем среднее геометрическое для строки
        var eigenvector = [Double]()
        
        for i in 0..<matrix.countRows {
            eigenvector.append(self.geometricMeanForRow(matrix[i]))
        }
        
        // 2. Вычисляем сумму средних геометрических
        // 3. Получаем нормированное значение собственного вектора
        return self.normalizationForRow(eigenvector)
    }
    
    /**
     Вычисляем среднее геометрическое для вектора
     
     - parameter row: Вектор
     
     - returns: Среднее геометрическое
     */
    private func geometricMeanForRow(row: [Double]) -> Double {
        guard row.count > 0 else { return 0 }
        return pow(row.reduce(1.0, combine: *), 1.0 / Double(row.count))
    }
    
    /**
     Нормировка вектора
     
     - parameter row: Вектор, нормировку которого необходимо провести
     
     - returns: Нормированный вектор row
     */
    private func normalizationForRow(row: [Double]) -> [Double] {
        guard row.count > 0 else { return row }
        guard row.count > 1 else { return [1] }
        
        /// Сумма всех значений
        let sum = row.reduce(0.0, combine: +)
        
        /// Новый нормированный вектор
        var newRow: [Double] = []
        for element in row { newRow.append(element / sum) }
        
        return newRow;
    }
    
    /**
     Нахождение максимального собственного числа
     
     - parameter matrix: Матрица для которой ищем собственное число
     - parameter eigenvector: Нормализованный собственный вектор
     
     - returns: Собственное число матрицы
     */
    private func eigenvalueForMatrix(matrix: MPC, andEigenvectorNormalized eigenvector: [Double]) -> Double {
        // 4. Определяем сумму для каждого столбца матрицы
        var sums = [Double](count: matrix.countColumns, repeatedValue: 0.0)
    
        for i in 0..<matrix.countRows {
            let row = matrix[i]
            for j in 0..<row.count {
                sums[j] += row[j]
            }
        }
        
        // 5. Определяем скалярное произведение векторов (максимальное собственное число)
        var lambda = 0.0
        for i in 0..<eigenvector.count {
            lambda += sums[i] * eigenvector[i]
        }
        
        return lambda
    }
}