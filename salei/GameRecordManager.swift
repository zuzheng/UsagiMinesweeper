//
//  GameRecordManager.swift
//  salei
//
//  Created for Minesweeper Game
//

import Foundation

// 游戏记录管理器 - 负责管理游戏记录数据和统计分析
class GameRecordManager {
    static let shared = GameRecordManager()
    
    // 游戏记录数据结构
    struct GameRecord: Codable {
        // 游戏完成时的日期时间
        let date: Date
        // 游戏难度等级
        let difficulty: Int
        // 特殊游戏模式标识
        let specialMode: Int
        // 是否获胜
        let isWin: Bool
        // 完成游戏所用时间（可选值，用于限时挑战模式）
        let timeUsed: Int?
        // 成功找到的地雷数量
        let minesFound: Int
        let totalMines: Int
        
        init(difficulty: Int, specialMode: Int, isWin: Bool, timeUsed: Int? = nil, minesFound: Int, totalMines: Int) {
            self.date = Date()
            self.difficulty = difficulty
            self.specialMode = specialMode
            self.isWin = isWin
            self.timeUsed = timeUsed
            self.minesFound = minesFound
            self.totalMines = totalMines
        }
    }
    
    // 游戏统计摘要结构
    struct GameStatsSummary {
        let totalGames: Int
        let totalWins: Int
        let winRate: Double
        let maxWinStreak: Int
        let currentWinStreak: Int
        let averageTime: Int?
        let bestTime: Int?
        let totalPlayTime: Int
        let longestGame: Int? // 新增：最长游戏时间
        let averageMinesFound: Double // 新增：平均每局找到的地雷数
        let totalMinesFound: Int // 新增：总共找到的地雷数
    }
    
    // 所有游戏记录
    private(set) var gameRecords: [GameRecord] = []
    
    // 最佳时间记录（按难度和特殊模式分类）
    private(set) var bestTimes: [Int: [Int: Int]] = [:] // [难度: [特殊模式: 时间]]
    
    // 用户默认设置的键
    private let gameRecordsKey = "gameRecordsData"
    private let bestTimesKey = "bestTimesData"
    
    private init() {
        loadRecords()
    }
    
    // 添加游戏记录
    func addRecord(difficulty: Int, specialMode: Int, isWin: Bool, timeUsed: Int? = nil, minesFound: Int, totalMines: Int) {
        let record = GameRecord(difficulty: difficulty, specialMode: specialMode, isWin: isWin, timeUsed: timeUsed, minesFound: minesFound, totalMines: totalMines)
        gameRecords.append(record)
        
        // 如果是胜利且有时间记录，更新最佳时间
        if isWin, let time = timeUsed {
            updateBestTime(difficulty: difficulty, specialMode: specialMode, time: time)
        }
        
        saveRecords()
    }
    
    // 更新最佳时间
    private func updateBestTime(difficulty: Int, specialMode: Int, time: Int) {
        if bestTimes[difficulty] == nil {
            bestTimes[difficulty] = [:]
        }
        
        if let currentBest = bestTimes[difficulty]?[specialMode] {
            // 只有当新时间更短时才更新
            if time < currentBest {
                bestTimes[difficulty]?[specialMode] = time
            }
        } else {
            bestTimes[difficulty]?[specialMode] = time
        }
        
        // 保存最佳时间记录
        saveRecords()
    }
    
    // 获取特定难度和模式的最佳时间
    func getBestTime(difficulty: Int, specialMode: Int) -> Int? {
        return bestTimes[difficulty]?[specialMode]
    }
    
    // 获取特定难度的胜率
    func getWinRate(difficulty: Int) -> Double {
        let difficultyRecords = gameRecords.filter { $0.difficulty == difficulty }
        guard !difficultyRecords.isEmpty else { return 0.0 }
        
        let wins = difficultyRecords.filter { $0.isWin }.count
        return Double(wins) / Double(difficultyRecords.count) * 100.0
    }
    
    // 获取特定特殊模式的胜率
    func getWinRate(specialMode: Int) -> Double {
        let modeRecords = gameRecords.filter { $0.specialMode == specialMode }
        guard !modeRecords.isEmpty else { return 0.0 }
        
        let wins = modeRecords.filter { $0.isWin }.count
        return Double(wins) / Double(modeRecords.count) * 100.0
    }
    
