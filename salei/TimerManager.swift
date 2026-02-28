//
//  TimerManager.swift
//  salei
//
//  Created for Minesweeper Game
//

import Foundation
import UIKit

// 计时器模式枚举
enum TimerMode {
    case normal      // 普通模式 - 正计时
    case timeChallenge  // 限时挑战模式 - 倒计时
    
    // 获取计时器图标
    var icon: String {
        switch self {
        case .normal:
            return "⏱" // 秒表图标
        case .timeChallenge:
            return "⏳" // 沙漏图标
        }
    }
    
    // 获取初始时间
    var initialTime: Int {
        switch self {
        case .normal:
            return 0 // 从0开始计时
        case .timeChallenge:
            return 180 // 3分钟倒计时
        }
    }
    
    // 是否为倒计时
    var isCountdown: Bool {
        return self == .timeChallenge
    }
}

// 计时器更新回调类型
typealias TimerUpdateCallback = (Int, TimerMode) -> Void

// 计时器管理器
class TimerManager {
    // 单例模式
    static let shared = TimerManager()
    
    // 私有属性
    private var timer: Timer?
    private var currentTime: Int = 0      // 当前计时器时间（正计时模式下递增，限时模式下递减）
    private var elapsedSeconds: Int = 0   // 已用时间（所有模式下都递增）
    private var timerMode: TimerMode = .normal
    private var updateCallback: TimerUpdateCallback?
    private var isRunning: Bool = false
    private var isPaused: Bool = false    // 标记计时器是否暂停
    
    // 公开属性 - 已用时间（所有模式下都是正计时）
    var elapsedTime: Int {
        return elapsedSeconds
    }
    
    // 剩余时间（仅限时挑战模式有效）
    var remainingTime: Int {
        if timerMode == .timeChallenge {
            return currentTime
        } else {
            return 0
        }
    }
    
    // 私有初始化方法
    private init() {}
    
    // 设置计时器模式
    func setMode(_ mode: TimerMode) {
        timerMode = mode
        resetTimer()
    }
    
    // 启动计时器
    func startTimer(callback: @escaping TimerUpdateCallback) {
        // 停止可能正在运行的计时器
        stopTimer()
        
        // 保存回调
        updateCallback = callback
        
        // 设置初始时间
        elapsedSeconds = 0 // 已用时间从0开始
        
        if timerMode == .normal {
            currentTime = 0 // 正计时从0开始
        } else {
            currentTime = timerMode.initialTime // 倒计时从初始值开始
        }
        
        // 创建新计时器
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // 所有模式下，已用时间都递增
            self.elapsedSeconds += 1
            
            if self.timerMode == .normal {
                // 正计时模式，时间递增
                self.currentTime += 1
            } else {
                // 倒计时模式，时间递减
                if self.currentTime > 0 {
                    self.currentTime -= 1
                }
            }
            
            // 调用回调函数
            self.updateCallback?(self.currentTime, self.timerMode)
            
            // 如果是倒计时模式且时间用完，停止计时器
            if self.timerMode == .timeChallenge && self.currentTime == 0 {
                self.stopTimer()
            }
        }
        
        // 立即调用一次回调，更新UI
        updateCallback?(currentTime, timerMode)
        
        // 标记计时器为运行状态
        isRunning = true
    }
    
    // 停止计时器
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
    }
    
    // 重置计时器
    func resetTimer() {
        stopTimer()
        elapsedSeconds = 0 // 重置已用时间
        
        if timerMode == .normal {
            currentTime = 0
        } else {
            currentTime = timerMode.initialTime
        }
    }
    
    // 获取格式化的时间字符串（显示正计时）
    func getFormattedTime() -> String {
        // 所有模式下都显示已用时间（正计时）
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 获取当前模式的图标
    func getModeIcon() -> String {
        return timerMode.icon
    }
    
    // 获取适合当前时间的颜色
    func getTimeColor() -> UIColor {
        if timerMode == .timeChallenge {
            // 限时挑战模式 - 根据剩余时间改变颜色
            if currentTime < 30 {
                return UIColor.systemRed
            } else if currentTime < 60 {
                return UIColor.systemOrange
            } else {
                return UIColor.systemGreen
            }
        } else {
            // 正计时模式 - 使用蓝色
            return UIColor.systemBlue
        }
    }
    
    // 检查计时器是否正在运行
    var isTimerRunning: Bool {
        return isRunning
    }
    
    // 检查计时器是否暂停
    var isTimerPaused: Bool {
        return isPaused
    }
    
    // 暂停计时器
    func pauseTimer() {
        guard isRunning && !isPaused else { return }
        
        timer?.invalidate()
        timer = nil
        isPaused = true
        // 保持isRunning为true，表示计时器仍处于活动状态，只是暂停了
    }
    
    // 恢复计时器
    func resumeTimer() {
        guard isRunning && isPaused else { return }
        
        // 创建新计时器继续计时
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // 所有模式下，已用时间都递增
            self.elapsedSeconds += 1
            
            if self.timerMode == .normal {
                // 正计时模式，时间递增
                self.currentTime += 1
            } else {
                // 倒计时模式，时间递减
                if self.currentTime > 0 {
                    self.currentTime -= 1
                }
            }
            
            // 调用回调函数
            self.updateCallback?(self.currentTime, self.timerMode)
            
            // 如果是倒计时模式且时间用完，停止计时器
            if self.timerMode == .timeChallenge && self.currentTime == 0 {
                self.stopTimer()
            }
        }
        
        isPaused = false
    }
    
    // 获取剩余时间的格式化字符串（仅限时挑战模式）
    func getFormattedRemainingTime() -> String {
        let time = remainingTime
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}