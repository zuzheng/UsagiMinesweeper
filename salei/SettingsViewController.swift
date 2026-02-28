//
//  SettingsViewController.swift
//  salei
//
//  Created for Minesweeper Game
//

import UIKit

class SettingsViewController: UIViewController {
    
    // UI元素
    private var contentView: UIView!
    private var difficultySegmentedControl: UISegmentedControl!
    private var specialModeSegmentedControl: UISegmentedControl!
    private var themeSegmentedControl: UISegmentedControl! // 新增主题选择控件
    private var soundToggleButton: UIButton!
    private var resetButton: UIButton!
    private var specialModeDescriptionLabel: UILabel!
    private var themeDescriptionLabel: UILabel! // 新增主题描述标签
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // 设置标题和背景
        title = "游戏设置"
        MinesweeperTheme.shared.applyBackgroundTheme(to: view)
        
        // 创建内容视图
        contentView = UIView()
        contentView.backgroundColor = UIColor.clear
        view.addSubview(contentView)
        
        // 创建难度选择控件
        let difficultyLabel = createSectionLabel(text: "游戏难度")
        difficultySegmentedControl = UISegmentedControl(items: GameDifficulty.allCases.map { $0.title })
        difficultySegmentedControl.selectedSegmentIndex = GameModeManager.shared.currentDifficulty.rawValue
        difficultySegmentedControl.addTarget(self, action: #selector(difficultyChanged(_:)), for: .valueChanged)
        
        // 创建特殊模式选择控件
        let specialModeLabel = createSectionLabel(text: "游戏模式")
        specialModeSegmentedControl = UISegmentedControl(items: SpecialGameModeType.allCases.map { $0.title })
        specialModeSegmentedControl.selectedSegmentIndex = SpecialGameMode.shared.currentMode.rawValue
        specialModeSegmentedControl.addTarget(self, action: #selector(specialModeChanged(_:)), for: .valueChanged)
        
        // 创建特殊模式描述标签
        specialModeDescriptionLabel = UILabel()
        specialModeDescriptionLabel.text = SpecialGameMode.shared.currentMode.description
        specialModeDescriptionLabel.textAlignment = .center
        specialModeDescriptionLabel.font = UIFont.systemFont(ofSize: 14)
        specialModeDescriptionLabel.textColor = UIColor.systemGray
        specialModeDescriptionLabel.numberOfLines = 0
        
        // 创建主题选择控件
        let themeLabel = createSectionLabel(text: "游戏主题")
        themeSegmentedControl = UISegmentedControl(items: ThemeType.allCases.map { $0.title })
        themeSegmentedControl.selectedSegmentIndex = MinesweeperTheme.shared.currentTheme.rawValue
        themeSegmentedControl.addTarget(self, action: #selector(themeChanged(_:)), for: .valueChanged)
        
        // 创建主题描述标签
        themeDescriptionLabel = UILabel()
        themeDescriptionLabel.text = MinesweeperTheme.shared.currentTheme.description
        themeDescriptionLabel.textAlignment = .center
        themeDescriptionLabel.font = UIFont.systemFont(ofSize: 14)
        themeDescriptionLabel.textColor = UIColor.systemGray
        themeDescriptionLabel.numberOfLines = 0
        
        // 创建声音切换按钮
        let soundLabel = createSectionLabel(text: "游戏音效")
        soundToggleButton = UIButton(type: .system)
        soundToggleButton.setTitle(AudioManager.shared.isSoundMuted() ? "🔇 静音" : "🔊 音效开启", for: .normal)
        soundToggleButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        MinesweeperTheme.shared.applyButtonTheme(to: soundToggleButton, color: .systemOrange)
        soundToggleButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        soundToggleButton.addTarget(self, action: #selector(toggleSound), for: .touchUpInside)
        
        // 创建重置按钮
        resetButton = UIButton(type: .system)
        resetButton.setTitle("重置游戏数据", for: .normal)
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        MinesweeperTheme.shared.applyButtonTheme(to: resetButton, color: .systemRed)
        resetButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        resetButton.addTarget(self, action: #selector(resetGameData), for: .touchUpInside)
        
        // 添加所有控件到内容视图
        contentView.addSubview(difficultyLabel)
        contentView.addSubview(difficultySegmentedControl)
        contentView.addSubview(specialModeLabel)
        contentView.addSubview(specialModeSegmentedControl)
        contentView.addSubview(specialModeDescriptionLabel)
        contentView.addSubview(themeLabel)
        contentView.addSubview(themeSegmentedControl)
        contentView.addSubview(themeDescriptionLabel)
        contentView.addSubview(soundLabel)
        contentView.addSubview(soundToggleButton)
        contentView.addSubview(resetButton)
        
        // 设置约束
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        }
        
        difficultyLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.leading.trailing.equalTo(contentView)
        }
        
        difficultySegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(difficultyLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(contentView)
            make.height.equalTo(40)
        }
        
        specialModeLabel.snp.makeConstraints { make in
            make.top.equalTo(difficultySegmentedControl.snp.bottom).offset(30)
            make.leading.trailing.equalTo(contentView)
        }
        
        specialModeSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(specialModeLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(contentView)
            make.height.equalTo(40)
        }
        
        specialModeDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(specialModeSegmentedControl.snp.bottom).offset(10)
            make.leading.trailing.equalTo(contentView)
        }
        
        themeLabel.snp.makeConstraints { make in
            make.top.equalTo(specialModeDescriptionLabel.snp.bottom).offset(30)
            make.leading.trailing.equalTo(contentView)
        }
        
        themeSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(themeLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(contentView)
            make.height.equalTo(40)
        }
        
        themeDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(themeSegmentedControl.snp.bottom).offset(10)
            make.leading.trailing.equalTo(contentView)
        }
        
        soundLabel.snp.makeConstraints { make in
            make.top.equalTo(themeDescriptionLabel.snp.bottom).offset(30)
            make.leading.trailing.equalTo(contentView)
        }
        
        soundToggleButton.snp.makeConstraints { make in
            make.top.equalTo(soundLabel.snp.bottom).offset(10)
            make.centerX.equalTo(contentView)
            make.width.equalTo(200)
        }
        
        resetButton.snp.makeConstraints { make in
            make.top.equalTo(soundToggleButton.snp.bottom).offset(40)
            make.centerX.equalTo(contentView)
            make.width.equalTo(200)
        }
    }
    
