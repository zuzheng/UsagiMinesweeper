//
//  ImageManager.swift
//  salei
//
//  Created for Minesweeper Game
//

import UIKit

class ImageManager {
    static let shared = ImageManager()
        
    // 图片类型枚举
    enum ImageType: String {
        case victory = "victory_"
        case defeat = "defeat_"
        case playing = "playing_"
        case gameStart = "gameStart_"
    }
    
    // 图片URL缓存，键为图片名称 (e.g., "victory_1"), 值为图片的URL
    private var imageUrlCache: [String: URL] = [:]
    
    // 图片数量
    private let victoryCount = 6
    private let defeatCount = 6
    private let playingCount = 25
    private let gameStartCount = 4
    
    // 用于存储数据的键
    private let unlockedPlayingImagesKey = "unlockedPlayingImages"
    private let unlockedVictoryImagesKey = "unlockedVictoryImages"
    private let unlockedDefeatImagesKey = "unlockedDefeatImages"
    
    // 图片解锁状态
    private(set) var unlockedPlayingImages: Set<Int> = []
    private(set) var unlockedVictoryImages: Set<Int> = []
    private(set) var unlockedDefeatImages: Set<Int> = []
    
    private init() {
        preloadImages()
        loadData()
    }
    
    private func preloadImages() {
        // 预加载所有图片的URL，但不加载实际图片数据
        // 这有助于快速获取URL，而图片加载交由第三方库处理
        let allTypes: [ImageType] = [.victory, .defeat, .playing, .gameStart]
        let counts = [victoryCount, defeatCount, playingCount, gameStartCount]
        
        for (index, type) in allTypes.enumerated() {
            for i in 1...counts[index] {
                let imageName = "\(type.rawValue)\(i)"
                let ext = "webp"
                if let url = Bundle.main.url(forResource: imageName, withExtension: ext) {
                    imageUrlCache[imageName] = url
//                    print("预加载图片URL: \(imageName).\(ext) -> \(url)")
                } else {
                    print("警告：预加载时未找到图片文件: \(imageName).\(ext)")
                }
            }
        }
    }
    
    private func loadData() {
        let defaults = UserDefaults.standard
        
        // 加载已解锁图片集合
        if let playingData = defaults.array(forKey: unlockedPlayingImagesKey) as? [Int] {
            unlockedPlayingImages = Set(playingData)
        }
        if let victoryData = defaults.array(forKey: unlockedVictoryImagesKey) as? [Int] {
            unlockedVictoryImages = Set(victoryData)
        }
        if let defeatData = defaults.array(forKey: unlockedDefeatImagesKey) as? [Int] {
            unlockedDefeatImages = Set(defeatData)
        }
    }
        
    // 获取随机胜利图片URL
    func getRandomVictoryImageUrl() -> URL? {
        return getRandomImageUrl(type: .victory)
    }
    
    // 获取随机失败图片URL
    func getRandomDefeatImageUrl() -> URL? {
        return getRandomImageUrl(type: .defeat)
    }
    
    // 获取随机游戏中图片URL
    func getRandomPlayingImageUrl() -> URL? {
        return getRandomImageUrl(type: .playing)
    }
    
    // 获取随机游戏开始图片URL
    func getRandomGameStartImageUrl() -> URL? {
        return getRandomImageUrl(type: .gameStart)
    }
    
    // 获取随机图片URL
    private func getRandomImageUrl(type: ImageType) -> URL? {
        let unlockedIndices: [Int]
        switch type {
        case .victory:
            unlockedIndices = getUnlockedImageIndices(category: .victory)
        case .defeat:
            unlockedIndices = getUnlockedImageIndices(category: .defeat)
        case .playing:
            unlockedIndices = getUnlockedImageIndices(category: .playing)
        case .gameStart: // gameStart类型不应该通过此方法获取随机，因为它只有一个且固定
            print("警告：不应通过getRandomImageUrl获取gameStart图片URL")
            return getImageUrlByTypeAndIndex(type: .gameStart, index: 1)
        }
        
//        if unlockedIndices.isEmpty {
//            print("警告：没有解锁的 \(type.rawValue) 图片可供选择随机URL")
//            // 作为后备，尝试返回该类型的第一个图片（如果存在）
//            // 这确保即使没有解锁图片，也能尝试提供一个默认图片URL
//            let firstImageName = "\(type.rawValue)1"
//            if let fallbackUrl = imageUrlCache[firstImageName] {
//                print("后备：返回 \(type.rawValue) 的第一张图片URL: \(fallbackUrl)")
//                return fallbackUrl
//            }
//            return nil
//        }
        
        if let randomIndex = unlockedIndices.randomElement() {
            return getImageUrlByTypeAndIndex(type: type, index: randomIndex)
        }
        
        return nil
    }
    
