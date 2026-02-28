//
//  PointsCalculator.swift
//  salei
//
//  Created for Minesweeper Game
//

import Foundation

class PointsCalculator {
    static let shared = PointsCalculator()
    
    private init() {}
    
    /// 计算游戏结束时应获得的积分
    /// - Parameters:
    ///   - isWin: 是否获胜
    ///   - difficulty: 游戏难度
    ///   - specialMode: 特殊游戏模式
    ///   - timeUsed: 用时（秒）
    ///   - minesFound: 找到的地雷数量
    ///   - totalMines: 总地雷数量
    /// - Returns: 获得的积分
    func calculatePoints(isWin: Bool, difficulty: Int, specialMode: Int, timeUsed: Int?, minesFound: Int, totalMines: Int) -> Int {
        // 基础积分 - 根据难度
        var points = getBasicPointsByDifficulty(difficulty: difficulty)
        
        // 如果游戏失败，只给予基础积分的一部分，并根据找到的地雷数量增加积分
        if !isWin {
            // 失败时获得基础积分的30%
            points = Int(Double(points) * 0.3)
            
            // 根据找到的地雷比例增加积分
            let mineRatio = Double(minesFound) / Double(totalMines)
            let mineBonus = Int(Double(points) * mineRatio)
            points += mineBonus
            
            return max(points, 5) // 确保至少获得5积分
        }
        
        // 胜利情况下的额外积分
        
        // 1. 特殊模式加成
        points += getSpecialModeBonus(specialMode: specialMode)
        
        // 2. 时间加成 - 如果完成得越快，获得的积分越多
        if let time = timeUsed {
            points += getTimeBonus(difficulty: difficulty, timeUsed: time)
        }
        
        // 3. 连胜加成
//        let winStreak = GameRecord.shared.currentWinStreak
//        points += getWinStreakBonus(winStreak: winStreak)
        
        return points
    }
    
    // MARK: - 私有辅助方法
    
    /// 根据难度获取基础积分
    private func getBasicPointsByDifficulty(difficulty: Int) -> Int {
        switch difficulty {
        case 0: // 简单
            return 50
        case 1: // 中等
            return 100
        case 2: // 困难
            return 200
        case 3: // 专家
            return 300
        default:
            return 50
        }
    }
    
    /// 获取特殊模式积分加成
    private func getSpecialModeBonus(specialMode: Int) -> Int {
        var bonus = 0
        
        // 盲模式加成
        if specialMode & 1 != 0 { // 检查是否启用盲模式
            bonus += 50
        }
        
        // 移动地雷模式加成
        if specialMode & 2 != 0 { // 检查是否启用移动地雷模式
            bonus += 75
        }
        
        // 限时模式加成
        if specialMode & 4 != 0 { // 检查是否启用限时模式
            bonus += 100
        }
        
        return bonus
    }
    
    /// 获取时间加成
    private func getTimeBonus(difficulty: Int, timeUsed: Int) -> Int {
        // 根据难度确定基准时间（秒）
        let benchmarkTime: Int
        switch difficulty {
        case 0: // 简单
            benchmarkTime = 60 // 1分钟
        case 1: // 中等
            benchmarkTime = 180 // 3分钟
        case 2: // 困难
            benchmarkTime = 360 // 6分钟
        case 3: // 专家
            benchmarkTime = 600 // 10分钟
        default:
            benchmarkTime = 180
        }
        
        // 如果用时少于基准时间，给予额外积分
        if timeUsed < benchmarkTime {
            let timeRatio = Double(benchmarkTime - timeUsed) / Double(benchmarkTime)
            return Int(Double(getBasicPointsByDifficulty(difficulty: difficulty)) * timeRatio * 0.5)
        }
        
        return 0
    }
    
    /// 获取连胜加成
    private func getWinStreakBonus(winStreak: Int) -> Int {
        // 每连胜一次增加5%的积分，最高增加50%
        let streakMultiplier = min(winStreak * 5, 50) // 最高50%加成
        return Int(Double(50) * Double(streakMultiplier) / 100.0) // 基于50点计算连胜加成
    }
}
