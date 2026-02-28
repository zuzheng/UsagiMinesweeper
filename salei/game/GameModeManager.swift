//
//  GameModeManager.swift
//  salei
//
//  Created for Minesweeper Game
//

import Foundation

// 游戏难度枚举
enum GameDifficulty: Int, CaseIterable {
    case easy = 0
    case medium = 1
    case hard = 2
    
    var title: String {
        switch self {
        case .easy: return "简单"
        case .medium: return "中等"
        case .hard: return "困难"
        }
    }
    
    var rows: Int {
        switch self {
        case .easy: return 10
        case .medium: return 12
        case .hard: return 15
        }
    }
    
    var columns: Int {
        switch self {
        case .easy: return 10
        case .medium: return 12
        case .hard: return 15
        }
    }
    
    var mineCount: Int {
        switch self {
        case .easy: return 15
        case .medium: return 25
        case .hard: return 40
        }
    }
    
    var cellSize: CGFloat {
        switch self {
        case .easy: return 30
        case .medium: return 30
        case .hard: return 30
        }
    }
}

// 游戏模式管理器
class GameModeManager {
    static let shared = GameModeManager()
    
    // 当前选择的游戏难度
    private(set) var currentDifficulty: GameDifficulty = .easy
    
    // 用户默认设置的键
    private let difficultyKey = "selectedGameDifficulty"
    
    private init() {
        // 从用户默认设置加载保存的难度
        if let savedDifficulty = UserDefaults.standard.object(forKey: difficultyKey) as? Int,
           let difficulty = GameDifficulty(rawValue: savedDifficulty) {
            currentDifficulty = difficulty
        }
    }
    
    // 设置游戏难度
    func setDifficulty(_ difficulty: GameDifficulty) {
        currentDifficulty = difficulty
        // 保存到用户默认设置
        UserDefaults.standard.set(difficulty.rawValue, forKey: difficultyKey)
    }
    
    // 获取当前游戏配置
    var rows: Int { return currentDifficulty.rows }
    var columns: Int { return currentDifficulty.columns }
    var mineCount: Int { return currentDifficulty.mineCount }
    var cellSize: CGFloat { return currentDifficulty.cellSize }
}