    // 获取总体游戏统计摘要
    func getOverallStatsSummary() -> GameStatsSummary {
        let totalGames = gameRecords.count
        let wins = gameRecords.filter { $0.isWin }
        let totalWins = wins.count
        let winRate = totalGames > 0 ? Double(totalWins) / Double(totalGames) * 100.0 : 0.0
        
        // 计算最大连胜和当前连胜
        var maxStreak = 0
        var currentStreak = 0
        var tempStreak = 0
        
        // 按日期排序记录
        let sortedRecords = gameRecords.sorted { $0.date < $1.date }
        
        for record in sortedRecords {
            if record.isWin {
                tempStreak += 1
                maxStreak = max(maxStreak, tempStreak)
            } else {
                tempStreak = 0
            }
        }
        
        // 计算当前连胜（从最近的记录开始倒数）
        for record in sortedRecords.reversed() {
            if record.isWin {
                currentStreak += 1
            } else {
                break
            }
        }
        
        // 计算平均时间和总游戏时间
        let gamesWithTime = gameRecords.filter { $0.timeUsed != nil }
        let totalPlayTime = gamesWithTime.reduce(0) { $0 + ($1.timeUsed ?? 0) }
        let averageTime = gamesWithTime.isEmpty ? nil : totalPlayTime / gamesWithTime.count
        
        // 获取最佳时间（所有难度和模式中的最佳）
        var bestTime: Int? = nil
        for (_, modeTimes) in bestTimes {
            for (_, time) in modeTimes {
                if bestTime == nil || time < bestTime! {
                    bestTime = time
                }
            }
        }
        
        // 计算最长游戏时间
        let longestGame = gamesWithTime.max { ($0.timeUsed ?? 0) < ($1.timeUsed ?? 0) }?.timeUsed
        
        // 计算地雷统计
        let totalMinesFound = gameRecords.reduce(0) { $0 + $1.minesFound }
        let averageMinesFound = totalGames > 0 ? Double(totalMinesFound) / Double(totalGames) : 0.0
        
        return GameStatsSummary(
            totalGames: totalGames,
            totalWins: totalWins,
            winRate: winRate,
            maxWinStreak: maxStreak,
            currentWinStreak: currentStreak,
            averageTime: averageTime,
            bestTime: bestTime,
            totalPlayTime: totalPlayTime,
            longestGame: longestGame,
            averageMinesFound: averageMinesFound,
            totalMinesFound: totalMinesFound
        )
    }
    
    // 获取特定难度的游戏统计摘要
    func getDifficultyStatsSummary(difficulty: Int) -> GameStatsSummary {
        let difficultyRecords = gameRecords.filter { $0.difficulty == difficulty }
        let totalGames = difficultyRecords.count
        let wins = difficultyRecords.filter { $0.isWin }
        let totalWins = wins.count
        let winRate = totalGames > 0 ? Double(totalWins) / Double(totalGames) * 100.0 : 0.0
        
        // 计算最大连胜和当前连胜
        var maxStreak = 0
        var currentStreak = 0
        var tempStreak = 0
        
        // 按日期排序记录
        let sortedRecords = difficultyRecords.sorted { $0.date < $1.date }
        
        for record in sortedRecords {
            if record.isWin {
                tempStreak += 1
                maxStreak = max(maxStreak, tempStreak)
            } else {
                tempStreak = 0
            }
        }
        
        // 计算当前连胜（从最近的记录开始倒数）
        for record in sortedRecords.reversed() {
            if record.isWin {
                currentStreak += 1
            } else {
                break
            }
        }
        
        // 计算平均时间和总游戏时间
        let gamesWithTime = difficultyRecords.filter { $0.timeUsed != nil }
        let totalPlayTime = gamesWithTime.reduce(0) { $0 + ($1.timeUsed ?? 0) }
        let averageTime = gamesWithTime.isEmpty ? nil : totalPlayTime / gamesWithTime.count
        
        // 获取该难度的最佳时间
        var bestTime: Int? = nil
        if let modeTimes = bestTimes[difficulty] {
            for (_, time) in modeTimes {
                if bestTime == nil || time < bestTime! {
                    bestTime = time
                }
            }
        }
        
        // 计算最长游戏时间
        let longestGame = gamesWithTime.max { ($0.timeUsed ?? 0) < ($1.timeUsed ?? 0) }?.timeUsed
        
        // 计算地雷统计
        let totalMinesFound = difficultyRecords.reduce(0) { $0 + $1.minesFound }
        let averageMinesFound = totalGames > 0 ? Double(totalMinesFound) / Double(totalGames) : 0.0
        
        return GameStatsSummary(
            totalGames: totalGames,
            totalWins: totalWins,
            winRate: winRate,
            maxWinStreak: maxStreak,
            currentWinStreak: currentStreak,
            averageTime: averageTime,
            bestTime: bestTime,
            totalPlayTime: totalPlayTime,
            longestGame: longestGame,
            averageMinesFound: averageMinesFound,
            totalMinesFound: totalMinesFound
        )
    }
    
