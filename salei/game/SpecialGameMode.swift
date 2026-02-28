//
//  SpecialGameMode.swift
//  salei
//
//  Created for Minesweeper Game
//

import Foundation

// 特殊游戏模式类型枚举
enum SpecialGameModeType: Int, CaseIterable {
    case normal = 0      // 普通模式
    case timeChallenge = 1  // 限时挑战模式
    case blindMode = 2    // 盲模式（不显示周围地雷数量）
    case movingMines = 3  // 移动地雷模式（地雷位置会随机变化）
    
    var title: String {
        switch self {
        case .normal: return "普通模式"
        case .timeChallenge: return "限时挑战"
        case .blindMode: return "盲模式"
        case .movingMines: return "移动地雷"
        }
    }
    
    var description: String {
        switch self {
        case .normal: 
            return "标准扫雷游戏规则。"
        case .timeChallenge: 
            return "在限定时间内完成游戏，时间越短得分越高。"
        case .blindMode: 
            return "不显示周围地雷数量，全靠记忆和推理。"
        case .movingMines: 
            return "每次点击后，未揭示区域的地雷有几率移动位置。"
        }
    }
}

// 特殊游戏模式管理器
class SpecialGameMode {
    static let shared = SpecialGameMode()
    
    // 当前选择的特殊游戏模式
    private(set) var currentMode: SpecialGameModeType = .normal
    
    // 计时器相关属性（用于限时挑战模式）
    private var gameTimer: Timer?
    private(set) var remainingTime: Int = 180 // 默认3分钟
    private(set) var isTimerRunning: Bool = false
    
    // 移动地雷概率（用于移动地雷模式）
    let mineMoveProbability: Double = 0.2 // 20%的概率移动
    
    // 用户默认设置的键
    private let specialModeKey = "selectedSpecialGameMode"
    
    private init() {
        // 从用户默认设置加载保存的模式
        if let savedMode = UserDefaults.standard.object(forKey: specialModeKey) as? Int,
           let mode = SpecialGameModeType(rawValue: savedMode) {
            currentMode = mode
        }
    }
    
    // 设置特殊游戏模式
    func setMode(_ mode: SpecialGameModeType) {
        currentMode = mode
        // 保存到用户默认设置
        UserDefaults.standard.set(mode.rawValue, forKey: specialModeKey)
        
        // 如果切换到非限时模式，停止计时器
        if mode != .timeChallenge {
            stopTimer()
        }
    }
    
    // 判断是否为盲模式（不显示数字）
    var isBlindMode: Bool {
        return currentMode == .blindMode
    }
    
    // 判断是否为移动地雷模式
    var isMovingMinesMode: Bool {
        return currentMode == .movingMines
    }
    
    // 判断是否为限时挑战模式
    var isTimeChallengeMode: Bool {
        return currentMode == .timeChallenge
    }
    
    // 开始计时器（用于限时挑战模式）
    func startTimer(initialTime: Int = 180, timerCallback: @escaping (Int) -> Void) {
        // 停止现有计时器
        stopTimer()
        
        // 设置初始时间
        remainingTime = initialTime
        isTimerRunning = true
        
        // 创建新计时器
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.remainingTime > 0 {
                self.remainingTime -= 1
                timerCallback(self.remainingTime)
            } else {
                // 时间用完
                self.stopTimer()
                timerCallback(0)
            }
        }
    }
    
    // 停止计时器
    func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
        isTimerRunning = false
    }
    
    // 暂停计时器
    func pauseTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
        isTimerRunning = false
    }
    
    // 恢复计时器
    func resumeTimer(timerCallback: @escaping (Int) -> Void) {
        if !isTimerRunning && remainingTime > 0 {
            gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                    timerCallback(self.remainingTime)
                } else {
                    // 时间用完
                    self.stopTimer()
                    timerCallback(0)
                }
            }
            isTimerRunning = true
        }
    }
    
    // 移动地雷（用于移动地雷模式）
    func shouldMoveMines() -> Bool {
        guard isMovingMinesMode else { return false }
        return Double.random(in: 0...1) < mineMoveProbability
    }
}
