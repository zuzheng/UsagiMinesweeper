//
//  PointsManager.swift
//  salei
//
//  Created for Minesweeper Game
//

import Foundation

class PointsManager {
    static let shared = PointsManager()
    
    // 积分相关属性
    private(set) var currentPoints: Int = 0
    private(set) var totalEarnedPoints: Int = 0
    private(set) var totalSpentPoints: Int = 0
    
    // 抽卡相关属性
    private(set) var cardPacks: [CardPack] = []
    
    // 用于存储数据的键
    private let currentPointsKey = "currentPoints"
    private let totalEarnedPointsKey = "totalEarnedPoints"
    private let totalSpentPointsKey = "totalSpentPoints"
    
    // 初始化方法
    private init() {
        loadData()
        setupCardPacks()
    }
    
    // MARK: - 数据持久化
    
    private func loadData() {
        let defaults = UserDefaults.standard
        
        currentPoints = defaults.integer(forKey: currentPointsKey)
        totalEarnedPoints = defaults.integer(forKey: totalEarnedPointsKey)
        totalSpentPoints = defaults.integer(forKey: totalSpentPointsKey)
    }
    
    private func saveData() {
        let defaults = UserDefaults.standard
        
        defaults.set(currentPoints, forKey: currentPointsKey)
        defaults.set(totalEarnedPoints, forKey: totalEarnedPointsKey)
        defaults.set(totalSpentPoints, forKey: totalSpentPointsKey)
    }
    
    // MARK: - 卡包设置
    
    private func setupCardPacks() {
        // 初始化卡包
        cardPacks = [
            CardPack(id: 1, name: "游戏中表情包", description: "解锁游戏中可爱的表情动画", cost: 150, cardType: .playing),
            CardPack(id: 2, name: "胜利表情包", description: "解锁胜利时的庆祝动画", cost: 200, cardType: .victory),
            CardPack(id: 3, name: "失败表情包", description: "解锁失败时的安慰动画", cost: 200, cardType: .defeat)
        ]
    }
    
    // MARK: - 积分管理
    
    /// 添加积分
    /// - Parameter points: 要添加的积分数量
    /// - Returns: 新增的积分数量
    func addPoints(_ points: Int) -> Int {
        guard points > 0 else { return 0 }
        
        currentPoints += points
        totalEarnedPoints += points
        saveData()
        return points
    }
    
    /// 使用积分
    /// - Parameter points: 要使用的积分数量
    /// - Returns: 是否成功使用积分
    func usePoints(_ points: Int) -> Bool {
        guard points > 0 && currentPoints >= points else { return false }
        
        currentPoints -= points
        totalSpentPoints += points
        saveData()
        return true
    }
    
    // MARK: - 抽卡系统
    
    /// 抽取卡片
    /// - Parameter packId: 卡包ID
    /// - Returns: 抽取结果，包含是否成功和解锁的卡片ID
    func drawCard(packId: Int) -> (success: Bool, cardId: Int?) {
        guard let pack = cardPacks.first(where: { $0.id == packId }) else {
            return (false, nil)
        }
        
        // 检查积分是否足够
        if currentPoints < pack.cost {
            return (false, nil)
        }
        
        // 使用积分
        if !usePoints(pack.cost) {
            return (false, nil)
        }
        
        // 根据卡片类型解锁对应的图片
        var unlockedCardId: Int? = nil
        
        switch pack.cardType {
        case .playing:
            unlockedCardId = unlockRandomImage(from: .playing)
        case .victory:
            unlockedCardId = unlockRandomImage(from: .victory)
        case .defeat:
            unlockedCardId = unlockRandomImage(from: .defeat)
        }

        return (true, unlockedCardId)
    }
    
    /// 解锁随机图片
    /// - Parameter category: 图片类别
    /// - Returns: 解锁的图片ID，如果所有图片都已解锁则返回nil
    private func unlockRandomImage(from category: ImageManager.ImageCategory) -> Int? {
        
        return ImageManager.shared.unlockRandomImage(from: category)
    }
    
    // MARK: - 重置
    
    /// 重置所有积分和抽卡记录
    func resetAllData() {
        currentPoints = 0
        totalEarnedPoints = 0
        totalSpentPoints = 0
        saveData()
    }
}

// MARK: - 卡包结构体

struct CardPack {
    let id: Int
    let name: String
    let description: String
    let cost: Int
    let cardType: CardType
    
    enum CardType {
        case playing
        case victory
        case defeat
    }
}