    // 获取特定特殊模式的游戏统计摘要
    func getSpecialModeStatsSummary(specialMode: Int) -> GameStatsSummary {
        let modeRecords = gameRecords.filter { $0.specialMode == specialMode }
        let totalGames = modeRecords.count
        let wins = modeRecords.filter { $0.isWin }
        let totalWins = wins.count
        let winRate = totalGames > 0 ? Double(totalWins) / Double(totalGames) * 100.0 : 0.0
        
        // 计算最大连胜和当前连胜
        var maxStreak = 0
        var currentStreak = 0
        var tempStreak = 0
        
        // 按日期排序记录
        let sortedRecords = modeRecords.sorted { $0.date < $1.date }
        
        for record in sortedRecords {
            if record.isWin {
                tempStreak += 1
                maxStreak = max(maxStreak, tempStreak)
            } else {
                tempStreak = 0
            }
        }
        
        // 计算当前连胜（从最近的记录开始倒数）
        for record in sortedRecords.reversed() {
            if record.isWin {
                currentStreak += 1
            } else {
                break
            }
        }
        
        // 计算平均时间和总游戏时间
        let gamesWithTime = modeRecords.filter { $0.timeUsed != nil }
        let totalPlayTime = gamesWithTime.reduce(0) { $0 + ($1.timeUsed ?? 0) }
        let averageTime = gamesWithTime.isEmpty ? nil : totalPlayTime / gamesWithTime.count
        
        // 获取该特殊模式的最佳时间（跨所有难度）
        var bestTime: Int? = nil
        for (_, modeTimes) in bestTimes {
            if let time = modeTimes[specialMode] {
                if bestTime == nil || time < bestTime! {
                    bestTime = time
                }
            }
        }
        
        // 计算最长游戏时间
        let longestGame = gamesWithTime.max { ($0.timeUsed ?? 0) < ($1.timeUsed ?? 0) }?.timeUsed
        
        // 计算地雷统计
        let totalMinesFound = modeRecords.reduce(0) { $0 + $1.minesFound }
        let averageMinesFound = totalGames > 0 ? Double(totalMinesFound) / Double(totalGames) : 0.0
        
        return GameStatsSummary(
            totalGames: totalGames,
            totalWins: totalWins,
            winRate: winRate,
            maxWinStreak: maxStreak,
            currentWinStreak: currentStreak,
            averageTime: averageTime,
            bestTime: bestTime,
            totalPlayTime: totalPlayTime,
            longestGame: longestGame,
            averageMinesFound: averageMinesFound,
            totalMinesFound: totalMinesFound
        )
    }
    
    // 获取最近的游戏记录
    func getRecentGames(limit: Int = 10) -> [GameRecord] {
        let sortedRecords = gameRecords.sorted { $0.date > $1.date }
        return Array(sortedRecords.prefix(limit))
    }
    
    // 获取按月份分组的游戏记录统计
    func getMonthlyStats(months: Int = 6) -> [(month: String, wins: Int, losses: Int)] {
        var result: [(month: String, wins: Int, losses: Int)] = []
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        
        // 获取当前月份和前几个月
        let currentDate = Date()
        var monthsData: [String: (wins: Int, losses: Int)] = [:]
        
        // 初始化最近几个月的数据结构
        for i in 0..<months {
            if let date = calendar.date(byAdding: .month, value: -i, to: currentDate) {
                let monthStr = dateFormatter.string(from: date)
                monthsData[monthStr] = (0, 0)
            }
        }
        
        // 统计每个月的胜负场次
        for record in gameRecords {
            let monthStr = dateFormatter.string(from: record.date)
            if monthsData[monthStr] != nil {
                if record.isWin {
                    monthsData[monthStr]!.wins += 1
                } else {
                    monthsData[monthStr]!.losses += 1
                }
            }
        }
        
        // 转换为结果数组并按月份排序
        for i in 0..<months {
            if let date = calendar.date(byAdding: .month, value: -i, to: currentDate) {
                let monthStr = dateFormatter.string(from: date)
                if let data = monthsData[monthStr] {
                    result.append((month: monthStr, wins: data.wins, losses: data.losses))
                }
            }
        }
        
        return result.reversed()
    }
    
    // 保存记录到用户默认设置
    private func saveRecords() {
        if let encodedData = try? JSONEncoder().encode(gameRecords) {
            UserDefaults.standard.set(encodedData, forKey: gameRecordsKey)
        }
        
        if let encodedTimes = try? JSONEncoder().encode(bestTimes) {
            UserDefaults.standard.set(encodedTimes, forKey: bestTimesKey)
        }
    }
    
    // 从用户默认设置加载记录
    private func loadRecords() {
        // 加载游戏记录
        if let savedData = UserDefaults.standard.data(forKey: gameRecordsKey),
           let loadedRecords = try? JSONDecoder().decode([GameRecord].self, from: savedData) {
            gameRecords = loadedRecords
        }
        
        // 加载最佳时间记录
        if let savedTimes = UserDefaults.standard.data(forKey: bestTimesKey),
           let loadedTimes = try? JSONDecoder().decode([Int: [Int: Int]].self, from: savedTimes) {
            bestTimes = loadedTimes
        }
    }
    
    // 清除所有记录
    func clearAllRecords() {
        gameRecords = []
        bestTimes = [:]
        UserDefaults.standard.removeObject(forKey: gameRecordsKey)
        UserDefaults.standard.removeObject(forKey: bestTimesKey)
    }
}
