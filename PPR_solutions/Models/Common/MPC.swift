//
//  MPC.swift
//  PPR
//
//  Created by Roman Kotov on 03.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import Foundation

/// Модель описания матрицы парных сравнений
public class MPC {
    // MARK: Constants ( Константы )
    /// Название матрицы (критерий или цель)
    public let title: BaseProtocol
    /// Названия столбцов
    public var columns: [BaseModelProtocol]
    /// Названия строк
    public var rows: [BaseModelProtocol]
    
    // MARK: Variables ( Переменные )
    /// Матрица
    private var matrix: Matrix
    /// Количество столбцов
    public var countColumns: Int {
        get {
            return self.matrix.columns
        }
    }
    /// Количество строк
    public var countRows: Int {
        get {
            return self.matrix.rows
        }
    }
    /// Собственный вектор
    public private(set) var eigenvector: [Double]?
    /// Максимальное собственное число
    public private(set) var lambdaMax: Double?
    /// Индекс согласованности
    public private(set) var iS: Double?
    /// Случайный индекс согласованности
    public private(set) var sI: Double?
    /// Отношение согласованности
    public private(set) var oS: Double?
    
    // MARK: Inits ( Конструкторы )
    /**
     Инициализация экземпляра МПС с одинаковыми значениями в строках и столбцах
     
     - parameter title: Критерий или цель для оценки
     - parameter columns: Столбцы матрицы (что будем сравнивать по данному критерию)
     
     - returns: Инициализированный экземпляр МПС
     */
    public init(title: BaseProtocol, columns: [BaseModelProtocol]) {
        self.title = title
        self.columns = columns
        self.rows = self.columns
        
        let count = columns.count
        self.matrix = Matrix(rows: count, columns: count)
        for i in 0..<count {
            self.matrix[i, i] = 1.0
        }
    }
    
    /**
     Инициализация экземпляра МПС с разными значениями в строках и столбцах (для оценок криетриев для проектов с помощью
     стандартов)
     
     - parameter title: Цель для оценки
     - parameter columns: Столбцы матрицы (критерии)
     - parameter rows: Строки матрицы (Проекты)
     
     - returns: Инициализированный экземпляр МПС
     */
    public init(title: BaseProtocol, columns: [BaseModelProtocol], rows: [BaseModelProtocol]) {
        self.title = title
        self.columns = columns
        self.rows = rows
        
        self.matrix = Matrix(rows: self.rows.count, columns: self.columns.count)
    }
    
    /**
     Инициализация экземпляра МПС используя другую МПС
     
     - parameter mpc: МПС от которой возьмутся criterion, columns, rows и matrix
     - parameter eigenvector: Собственный вектор
     - parameter lambdaMax: Максимальное собственное число
     
     - returns: Инициализированный экземпляр МПС
     */
    convenience init(mpc: MPC, eigenvector:[Double], lambdaMax: Double) {
        self.init(title: mpc.title, columns: mpc.columns, rows: mpc.rows)
        self.matrix = mpc.matrix
        
        self.eigenvector = eigenvector
        self.lambdaMax = lambdaMax
        
        // Находим ИС (lambda - n) / (n - 1)
        let eigenvectorCount = Double(eigenvector.count)
        self.iS = (self.lambdaMax! - eigenvectorCount) / (eigenvectorCount - 1)
        self.sI = self.sIForPor(eigenvector.count)
        self.oS = self.iS! / self.sI!
    }
    
    // MARK: Additional Helpers ( Дополнительные функции )
    public subscript(row: Int, column: Int) -> Double {
        get {
            return matrix[row, column]
        }
        set {
            matrix[row, column] = newValue
            if  self.rows.count - 1 >= row && self.columns.count - 1 >= row &&
                self.rows[row].title == self.columns[row].title {
                
                matrix[column, row] = 1 / newValue
            }
        }
    }
    
    public subscript(rowIndex: Int) -> [Double] {
        return self.matrix[rowIndex]
    }
    
    /**
     Соответствие порядка и среднего значения Случайного индекса согласованности
     
     - parameter por: порядок матрицы (min 1, max 15)
     
     - returns: Случайный индекс согласованности
     */
    private func sIForPor(por: Int) -> Double {
        assert(por > 0 && por <= 15)
        
        return [0,    0,
                0.58, 0.9,
                1.12, 1.23,
                1.32, 1.41,
                1.45, 1.49,
                1.51, 1.48,
                1.56, 1.57,
                1.59][por - 1];
    }
}

extension MPC {
    /**
     Добавление строки и столбца в матрицу парных сравнений
     
     - parameter row: Элемент добавляемый в строку
     - parameter column: Элемент добавляемый в столбец
     */
    func addRow(row: BaseModelProtocol, column col: BaseModelProtocol) {
        self.addRow(row)
        self.addCol(col)
        self[self.countRows - 1, self.countColumns - 1] = 1.0
    }
    
    /**
     Добавление строки  в матрицу парных сравнений
     
     - parameter row: Элемент добавляемый в строку
     */
    func addRow(row: BaseModelProtocol) {
        self.rows.append(row)
        self.matrix.addRow()
    }
    
    /**
     Добавление столбца в матрицу парных сравнений
     
     - parameter column: Элемент добавляемый в столбец
     */
    func addCol(col: BaseModelProtocol) {
        self.columns.append(col)
        self.matrix.addCol()
    }
    
    /**
     Удаление строки и столбца в матрице парных сравнений
     
     - parameter row: Индекс удаляемой строки
     - parameter column: Индекс удаляемого столбца
     */
    func removeRow(row: Int, column col: Int) {
        self.removeRow(row)
        self.removeCol(col)
    }
    
    /**
     Удаление столбца в матрице парных сравнений
     
     - parameter colIndex: Индекс удаляемого столбца
     */
    func removeCol(colIndex: Int) {
        self.columns.removeAtIndex(colIndex)
        self.matrix.removeCol(colIndex)
    }
    
    /**
     Удаление строки в матрице парных сравнений
     
     - parameter rowIndex: Индекс удаляемой строки
     */
    func removeRow(rowIndex: Int) {
        self.rows.removeAtIndex(rowIndex)
        self.matrix.removeRow(rowIndex)
    }
}