//
//  AudioManager.swift
//  salei
//
//  Created for Minesweeper Game
//

import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var isMuted: Bool = false
    
    private init() {
        setupAudioSession()
        preloadSounds()
    }
    
    private func setupAudioSession() {
        do {
            // 使用.ambient类别而不是.playback，减少系统资源占用
            // .ambient适用于背景音效，不会中断其他应用的音频
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            print("音频会话已成功配置为低资源消耗模式")
        } catch {
            print("设置音频会话失败: \(error)")
        }
    }
    
    private func preloadSounds() {
        // 音效文件已添加到项目的主目录中
        let soundNames = ["start", "click", "success", "failure", "flag_on", "flag_off"]
        
        // 避免重复加载音频文件
        if !audioPlayers.isEmpty {
            print("音频文件已加载，跳过重复加载")
            return
        }
                
        // 创建空的音频播放器，避免应用崩溃
        for name in soundNames {
            // 尝试从Bundle中加载
            if let soundURL = Bundle.main.url(forResource: name, withExtension: "mp3") {
                loadAudioPlayer(name: name, url: soundURL)
            } else {
                print("找不到音效文件: \(name).mp3 或文件格式不正确")
                // 创建一个空的音频播放器，避免应用崩溃
                createEmptyAudioPlayer(for: name)
            }
        }
    }
    
    private func loadAudioPlayer(name: String, url: URL) {
        do {
            // 简化音频加载过程，减少不必要的数据检查
            let player = try AVAudioPlayer(contentsOf: url)
            // 设置较低的音量，减少系统负担
            player.volume = 0.7
            // 减少预缓冲大小，降低内存使用
            player.prepareToPlay()
            audioPlayers[name] = player
            print("成功加载音效: \(name)")
        } catch {
            print("无法加载音效: \(name), 错误: \(error)")
            createEmptyAudioPlayer(for: name)
        }
    }
    
    private func createEmptyAudioPlayer(for name: String) {
        // 创建一个空的音频播放器，避免应用崩溃
        audioPlayers[name] = nil
        print("已为 \(name) 创建空音频播放器占位符")
    }
    
    func playSound(_ name: String) {
        if isMuted {
            print("声音已静音，跳过播放: \(name)")
            return
        }
        
        guard let player = audioPlayers[name] else {
            print("找不到有效的音效: \(name)，请确保添加了正确格式的MP3文件")
            return
        }
        
        // 如果同一个音效正在播放，不要重新开始播放
        // 这可以减少音频系统的负担
        if player.isPlaying {
            // 对于某些音效，我们可能希望允许重叠播放
            // 但对于大多数情况，避免重叠播放可以减少系统负担
            if name != "click" { // 点击音效可能需要快速连续播放
                return
            }
            
            // 如果是点击音效且距离上次播放时间太短，也跳过
            if name == "click" && player.currentTime < 0.1 {
                return
            }
            
            // 否则重置播放位置
            player.currentTime = 0
        }
        
        // 使用较低的音量播放，减少系统负担
        player.volume = 0.7
        player.play()
    }
    
    // 添加静音切换功能
    func toggleMute() -> Bool {
        isMuted = !isMuted
        
        // 如果切换到非静音状态，播放一个短暂的音效提示用户
        if !isMuted {
            if let player = audioPlayers["click"] {
                player.play()
            }
        }
        
        return isMuted
    }
    
    // 获取当前静音状态
    func isSoundMuted() -> Bool {
        return isMuted
    }
    
    func playStartSound() {
        playSound("start")
    }
    
    func playClickSound() {
        playSound("click")
    }
    
    func playSuccessSound() {
        playSound("success")
    }
    
    func playFailureSound() {
        playSound("failure")
    }
    
    func playFlagOnSound() {
        playSound("flag_on")
    }
    
    func playFlagOffSound() {
        playSound("flag_off")
    }
}