    // 根据类型和索引获取特定图片URL
    func getImageUrlByTypeAndIndex(type: ImageType, index: Int) -> URL? {
        let imageName = "\(type.rawValue)\(index)"
        print("获取图片URL: \(imageName)")
        if let url = imageUrlCache[imageName] {
            return url
        } else {
            // 如果预加载时未找到，尝试再次从Bundle中查找（作为后备）
            let ext = "webp"
            if let url = Bundle.main.url(forResource: imageName, withExtension: ext) {
                imageUrlCache[imageName] = url // 缓存找到的URL
                print("后备查找成功，找到图片URL: \(imageName).\(ext) -> \(url)")
                return url
            }
            print("警告：未在缓存或Bundle中找到图片URL: \(imageName)")
            return nil
        }
    }
    
}

extension ImageManager {

    // MARK: - 图片解锁
    enum ImageCategory {
        case playing
        case victory
        case defeat
    }
    
    func getImageTotalCount(category: ImageCategory) -> Int {
        switch category {
        case .victory:
            return victoryCount
        case .defeat:
            return defeatCount
        case .playing:
            return playingCount
        }
    }
    
    // MARK: - 解锁图片（用于积分抽卡系统）

    func unlockRandomImage(from category: ImageCategory) -> Int? {
        switch category {
        case .playing:
            return unlockRandomImageFromSet(unlockedSet: unlockedPlayingImages, totalCount: playingCount, category: category)
        case .victory:
            return unlockRandomImageFromSet(unlockedSet: unlockedVictoryImages, totalCount: victoryCount, category: category)
        case .defeat:
            return unlockRandomImageFromSet(unlockedSet: unlockedDefeatImages, totalCount: defeatCount, category: category)
        }
    }
    
    private func unlockRandomImageFromSet(unlockedSet: Set<Int>, totalCount: Int, category: ImageCategory) -> Int? {
        // 如果所有图片都已解锁，返回nil
        if unlockedSet.count >= totalCount {
            return nil
        }
        
        // 找出所有未解锁的图片索引
        var lockedIndices: [Int] = []
        for i in 1...totalCount {
            if !unlockedSet.contains(i) {
                lockedIndices.append(i)
            }
        }
        
        // 随机选择一个未解锁的图片
        if let randomIndex = lockedIndices.randomElement() {
            // 根据类别将图片添加到正确的集合中
            switch category {
            case .playing:
                unlockedPlayingImages.insert(randomIndex)
            case .victory:
                unlockedVictoryImages.insert(randomIndex)
            case .defeat:
                unlockedDefeatImages.insert(randomIndex)
            }
            saveData()
            return randomIndex
        }
        
        return nil
    }
    
    // MARK: - 获取已解锁图片的索引数组

    func getUnlockedImageIndices(category: ImageCategory) -> [Int] {
        switch category {
        case .playing:
            return Array(unlockedPlayingImages).sorted()
        case .victory:
            return Array(unlockedVictoryImages).sorted()
        case .defeat:
            return Array(unlockedDefeatImages).sorted()
        }
    }
    
    private func saveData() {
        let defaults = UserDefaults.standard

        // 保存已解锁图片集合
        defaults.set(Array(unlockedPlayingImages), forKey: unlockedPlayingImagesKey)
        defaults.set(Array(unlockedVictoryImages), forKey: unlockedVictoryImagesKey)
        defaults.set(Array(unlockedDefeatImages), forKey: unlockedDefeatImagesKey)
    }
    
}