    private func createSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }
    
    // MARK: - 动作处理
    
    @objc private func difficultyChanged(_ sender: UISegmentedControl) {
        if let difficulty = GameDifficulty(rawValue: sender.selectedSegmentIndex) {
            GameModeManager.shared.setDifficulty(difficulty)
            
            // 添加选择动画
            UIView.animate(withDuration: 0.2, animations: {
                self.difficultySegmentedControl.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    self.difficultySegmentedControl.transform = CGAffineTransform.identity
                }
            }
        }
    }
    
    @objc private func specialModeChanged(_ sender: UISegmentedControl) {
        if let mode = SpecialGameModeType(rawValue: sender.selectedSegmentIndex) {
            SpecialGameMode.shared.setMode(mode)
            specialModeDescriptionLabel.text = mode.description
            
            // 添加选择动画
            UIView.animate(withDuration: 0.2, animations: {
                self.specialModeSegmentedControl.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    self.specialModeSegmentedControl.transform = CGAffineTransform.identity
                }
            }
        }
    }
    
    @objc private func themeChanged(_ sender: UISegmentedControl) {
        if let theme = ThemeType(rawValue: sender.selectedSegmentIndex) {
            MinesweeperTheme.shared.setTheme(theme)
            themeDescriptionLabel.text = theme.description
            
            // 更新视图主题
            MinesweeperTheme.shared.applyBackgroundTheme(to: view)
            
            // 添加选择动画
            UIView.animate(withDuration: 0.2, animations: {
                self.themeSegmentedControl.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    self.themeSegmentedControl.transform = CGAffineTransform.identity
                }
            }
        }
    }
    
    @objc private func toggleSound() {
        let isMuted = AudioManager.shared.toggleMute()
        
        // 更新按钮外观
        if isMuted {
            soundToggleButton.setTitle("🔇 静音", for: .normal)
            soundToggleButton.backgroundColor = UIColor.systemGray.withAlphaComponent(0.8)
        } else {
            soundToggleButton.setTitle("🔊 音效开启", for: .normal)
            soundToggleButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.8)
        }
        
        // 添加按钮点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.soundToggleButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.soundToggleButton.transform = CGAffineTransform.identity
            }
        }
    }
    
    @objc private func resetGameData() {
        // 创建确认对话框
        let alert = UIAlertController(title: "重置游戏数据", message: "确定要重置所有游戏数据吗？这将清除所有游戏记录和统计信息。", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .destructive) { _ in
            // 重置游戏记录和统计数据
            GameRecordManager.shared.clearAllRecords()
            
            // 显示成功提示
            let successAlert = UIAlertController(title: "重置成功", message: "所有游戏数据已重置", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "确定", style: .default))
            self.present(successAlert, animated: true)
        })
        
        present(alert, animated: true)
    }
}
