//
//  MinesweeperGame.swift
//  salei
//
//  Created for Minesweeper Game
//

import Foundation
import UIKit

enum CellState {
    case covered
    case flagged
    case revealed
}

enum CellContent {
    case mine
    case empty(adjacentMines: Int)
}

class MinesweeperGame {
    var rows: Int
    var columns: Int
    var mineCount: Int
    var gameBoard: [[CellContent]]
    var cellStates: [[CellState]]
    var isGameOver: Bool = false
    var isWin: Bool = false
    var flagsPlaced: Int = 0
    var revealedCells: Int = 0
    
    // 特殊游戏模式属性
    var isBlindMode: Bool { return SpecialGameMode.shared.isBlindMode }
    var isMovingMinesMode: Bool { return SpecialGameMode.shared.isMovingMinesMode }
    
    init(rows: Int, columns: Int, mineCount: Int) {
        self.rows = rows
        self.columns = columns
        self.mineCount = mineCount
        self.gameBoard = Array(repeating: Array(repeating: .empty(adjacentMines: 0), count: columns), count: rows)
        self.cellStates = Array(repeating: Array(repeating: .covered, count: columns), count: rows)
        placeMines()
        calculateAdjacentMines()
    }
    
    private func placeMines() {
        var minesPlaced = 0
        while minesPlaced < mineCount {
            let row = Int.random(in: 0..<rows)
            let column = Int.random(in: 0..<columns)
            
            if case .empty = gameBoard[row][column] {
                gameBoard[row][column] = .mine
                minesPlaced += 1
            }
        }
    }
    
    private func calculateAdjacentMines() {
        for row in 0..<rows {
            for column in 0..<columns {
                if case .mine = gameBoard[row][column] { continue }
                
                var adjacentMines = 0
                for r in max(0, row-1)...min(rows-1, row+1) {
                    for c in max(0, column-1)...min(columns-1, column+1) {
                        if r == row && c == column { continue }
                        if case .mine = gameBoard[r][c] {
                            adjacentMines += 1
                        }
                    }
                }
                gameBoard[row][column] = .empty(adjacentMines: adjacentMines)
            }
        }
    }
    
    func revealCell(at row: Int, at column: Int) -> Bool {
        guard !isGameOver,
              row >= 0, row < rows,
              column >= 0, column < columns,
              cellStates[row][column] == .covered else {
            return false
        }
        
        cellStates[row][column] = .revealed
        revealedCells += 1
        
        switch gameBoard[row][column] {
        case .mine:
            isGameOver = true
            return false
        case .empty(let adjacentMines):
            if adjacentMines == 0 {
                // 自动揭开周围的空白格子
                for r in max(0, row-1)...min(rows-1, row+1) {
                    for c in max(0, column-1)...min(columns-1, column+1) {
                        if r == row && c == column { continue }
                        if cellStates[r][c] == .covered {
                            _ = revealCell(at: r, at: c)
                        }
                    }
                }
            }
            
            // 检查是否获胜
            checkWinCondition()
            
            // 移动地雷模式：有几率移动未揭示区域的地雷
            if isMovingMinesMode && SpecialGameMode.shared.shouldMoveMines() {
                moveMines()
            }
            
            return true
        }
    }
    
    func toggleFlag(at row: Int, at column: Int) {
        guard !isGameOver,
              row >= 0, row < rows,
              column >= 0, column < columns,
              cellStates[row][column] != .revealed else {
            return
        }
        
        if cellStates[row][column] == .covered {
            cellStates[row][column] = .flagged
            flagsPlaced += 1
        } else if cellStates[row][column] == .flagged {
            cellStates[row][column] = .covered
            flagsPlaced -= 1
        }
    }
    
    private func checkWinCondition() {
        let totalCells = rows * columns
        if revealedCells == totalCells - mineCount {
            isGameOver = true
            isWin = true
        }
    }
    
    func resetGame() {
        gameBoard = Array(repeating: Array(repeating: .empty(adjacentMines: 0), count: columns), count: rows)
        cellStates = Array(repeating: Array(repeating: .covered, count: columns), count: rows)
        isGameOver = false
        isWin = false
        flagsPlaced = 0
        revealedCells = 0
        placeMines()
        calculateAdjacentMines()
    }
    
    // MARK: - 特殊游戏模式方法
    
    // 移动地雷方法（用于移动地雷模式）
    private func moveMines() {
        // 收集所有未揭示的单元格位置
        var coveredCells: [(row: Int, column: Int)] = []
        var mineCells: [(row: Int, column: Int)] = []
        
        for row in 0..<rows {
            for column in 0..<columns {
                if cellStates[row][column] == .covered {
                    if case .mine = gameBoard[row][column] {
                        mineCells.append((row, column))
                    } else {
                        coveredCells.append((row, column))
                    }
                }
            }
        }
        
        // 确保有足够的未揭示非地雷单元格可以移动
        guard !coveredCells.isEmpty, !mineCells.isEmpty else { return }
        
        // 随机选择一个地雷和一个非地雷单元格交换位置
        let randomMineIndex = Int.random(in: 0..<mineCells.count)
        let randomCellIndex = Int.random(in: 0..<coveredCells.count)
        
        let mineCell = mineCells[randomMineIndex]
        let targetCell = coveredCells[randomCellIndex]
        
        // 交换地雷和非地雷单元格
        if case .empty(let adjacentMines) = gameBoard[targetCell.row][targetCell.column] {
            gameBoard[mineCell.row][mineCell.column] = .empty(adjacentMines: adjacentMines)
            gameBoard[targetCell.row][targetCell.column] = .mine
            
            // 重新计算周围地雷数量
            calculateAdjacentMines()
        }
    }
    
    // 获取单元格显示内容（考虑盲模式）
    func getCellDisplayContent(at row: Int, at column: Int) -> String? {
        guard row >= 0, row < rows, column >= 0, column < columns else { return nil }
        
        if cellStates[row][column] != .revealed {
            return nil
        }
        
        switch gameBoard[row][column] {
        case .mine:
            return MinesweeperTheme.shared.mineIcon
        case .empty(let adjacentMines):
            if adjacentMines > 0 {
                // 在盲模式下不显示数字
                return isBlindMode ? "" : "\(adjacentMines)"
            } else {
                return ""
            }
        }
    }
    
}
