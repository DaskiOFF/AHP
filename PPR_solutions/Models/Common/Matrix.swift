//
//  Matrix.swift
//  PPR
//
//  Created by Roman Kotov on 03.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import Foundation

public struct Matrix {
    /// Количество строк
    private(set) var rows: Int
    /// Количество столбцов
    private(set) var columns: Int
    /// Сетка
    private var grid: [Double]
    
    /**
     Инициализация матрицы
     
     - parameter rows: Количество строк
     - parameter columns: Количество столбцов
     
     - returns: Инициализированный экземпляр матрицы
     */
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        self.grid = Array(count: rows * columns, repeatedValue: 0.0)
    }  
    
    /**
     Валидация индекса матрицы
     
     - parameter row: Индекс строки матрицы
     - parameter column: Индекс столбца матрицы
     
     - returns: true, если индекс валиден, false иначе
     */
    private func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < self.rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
    
    subscript(rowIndex: Int) -> [Double] {
        var row: [Double] = []
        
        for i in 0..<self.columns {
            row.append(self[rowIndex, i])
        }
        
        return row
    }
}

extension Matrix {
    /// Добавление строки заполненной нулями к существующей матрице
    mutating func addRow() {
        for _ in 0..<self.columns {
            self.grid.append(0.0)
        }
        self.rows += 1
    }
    
    /// Добавление столбца заполненного нулями к существующей матрице
    mutating func addCol() {
        for row in 1...self.rows {
            self.grid.insert(0.0, atIndex: row * self.columns + row - 1)
        }
        self.columns += 1
    }
    
    /**
     Удаление столбца матрицы
     
     - parameter colIndex: Индекс удаляемого столбца
     */
    mutating func removeCol(colIndex: Int) {
        for row in 0..<self.rows {
            self.grid.removeAtIndex(row * self.columns + colIndex - row)
        }
        self.columns -= 1
    }
    
    /**
     Удаление строки матрицы
     
     - parameter rowIndex: Индекс удаляемой строки
     */
    mutating func removeRow(rowIndex: Int) {
        for _ in 0..<self.columns {
            self.grid.removeAtIndex(rowIndex * self.columns)
        }
        self.rows -= 1
    }
}